// ============================================================
// Servidor multijugador POW para cliente Flutter.
//
// Protocolo idéntico al servidor de Android original:
//   - SESSION_INIT       → asigna UUID al conectarse
//   - ROLE_UPDATE        → notifica si el cliente es Host de zona
//   - PLAYER_UPDATE      → se reenvía a los demás clientes
//   - NPC_BATCH_UPDATE   → broadcast de NPCs simulados por el Host
//   - NPC_SPAWN/UPDATE   → idem (forma individual)
//   - NPC_DESTROY        → elimina un NPC del estado global
//   - SYNC_ALL_NPCS      → se manda a quien se conecta
//   - MASTER_SYNC_CHECK  → reconciliación periódica anti-fantasmas
//   - PLAYER_DAMAGE      → daño entre jugadores (combate)
//   - DISCONNECT         → cliente caído + NPCs huérfanos
//
// Diferencias respecto al de Android:
//   - Solo acepta conexiones al path /flutter (separación lógica).
//   - El endpoint /status devuelve estadísticas legibles para
//     debug y para el ServerWarmupManager del cliente.
// ============================================================

const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 8080;
const server = http.createServer(app);

// ── Estado global del servidor ──────────────────────────────────
const players = new Map();   // sessionId → datos del jugador
const npcs = new Map();      // npcId     → datos del NPC

// Radio de autoridad del Host en grados (~444 m a la latitud de CDMX).
const HOST_RADIUS = 0.004;

// ── Endpoint HTTP de health-check ───────────────────────────────
app.get('/status', (req, res) => {
    res.json({
        estado: 'Online',
        path: '/flutter',
        jugadoresConectados: players.size,
        npcsActivos: npcs.size,
        timestamp: new Date().toISOString()
    });
});

app.get('/', (req, res) => {
    res.json({ msg: 'POW Flutter Multiplayer — usa el path /flutter por WebSocket' });
});

// ── WebSocket Server filtrado por path ──────────────────────────
// noServer: true nos da control fino sobre qué conexiones aceptamos.
// Solo dejamos pasar las que apuntan exactamente a /flutter.
const wss = new WebSocket.Server({ noServer: true });

server.on('upgrade', (request, socket, head) => {
    const { url } = request;
    if (url === '/flutter') {
        wss.handleUpgrade(request, socket, head, (ws) => {
            wss.emit('connection', ws, request);
        });
    } else {
        socket.destroy();
    }
});

// ── Utilidades de broadcast ─────────────────────────────────────
function broadcastToOthers(senderWs, messageAsString) {
    wss.clients.forEach((client) => {
        if (client !== senderWs && client.readyState === WebSocket.OPEN) {
            client.send(messageAsString.toString());
        }
    });
}

function broadcastAll(messageAsString) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(messageAsString.toString());
        }
    });
}

// ── Heartbeat ────────────────────────────────────────────────────
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

// ── Garbage Collector de NPCs huérfanos ──────────────────────────
// Si un Host se desconecta, sus NPCs sobreviven 15 s. Si nadie los
// adopta en ese plazo, los borramos y avisamos a todos.
const npcGcInterval = setInterval(() => {
    const now = Date.now();
    const npcsToDelete = [];
    for (const [npcId, npcData] of npcs.entries()) {
        if (now - (npcData.lastUpdated || now) > 15000) {
            npcsToDelete.push(npcId);
            npcs.delete(npcId);
        }
    }
    if (npcsToDelete.length > 0) {
        broadcastAll(JSON.stringify({
            type: 'DISCONNECT',
            orphanedNpcs: npcsToDelete
        }));
    }
}, 5000);

// ── Sincronización maestra periódica ────────────────────────────
// Cada 5 s mandamos a todos la lista oficial de NPCs vivos para que
// el cliente pueda borrar fantasmas que se le quedaron en memoria.
const masterSyncInterval = setInterval(() => {
    if (wss.clients.size > 0) {
        broadcastAll(JSON.stringify({
            type: 'MASTER_SYNC_CHECK',
            activeNpcIds: Array.from(npcs.keys())
        }));
    }
}, 5000);

