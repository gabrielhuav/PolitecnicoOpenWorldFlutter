import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'; // Importante para usar IOWebSocketChannel

import '../../../core/utils/app_logger.dart';

/// SharedPreferences vía SettingsRepository.
const String kDefaultMultiplayerServerUrl = 'wss://politecnicoopenworld.onrender.com';

/// Provider editable de la URL del servidor. main.dart hace el override
/// con el valor guardado en SharedPreferences.
final multiplayerServerUrlProvider =
    StateProvider<String>((ref) => kDefaultMultiplayerServerUrl);

// ── Modelo: jugador remoto ──────────────────────────────────────────
class RemotePlayer {
  final String id;
  final LatLng position;
  final String displayName;
  final bool isHost;
  final bool isDriving;

  const RemotePlayer({
    required this.id,
    required this.position,
    required this.displayName,
    this.isHost = false,
    this.isDriving = false,
  });

  RemotePlayer copyWith({
    LatLng? position,
    String? displayName,
    bool? isHost,
    bool? isDriving,
  }) =>
      RemotePlayer(
        id: id,
        position: position ?? this.position,
        displayName: displayName ?? this.displayName,
        isHost: isHost ?? this.isHost,
        isDriving: isDriving ?? this.isDriving,
      );
}

// ── Modelo: NPC remoto ──────────────────────────────────────────────
/// NPC simulado por el host de zona de otro cliente. La capa
/// MultiplayerLayer los renderiza; el ticker local de NpcNotifier sigue
/// generando los suyos en paralelo (queda pendiente desactivarlos en
/// modo multijugador para evitar duplicación).
class RemoteNpc {
  final String id;
  final LatLng position;
  final String type; // 'car' o 'person'
  final double rotation; // grados, 0 = norte

  const RemoteNpc({
    required this.id,
    required this.position,
    required this.type,
    this.rotation = 0,
  });
}

// ── Estado ──────────────────────────────────────────────────────────
enum MultiplayerStatus { disconnected, connecting, connected, error }

class MultiplayerState {
  final MultiplayerStatus status;
  final Map<String, RemotePlayer> players;
  final Map<String, RemoteNpc> remoteNpcs;
  final String? errorMessage;

  /// Lo asigna el servidor vía SESSION_INIT. null mientras no llegue.
  final String? sessionId;
  final bool isZoneHost;
  final String playerName;

  const MultiplayerState({
    required this.status,
    required this.players,
    required this.remoteNpcs,
    required this.playerName,
    this.sessionId,
    this.errorMessage,
    this.isZoneHost = false,
  });

  factory MultiplayerState.initial() => const MultiplayerState(
        status: MultiplayerStatus.disconnected,
        players: {},
        remoteNpcs: {},
        playerName: 'Jugador',
      );

