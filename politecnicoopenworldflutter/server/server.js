const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 8080;
const server = http.createServer(app);

const players = new Map();
const npcs = new Map();

const HOST_RADIUS = 0.004;

// Status con jugadores visibles para debug
app.get('/status', (req, res) => {
    res.json({
        estado: 'Online',
        path: '/flutter',
        jugadoresConectados: players.size,
        npcsActivos: npcs.size,
        jugadores: Array.from(players.values()).map(p => ({
            id: p.id,
            displayName: p.displayName,
            x: p.x,
            y: p.y,
            action: p.action,
            facingRight: p.facingRight,
            isHost: p.isHost,
        })),
        timestamp: new Date().toISOString()
    });
});

app.get('/', (req, res) => {
    res.json({ msg: 'POW Flutter Multiplayer' });
});

const wss = new WebSocket.Server({ noServer: true });

server.on('upgrade', (request, socket, head) => {
    if (request.url === '/flutter') {
        wss.handleUpgrade(request, socket, head, (ws) => {
            wss.emit('connection', ws, request);
        });
    } else {
        socket.destroy();
    }
});

function broadcastToOthers(senderWs, msg) {
    wss.clients.forEach((client) => {
        if (client !== senderWs && client.readyState === WebSocket.OPEN) {
            client.send(msg.toString());
        }
    });
}

function broadcastAll(msg) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(msg.toString());
        }
    });
}

// Heartbeat
const heartbeatInterval = setInterval(() => {
    wss.clients.forEach((ws) => {
        if (ws.missedPings === undefined) ws.missedPings = 0;
        if (ws.isAlive === false) {
            ws.missedPings++;
            if (ws.missedPings >= 6) return ws.terminate();
        } else {
            ws.missedPings = 0;
        }
        ws.isAlive = false;
        ws.ping();
    });
}, 30000);

// GC de NPCs huérfanos
const npcGcInterval = setInterval(() => {
    const now = Date.now();
    const toDelete = [];
    for (const [id, npc] of npcs.entries()) {
        if (now - (npc.lastUpdated || now) > 15000) {
            toDelete.push(id);
            npcs.delete(id);
        }
    }
    if (toDelete.length > 0) {
        broadcastAll(JSON.stringify({ type: 'DISCONNECT', orphanedNpcs: toDelete }));
    }
}, 5000);

// Sync maestra
const masterSyncInterval = setInterval(() => {
    if (wss.clients.size > 0) {
        broadcastAll(JSON.stringify({
            type: 'MASTER_SYNC_CHECK',
            activeNpcIds: Array.from(npcs.keys())
        }));
    }
}, 5000);