// ── Manejador de conexión ───────────────────────────────────────
wss.on('connection', (ws) => {
    ws.sessionId = uuidv4();
    ws.isAlive = true;
    ws.missedPings = 0;
    ws.isHost = true; // por defecto, todo cliente nuevo es Host de su zona

    console.log(`[+] Cliente Flutter conectado: ${ws.sessionId}`);

    // 1. Mandamos su UUID
    ws.send(JSON.stringify({ type: 'SESSION_INIT', sessionId: ws.sessionId }));

    // 2. Su rol inicial. Sin este mensaje el cliente nunca activaría
    // isZoneHost y nadie spawnearía NPCs en el modo multijugador.
    ws.send(JSON.stringify({ type: 'ROLE_UPDATE', isZoneHost: true }));

    // 3. Snapshot de NPCs existentes para que vea de inmediato lo
    // que ya está vivo en el mundo (NPCs de otros Hosts cercanos).
    const existingNpcs = Array.from(npcs.values());
    if (existingNpcs.length > 0) {
        ws.send(JSON.stringify({ type: 'SYNC_ALL_NPCS', npcs: existingNpcs }));
    }

    ws.on('pong', () => { ws.isAlive = true; });

    ws.on('message', (raw) => {
        try {
            const data = JSON.parse(raw);

            // ── PLAYER_UPDATE (o mensaje sin tipo: legacy) ─────────
            if (data && (!data.type || data.type === 'PLAYER_UPDATE')) {
                handlePlayerUpdate(ws, data);
                return;
            }

            // ── NPC_SPAWN / NPC_UPDATE individual ──────────────────
            if (data && (data.type === 'NPC_SPAWN' || data.type === 'NPC_UPDATE')) {
                if (data.npc && data.npc.id) {
                    npcs.set(data.npc.id, {
                        ...data.npc,
                        ownerId: ws.sessionId,
                        lastUpdated: Date.now()
                    });
                    broadcastToOthers(ws, raw);
                }
                return;
            }

            // ── NPC_BATCH_UPDATE ───────────────────────────────────
            if (data && data.type === 'NPC_BATCH_UPDATE') {
                if (Array.isArray(data.npcs)) {
                    const now = Date.now();
                    for (const npc of data.npcs) {
                        if (npc && npc.id) {
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
            }

            // ── NPC_DESTROY ────────────────────────────────────────
            if (data && data.type === 'NPC_DESTROY' && data.npcId) {
                npcs.delete(data.npcId);
                broadcastToOthers(ws, raw);
                return;
            }

            // ── PLAYER_DAMAGE (combate entre jugadores) ────────────
            // El servidor solo reenvía; el cliente cuyo sessionId == targetId
            // aplica el daño en su propia salud. Esto evita que un cliente
            // pueda decidir cuánta vida pierden los demás de forma directa,
            // aunque siempre puede mentir sobre el daño que pidió. La
            // validación fuerte es responsabilidad de cada cliente.
            if (data && data.type === 'PLAYER_DAMAGE' && data.targetId) {
                broadcastToOthers(ws, raw);
                return;
            }

            // Cualquier otro tipo es ignorado (logs por si vienen mensajes
            // de versiones futuras del cliente).
            console.log(`[?] Mensaje ignorado tipo=${data?.type}`);
        } catch (e) {
            console.error('Error al procesar mensaje:', e.message);
        }
    });

    ws.on('close', () => {
        console.log(`[-] Cliente Flutter desconectado: ${ws.sessionId}`);
        players.delete(ws.sessionId);
        broadcastAll(JSON.stringify({ type: 'DISCONNECT', id: ws.sessionId }));
        // Los NPCs de este cliente NO se borran inmediatamente:
        // el GC los matará a los 15s si nadie los adopta.
    });
});

// ── Lógica de rol Host/zona (idéntica al servidor Android) ──────
function handlePlayerUpdate(ws, data) {
    let isNowHost = ws.isHost;

    if (!ws.isHost) {
        // No soy Host: si no hay otro Host cerca, paso a serlo.
        let nearbyHost = false;
        for (const other of players.values()) {
            if (other.isHost && other.id !== ws.sessionId) {
                const dist = Math.sqrt(
                    Math.pow(other.y - data.y, 2) +
                    Math.pow(other.x - data.x, 2)
                );
                if (dist < HOST_RADIUS) { nearbyHost = true; break; }
            }
        }
        if (!nearbyHost) isNowHost = true;
    } else {
        // Soy Host: si hay otro Host cerca y mi UUID es "mayor", cedo.
        // Comparación lexicográfica → desempate determinista sin coordinarse.
        for (const other of players.values()) {
            if (other.isHost && other.id !== ws.sessionId) {
                const dist = Math.sqrt(
                    Math.pow(other.y - data.y, 2) +
                    Math.pow(other.x - data.x, 2)
                );
                if (dist < HOST_RADIUS && ws.sessionId > other.id) {
                    isNowHost = false;
                    break;
                }
            }
        }
    }

    if (ws.isHost !== isNowHost) {
        ws.isHost = isNowHost;
        ws.send(JSON.stringify({ type: 'ROLE_UPDATE', isZoneHost: isNowHost }));
        console.log(`[Zonas] ${ws.sessionId} ahora Host=${isNowHost}`);
    }

    players.set(ws.sessionId, {
        id: ws.sessionId,
        displayName: typeof data.displayName === 'string' ? data.displayName : '',
        x: typeof data.x === 'number' ? data.x : 0,
        y: typeof data.y === 'number' ? data.y : 0,
        action: typeof data.action === 'string' ? data.action : '',
        facingRight: typeof data.facingRight === 'boolean' ? data.facingRight : true,
        isHost: ws.isHost,
        isDriving: typeof data.isDriving === 'boolean' ? data.isDriving : false,
        health: typeof data.health === 'number' ? data.health : 100
    });

    // Reenviar a los demás (incluyendo el campo id para que sepan
    // de quién es la actualización).
    broadcastToOthers(ws, JSON.stringify({
        ...data,
        id: ws.sessionId,
        isHost: ws.isHost
    }));
}

// ── Limpieza al cerrar el servidor ──────────────────────────────
server.on('close', () => {
    clearInterval(heartbeatInterval);
    clearInterval(npcGcInterval);
    clearInterval(masterSyncInterval);
});

server.listen(PORT, () => {
    console.log(`POW Flutter Multiplayer escuchando en :${PORT} (WS path /flutter)`);
});
