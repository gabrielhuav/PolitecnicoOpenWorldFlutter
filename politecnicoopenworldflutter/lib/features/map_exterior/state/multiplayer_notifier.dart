import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/utils/app_logger.dart';

// URL del servidor WebSocket (server.js). 10.0.2.2 → host desde el emulador Android.
const String kMultiplayerServerUrl = 'ws://10.0.2.2:8080';

class RemotePlayer {
  final String id;
  final LatLng position;
  final String name;

  const RemotePlayer({
    required this.id,
    required this.position,
    required this.name,
  });

  RemotePlayer copyWith({LatLng? position, String? name}) => RemotePlayer(
        id: id,
        position: position ?? this.position,
        name: name ?? this.name,
      );
}

enum MultiplayerStatus { disconnected, connecting, connected, error }

class MultiplayerState {
  final MultiplayerStatus status;
  final Map<String, RemotePlayer> players;
  final String? errorMessage;
  /// Lo asigna el server vía SESSION_INIT. Null mientras no se haya recibido.
  final String? localPlayerId;
  final bool isZoneHost;
  final String playerName;

  const MultiplayerState({
    required this.status,
    required this.players,
    required this.playerName,
    this.localPlayerId,
    this.errorMessage,
    this.isZoneHost = false,
  });

  factory MultiplayerState.initial() => const MultiplayerState(
        status: MultiplayerStatus.disconnected,
        players: {},
        playerName: 'Jugador',
      );

  MultiplayerState copyWith({
    MultiplayerStatus? status,
    Map<String, RemotePlayer>? players,
    String? errorMessage,
    String? localPlayerId,
    bool? isZoneHost,
    String? playerName,
    bool clearError = false,
    bool clearLocalId = false,
  }) =>
      MultiplayerState(
        status: status ?? this.status,
        players: players ?? this.players,
        localPlayerId: clearLocalId ? null : (localPlayerId ?? this.localPlayerId),
        isZoneHost: isZoneHost ?? this.isZoneHost,
        playerName: playerName ?? this.playerName,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  bool get isConnected => status == MultiplayerStatus.connected;
}

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  MultiplayerNotifier() : super(MultiplayerState.initial());

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  // ── Conexión ───────────────────────────────────────────────────────
  Future<void> connect({String playerName = 'Jugador'}) async {
    if (state.isConnected || state.status == MultiplayerStatus.connecting) {
      return;
    }

    state = state.copyWith(
      status: MultiplayerStatus.connecting,
      playerName: playerName,
      players: const {},
      clearError: true,
      clearLocalId: true,
      isZoneHost: false,
    );
    AppLogger.log.i('Multiplayer: conectando a $kMultiplayerServerUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(kMultiplayerServerUrl));
      await _channel!.ready;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      state = state.copyWith(status: MultiplayerStatus.connected);
      AppLogger.log.i('Multiplayer: conexión establecida');
      // No enviamos nada aún: el server nos manda SESSION_INIT y ROLE_UPDATE
      // antes de que tengamos posición. La primera emisión PLAYER_UPDATE
      // sale desde WorldMapScreen al montarse el mapa (ver cambio 2).
    } catch (e) {
      AppLogger.log.e('Multiplayer: error al conectar', error: e);
      state = state.copyWith(
        status: MultiplayerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Envío de posición ──────────────────────────────────────────────
  /// Se llama desde WorldMapScreen en cada cambio de playerMovementProvider
  /// y una vez en initState. El server usa el primer PLAYER_UPDATE como
  /// registro del jugador; sin esa emisión nadie nos ve.
  void broadcastMovement(LatLng pos) {
    if (!state.isConnected) return;
    _sendJson({
      'type': 'PLAYER_UPDATE',
      // Convención: x = longitud, y = latitud (cartesiano estándar).
      // El server.js usa HOST_RADIUS = 0.004 en ambas dimensiones, lo que
      // equivale a ~444m en lat y ~420m en lon a 19.5°. Consistente con
      // su comentario de "aproximadamente 400 metros".
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
          final sessionId = data['sessionId'] as String?;
          if (sessionId == null) return;
          state = state.copyWith(localPlayerId: sessionId);
          AppLogger.log.i('Multiplayer: SESSION_INIT id=$sessionId');

        case 'ROLE_UPDATE':
          final isHost = data['isZoneHost'] as bool? ?? false;
          state = state.copyWith(isZoneHost: isHost);
          AppLogger.log.d('Multiplayer: ROLE_UPDATE isHost=$isHost');

        case 'DISCONNECT':
          final id = data['id'] as String?;
          if (id != null) {
            final updated = Map<String, RemotePlayer>.from(state.players)
              ..remove(id);
            state = state.copyWith(players: updated);
            AppLogger.log.i('Multiplayer: jugador salió $id');
          }
          // El campo `orphanedNpcs` se ignora: los NPCs se simulan
          // localmente en cada cliente.

        case 'PLAYER_UPDATE':
        case null:
          // Posición de OTRO jugador (el server reenvía PLAYER_UPDATE
          // con `id` agregado, conservando o no el `type` original).
          _handleRemotePlayerUpdate(data);

        case 'SYNC_ALL_NPCS':
        case 'NPC_SPAWN':
        case 'NPC_UPDATE':
        case 'NPC_BATCH_UPDATE':
        case 'NPC_DESTROY':
        case 'MASTER_SYNC_CHECK':
        case 'PLAYER_DAMAGE':
          // No implementado todavía en Flutter.
          break;

        default:
          AppLogger.log.d('Multiplayer: tipo desconocido $type');
      }
    } catch (e) {
      AppLogger.log.w('Multiplayer: no se pudo parsear: $e');
    }
  }

  void _handleRemotePlayerUpdate(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    if (id == null || id == state.localPlayerId) return;
    final x = (data['x'] as num?)?.toDouble();
    final y = (data['y'] as num?)?.toDouble();
    if (x == null || y == null) return;
    final name = data['displayName'] as String? ?? 'Jugador';

    final pos = LatLng(y, x); // y=lat, x=lon (inverso del envío).
    final updated = Map<String, RemotePlayer>.from(state.players);
    final existing = updated[id];
    if (existing == null) {
      updated[id] = RemotePlayer(id: id, position: pos, name: name);
      AppLogger.log.i('Multiplayer: nuevo remoto $id ($name)');
    } else {
      updated[id] = existing.copyWith(position: pos, name: name);
    }
    state = state.copyWith(players: updated);
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
        clearLocalId: true,
      );
    }
  }

  void _sendJson(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      AppLogger.log.w('Multiplayer: no se pudo enviar: $e');
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