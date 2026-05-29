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

function sendTo(ws, data) {
    if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(data));
    }
}

function broadcastToOthers(senderWs, msg) {
    const str = typeof msg === 'string' ? msg : JSON.stringify(msg);
    wss.clients.forEach((client) => {
        if (client !== senderWs && client.readyState === WebSocket.OPEN) {
            client.send(str);
        }
    });
}

function broadcastAll(data) {
    const str = JSON.stringify(data);
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(str);
        }
    });
}

// Heartbeat WebSocket
const heartbeatInterval = setInterval(() => {
    wss.clients.forEach((ws) => {
        if (ws.isAlive === false) {
            console.log(`[x] Sin respuesta: ${ws.sessionId}, terminando`);
            return ws.terminate();
        }
        ws.isAlive = false;
        ws.ping();
    });
}, 30000);

// GC de NPCs huérfanos (sin actualización en 15 s)
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
        broadcastAll({ type: 'DISCONNECT', orphanedNpcs: toDelete });
    }
}, 5000);

// Sync maestra cada 5 s
const masterSyncInterval = setInterval(() => {
    if (wss.clients.size > 0) {
        broadcastAll({
            type: 'MASTER_SYNC_CHECK',
            activeNpcIds: Array.from(npcs.keys())
        });
    }
}, 5000);

wss.on('connection', (ws) => {
    ws.sessionId = uuidv4();
    ws.isAlive = true;
    ws.isHost = false;

    console.log(`[+] Conectado: ${ws.sessionId} (total: ${wss.clients.size})`);

    // 1. UUID propio
    sendTo(ws, { type: 'SESSION_INIT', sessionId: ws.sessionId });

    // 2. Snapshot de jugadores ya conectados
    // CRÍTICO: sin esto, el jugador B nunca ve al jugador A que ya estaba
    for (const p of players.values()) {
        sendTo(ws, {
            type: 'PLAYER_UPDATE',
            id: p.id,
            x: p.x,
            y: p.y,
            displayName: p.displayName,
            action: p.action || 'idle',
            facingRight: p.facingRight !== false,
            isHost: p.isHost,
            isDriving: p.isDriving || false,
            health: p.health || 100,
        });
    }

    // 3. NPCs existentes
    const existingNpcs = Array.from(npcs.values());
    if (existingNpcs.length > 0) {
        sendTo(ws, { type: 'SYNC_ALL_NPCS', npcs: existingNpcs });
    }

    ws.on('pong', () => { ws.isAlive = true; });

    ws.on('message', (raw) => {
        try {
            const data = JSON.parse(raw);
            if (!data) return;

            switch (data.type) {
                case 'PING':
                    // Silencio — el keepalive no necesita respuesta visible
                    ws.isAlive = true;
                    return;

                case undefined:
                case null:
                case 'PLAYER_UPDATE':
                    handlePlayerUpdate(ws, data);
                    return;

                case 'NPC_BATCH_UPDATE':
                    if (Array.isArray(data.npcs)) {
                        const now = Date.now();
                        for (const npc of data.npcs) {
                            if (npc?.id) {
                                npcs.set(npc.id, {
                                    ...npc,
                                    ownerId: ws.sessionId,
                                    lastUpdated: now
                                });
                            }
                        }
                        broadcastToOthers(ws, raw);
                    }
                    return;

                case 'NPC_SPAWN':
                case 'NPC_UPDATE':
                    if (data.npc?.id) {
                        npcs.set(data.npc.id, {
                            ...data.npc,
                            ownerId: ws.sessionId,
                            lastUpdated: Date.now()
                        });
                        broadcastToOthers(ws, raw);
                    }
                    return;

                case 'NPC_DESTROY':
                    if (data.npcId) {
                        npcs.delete(data.npcId);
                        broadcastToOthers(ws, raw);
                    }
                    return;

                case 'PLAYER_DAMAGE':
                    if (data.targetId) {
                        broadcastToOthers(ws, raw);
                    }
                    return;

                default:
                    console.log(`[?] Tipo desconocido: ${data.type}`);
            }
        } catch (e) {
            console.error('Error procesando mensaje:', e.message);
        }
    });

    ws.on('close', () => {
        console.log(`[-] Desconectado: ${ws.sessionId} (restantes: ${wss.clients.size})`);

        // Limpiar NPCs del jugador que se fue
        const orphanedNpcs = [];
        for (const [id, npc] of npcs.entries()) {
            if (npc.ownerId === ws.sessionId) {
                orphanedNpcs.push(id);
                npcs.delete(id);
            }
        }

        players.delete(ws.sessionId);

        broadcastAll({
            type: 'DISCONNECT',
            id: ws.sessionId,
            orphanedNpcs,
        });
    });
});

function handlePlayerUpdate(ws, data) {
    // Determinar si este cliente debe ser Host de zona:
    // Host = ningún otro Host cercano con UUID menor.
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
        if (ws.isHost && !shouldBeHost) {
            const toDelete = [];
            for (const [id, npc] of npcs.entries()) {
            if (npc.ownerId === ws.sessionId) {
                toDelete.push(id);
                npcs.delete(id);
            }
            }
            if (toDelete.length > 0) {
            broadcastAll({ type: 'DISCONNECT', orphanedNpcs: toDelete });
            }
        }
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

    // Reenviar a todos los demás con el id del emisor
    broadcastToOthers(ws, {
        ...data,
        type: 'PLAYER_UPDATE',
        id: ws.sessionId,
        isHost: ws.isHost,
    });
}

server.on('close', () => {
    clearInterval(heartbeatInterval);
    clearInterval(npcGcInterval);
    clearInterval(masterSyncInterval);
});

server.listen(PORT, () => {
    console.log(`POW Flutter Multiplayer :${PORT} path=/flutter`);
});