wss.on('connection', (ws) => {
    ws.sessionId = uuidv4();
    ws.isAlive = true;
    ws.missedPings = 0;
    // CRÍTICO: arrancar como no-Host. El rol se asigna en el primer
    // PLAYER_UPDATE cuando ya conocemos la posición y los vecinos.
    ws.isHost = false;

    console.log(`[+] Conectado: ${ws.sessionId} (total: ${wss.clients.size})`);

    // 1. UUID propio
    ws.send(JSON.stringify({ type: 'SESSION_INIT', sessionId: ws.sessionId }));

    // 2. Estado actual de otros jugadores para que el recién llegado
    //    los vea inmediatamente sin esperar su primer PLAYER_UPDATE.
    const currentPlayers = Array.from(players.values());
    for (const p of currentPlayers) {
        ws.send(JSON.stringify({
            type: 'PLAYER_UPDATE',
            id: p.id,
            x: p.x,
            y: p.y,
            displayName: p.displayName,
            action: p.action,
            facingRight: p.facingRight,
            isHost: p.isHost,
            isDriving: p.isDriving,
            health: p.health,
        }));
    }

    // 3. NPCs existentes
    const existingNpcs = Array.from(npcs.values());
    if (existingNpcs.length > 0) {
        ws.send(JSON.stringify({ type: 'SYNC_ALL_NPCS', npcs: existingNpcs }));
    }

    ws.on('pong', () => { ws.isAlive = true; });

    ws.on('message', (raw) => {
        try {
            const data = JSON.parse(raw);
            if (!data) return;

            if (!data.type || data.type === 'PLAYER_UPDATE') {
                handlePlayerUpdate(ws, data);
                return;
            }
            if (data.type === 'NPC_SPAWN' || data.type === 'NPC_UPDATE') {
                if (data.npc?.id) {
                    npcs.set(data.npc.id, { ...data.npc, ownerId: ws.sessionId, lastUpdated: Date.now() });
                    broadcastToOthers(ws, raw);
                }
                return;
            }
            if (data.type === 'NPC_BATCH_UPDATE' && Array.isArray(data.npcs)) {
                const now = Date.now();
                for (const npc of data.npcs) {
                    if (npc?.id) npcs.set(npc.id, { ...npc, ownerId: ws.sessionId, lastUpdated: now });
                }
                broadcastToOthers(ws, raw);
                return;
            }
            if (data.type === 'NPC_DESTROY' && data.npcId) {
                npcs.delete(data.npcId);
                broadcastToOthers(ws, raw);
                return;
            }
            if (data.type === 'PLAYER_DAMAGE' && data.targetId) {
                broadcastToOthers(ws, raw);
                return;
            }
            // Keepalive del cliente: ignorar silenciosamente.
            if (data.type === 'PING') {
                return;
            }
        } catch (e) {
            console.error('Error procesando mensaje:', e.message);
        }
    });

    ws.on('close', () => {
        console.log(`[-] Desconectado: ${ws.sessionId} (total restante: ${wss.clients.size - 1})`);
        players.delete(ws.sessionId);
        broadcastAll(JSON.stringify({ type: 'DISCONNECT', id: ws.sessionId }));
    });
});

function handlePlayerUpdate(ws, data) {
    // Calcular si este cliente debe ser Host:
    // - Si no hay ningún Host activo en el radio → este cliente es Host.
    // - Si hay Hosts cercanos → solo es Host si su UUID es el menor (desempate).
    let nearbyHostMinId = null;

    for (const p of players.values()) {
        if (p.id === ws.sessionId || !p.isHost) continue;
        const dist = Math.sqrt(
            Math.pow((p.y || 0) - (data.y || 0), 2) +
            Math.pow((p.x || 0) - (data.x || 0), 2)
        );
        if (dist < HOST_RADIUS) {
            if (nearbyHostMinId === null || p.id < nearbyHostMinId) {
                nearbyHostMinId = p.id;
            }
        }
    }

    const shouldBeHost = nearbyHostMinId === null || ws.sessionId < nearbyHostMinId;

    if (ws.isHost !== shouldBeHost) {
        ws.isHost = shouldBeHost;
        ws.send(JSON.stringify({ type: 'ROLE_UPDATE', isZoneHost: shouldBeHost }));
        console.log(`[Host] ${ws.sessionId.slice(0, 8)} isHost=${shouldBeHost}`);
    }

    players.set(ws.sessionId, {
        id: ws.sessionId,
        displayName: typeof data.displayName === 'string' ? data.displayName : '',
        x: typeof data.x === 'number' ? data.x : 0,
        y: typeof data.y === 'number' ? data.y : 0,
        action: typeof data.action === 'string' ? data.action : 'idle',
        facingRight: typeof data.facingRight === 'boolean' ? data.facingRight : true,
        isHost: ws.isHost,
        isDriving: typeof data.isDriving === 'boolean' ? data.isDriving : false,
        health: typeof data.health === 'number' ? data.health : 100,
    });

    // Reenviar a todos los demás con el id del emisor.
    broadcastToOthers(ws, JSON.stringify({
        ...data,
        id: ws.sessionId,
        isHost: ws.isHost,
    }));
}

server.on('close', () => {
    clearInterval(heartbeatInterval);
    clearInterval(npcGcInterval);
    clearInterval(masterSyncInterval);
});

server.listen(PORT, () => {
    console.log(`POW Flutter Multiplayer :${PORT} path=/flutter`);
});