  MultiplayerState copyWith({
    MultiplayerStatus? status,
    Map<String, RemotePlayer>? players,
    Map<String, RemoteNpc>? remoteNpcs,
    String? errorMessage,
    String? sessionId,
    bool? isZoneHost,
    String? playerName,
    bool clearError = false,
    bool clearSessionId = false,
  }) =>
      MultiplayerState(
        status: status ?? this.status,
        players: players ?? this.players,
        remoteNpcs: remoteNpcs ?? this.remoteNpcs,
        sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
        isZoneHost: isZoneHost ?? this.isZoneHost,
        playerName: playerName ?? this.playerName,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  bool get isConnected => status == MultiplayerStatus.connected;
}

// ── Notifier ────────────────────────────────────────────────────────
class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  MultiplayerNotifier() : super(MultiplayerState.initial());

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  Future<void> connect({
    required String serverUrl,
    String playerName = 'Jugador',
  }) async {
    if (state.isConnected || state.status == MultiplayerStatus.connecting) {
      return;
    }

    state = state.copyWith(
      status: MultiplayerStatus.connecting,
      playerName: playerName,
      players: const {},
      remoteNpcs: const {},
      clearError: true,
      clearSessionId: true,
      isZoneHost: false,
    );
    AppLogger.log.i('Multiplayer: conectando a $serverUrl');

    try {
      // REEMPLAZO CLAVE: Usar IOWebSocketChannel para inyectar el pingInterval exacto de Android
      _channel = IOWebSocketChannel.connect(
        Uri.parse(serverUrl),
        // Manda un ping cada 25 segundos para mantener viva la conexión en Render
        pingInterval: const Duration(seconds: 25), 
      );
      
      await _channel!.ready;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      if (!mounted) return;
      state = state.copyWith(status: MultiplayerStatus.connected);
      AppLogger.log.i('Multiplayer: conexión establecida');
    } catch (e) {
      AppLogger.log.e('Multiplayer: error al conectar', error: e);
      if (mounted) {
        state = state.copyWith(
          status: MultiplayerStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// Se llama desde WorldMapScreen en cada cambio de posición del
  /// jugador. Sin la primera emisión, el server no nos registra y
  /// nadie nos ve.
  void broadcastMovement(LatLng pos) {
    if (!state.isConnected) return;
    _sendJson({
      'type': 'PLAYER_UPDATE',
      // Convención del server.js: x = longitud, y = latitud.
      'x': pos.longitude,
      'y': pos.latitude,
      'displayName': state.playerName,
      'action': 'idle',
      'facingRight': true,
      'isDriving': false,
    });
  }

  void disconnect() {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close(1000);
    _channel = null;
    if (mounted) {
      state = MultiplayerState.initial().copyWith(playerName: state.playerName);
    }
    AppLogger.log.i('Multiplayer: desconectado');
  }

  // ── Entrada de mensajes ────────────────────────────────────────────
  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'SESSION_INIT':
          final id = data['sessionId'] as String?;
          if (id != null) {
            state = state.copyWith(sessionId: id);
            AppLogger.log.i('Multiplayer: SESSION_INIT $id');
          }

        case 'ROLE_UPDATE':
          final isHost = data['isZoneHost'] as bool? ?? false;
          state = state.copyWith(isZoneHost: isHost);
          AppLogger.log.d('Multiplayer: ROLE_UPDATE isHost=$isHost');

        case 'DISCONNECT':
          final id = data['id'] as String?;
          final orphans = data['orphanedNpcs'];
          var players = state.players;
          var npcs = state.remoteNpcs;
          if (id != null && players.containsKey(id)) {
            final updated = Map<String, RemotePlayer>.from(players)..remove(id);
            players = updated;
            AppLogger.log.i('Multiplayer: salió $id');
          }
          if (orphans is List) {
            final updated = Map<String, RemoteNpc>.from(npcs);
            for (final o in orphans) {
              if (o is String) updated.remove(o);
            }
            npcs = updated;
          }
          state = state.copyWith(players: players, remoteNpcs: npcs);

        case 'SYNC_ALL_NPCS':
          final list = data['npcs'];
          if (list is List) {
            final npcs = <String, RemoteNpc>{};
            for (final n in list) {
              if (n is Map) {
                final npc = _parseNpc(Map<String, dynamic>.from(n));
                if (npc != null) npcs[npc.id] = npc;
              }
            }
            state = state.copyWith(remoteNpcs: npcs);
            AppLogger.log.i('Multiplayer: SYNC_ALL_NPCS ${npcs.length} NPCs');
          }

        case 'NPC_SPAWN':
        case 'NPC_UPDATE':
          final n = data['npc'];
          if (n is Map) {
            final npc = _parseNpc(Map<String, dynamic>.from(n));
            if (npc != null) {
              final npcs = Map<String, RemoteNpc>.from(state.remoteNpcs);
              npcs[npc.id] = npc;
              state = state.copyWith(remoteNpcs: npcs);
            }
          }

        case 'NPC_BATCH_UPDATE':
          final list = data['npcs'];
          if (list is List) {
            final npcs = Map<String, RemoteNpc>.from(state.remoteNpcs);
            for (final n in list) {
              if (n is Map) {
                final npc = _parseNpc(Map<String, dynamic>.from(n));
                if (npc != null) npcs[npc.id] = npc;
              }
            }
            state = state.copyWith(remoteNpcs: npcs);
          }

        case 'NPC_DESTROY':
          final id = data['npcId'] as String?;
          if (id != null && state.remoteNpcs.containsKey(id)) {
            final npcs = Map<String, RemoteNpc>.from(state.remoteNpcs)
              ..remove(id);
            state = state.copyWith(remoteNpcs: npcs);
          }

        case 'PLAYER_UPDATE':
        case null:
          // El server reenvía PLAYER_UPDATE sin tipo o con type='PLAYER_UPDATE'.
          _handleRemotePlayerUpdate(data);

        case 'MASTER_SYNC_CHECK':
        case 'PLAYER_DAMAGE':
          // No implementado todavía.
          break;

        default:
          AppLogger.log.d('Multiplayer: tipo desconocido $type');
      }
    } catch (e) {
      AppLogger.log.w('Multiplayer: parse error: $e');
    }
  }

  void _handleRemotePlayerUpdate(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    if (id == null || id == state.sessionId) return;
    final x = (data['x'] as num?)?.toDouble();
    final y = (data['y'] as num?)?.toDouble();
    if (x == null || y == null) return;
    final displayName = data['displayName'] as String? ?? 'Jugador';
    final isHost = data['isHost'] as bool? ?? false;
    final isDriving = data['isDriving'] as bool? ?? false;

    final pos = LatLng(y, x); // y=lat, x=lon (inverso del envío).
    final updated = Map<String, RemotePlayer>.from(state.players);
    final existing = updated[id];
    if (existing == null) {
      updated[id] = RemotePlayer(
        id: id,
        position: pos,
        displayName: displayName,
        isHost: isHost,
        isDriving: isDriving,
      );
      AppLogger.log.i('Multiplayer: nuevo remoto $id ($displayName)');
    } else {
      updated[id] = existing.copyWith(
        position: pos,
        displayName: displayName,
        isHost: isHost,
        isDriving: isDriving,
      );
    }
    state = state.copyWith(players: updated);
  }

  RemoteNpc? _parseNpc(Map<String, dynamic> data) {
    final id = data['id'];
    if (id is! String) return null;
    final x = (data['x'] as num?)?.toDouble();
    final y = (data['y'] as num?)?.toDouble();
    if (x == null || y == null) return null;
    final type = (data['type'] as String?) ?? 'person';
    // El Android client puede usar nombres distintos; los aceptamos todos.
    final rotation = (data['rotation'] as num?)?.toDouble() ??
        (data['vehicleRotation'] as num?)?.toDouble() ??
        (data['rotationAngle'] as num?)?.toDouble() ??
        0.0;
    return RemoteNpc(
      id: id,
      position: LatLng(y, x),
      type: type,
      rotation: rotation,
    );
  }

  void _onError(Object e) {
    AppLogger.log.e('Multiplayer: error de stream', error: e);
    if (mounted) {
      state = state.copyWith(
        status: MultiplayerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _onDone() {
    AppLogger.log.i('Multiplayer: stream cerrado');
    if (mounted) {
      state = state.copyWith(
        status: MultiplayerStatus.disconnected,
        players: const {},
        remoteNpcs: const {},
        clearSessionId: true,
      );
    }
  }

  void _sendJson(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      AppLogger.log.w('Multiplayer: send error: $e');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final multiplayerProvider =
    StateNotifierProvider<MultiplayerNotifier, MultiplayerState>(
  (ref) => MultiplayerNotifier(),
);