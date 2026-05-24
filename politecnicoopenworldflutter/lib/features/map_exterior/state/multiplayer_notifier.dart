import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/app_logger.dart';

// ── URL del servidor ────────────────────────────────────────────────
// Cambia esta constante a la IP/dominio de tu servidor WebSocket.
const String kMultiplayerServerUrl = 'ws://10.0.2.2:8080';

// ── Modelo de jugador remoto ────────────────────────────────────────
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

// ── Estado del multiplayer ──────────────────────────────────────────
enum MultiplayerStatus { disconnected, connecting, connected, error }

class MultiplayerState {
  final MultiplayerStatus status;
  final Map<String, RemotePlayer> players;
  final String? errorMessage;
  final String localPlayerId;

  const MultiplayerState({
    required this.status,
    required this.players,
    required this.localPlayerId,
    this.errorMessage,
  });

  factory MultiplayerState.initial() => MultiplayerState(
        status: MultiplayerStatus.disconnected,
        players: const {},
        localPlayerId: const Uuid().v4(),
      );

  MultiplayerState copyWith({
    MultiplayerStatus? status,
    Map<String, RemotePlayer>? players,
    String? errorMessage,
    bool clearError = false,
  }) =>
      MultiplayerState(
        status: status ?? this.status,
        players: players ?? this.players,
        localPlayerId: localPlayerId,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  bool get isConnected => status == MultiplayerStatus.connected;
}

// ── Notifier ────────────────────────────────────────────────────────
class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  MultiplayerNotifier() : super(MultiplayerState.initial());

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _pingTimer;

  /// Conecta al servidor WebSocket. Equivalente al connect() de Android.
  Future<void> connect({String playerName = 'Jugador'}) async {
    if (state.isConnected) return;

    state = state.copyWith(
      status: MultiplayerStatus.connecting,
      clearError: true,
    );
    AppLogger.log.i('Multiplayer: conectando a $kMultiplayerServerUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(kMultiplayerServerUrl));

      // Espera a que el handshake WebSocket termine
      await _channel!.ready;

      state = state.copyWith(status: MultiplayerStatus.connected);
      AppLogger.log.i('Multiplayer: conexión establecida ✅');

      // Notifica al servidor quiénes somos
      _sendJson({
        'type': 'join',
        'id': state.localPlayerId,
        'name': playerName,
      });

      // Escucha mensajes entrantes
      _sub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // Ping cada 25 s (igual que el pingInterval de Android)
      _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
        _sendJson({'type': 'ping', 'id': state.localPlayerId});
      });
    } catch (e) {
      AppLogger.log.e('Multiplayer: error al conectar', error: e);
      state = state.copyWith(
        status: MultiplayerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Envía la posición local al servidor.
  void broadcastMovement(LatLng pos) {
    if (!state.isConnected) return;
    _sendJson({
      'type': 'move',
      'id': state.localPlayerId,
      'lat': pos.latitude,
      'lon': pos.longitude,
    });
  }

  /// Cierra la conexión.
  void disconnect() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close(1000);
    _channel = null;

    if (mounted) {
      state = state.copyWith(
        status: MultiplayerStatus.disconnected,
        players: {},
        clearError: true,
      );
    }
    AppLogger.log.i('Multiplayer: desconectado 🔌');
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'move':
        case 'position':
          final id = data['id'] as String?;
          if (id == null || id == state.localPlayerId) return;
          final lat = (data['lat'] as num?)?.toDouble();
          final lon = (data['lon'] as num?)?.toDouble();
          if (lat == null || lon == null) return;

          final updated = Map<String, RemotePlayer>.from(state.players);
          updated[id] = (updated[id] ?? RemotePlayer(
            id: id,
            position: LatLng(lat, lon),
            name: data['name'] as String? ?? 'Jugador',
          )).copyWith(position: LatLng(lat, lon));
          state = state.copyWith(players: updated);

        case 'join':
          final id = data['id'] as String?;
          if (id == null || id == state.localPlayerId) return;
          final updated = Map<String, RemotePlayer>.from(state.players);
          updated[id] = RemotePlayer(
            id: id,
            position: LatLng(
              (data['lat'] as num?)?.toDouble() ?? 19.5045,
              (data['lon'] as num?)?.toDouble() ?? -99.1465,
            ),
            name: data['name'] as String? ?? 'Jugador',
          );
          state = state.copyWith(players: updated);
          AppLogger.log.i('Multiplayer: jugador unido → $id');

        case 'leave':
          final id = data['id'] as String?;
          if (id == null) return;
          final updated = Map<String, RemotePlayer>.from(state.players)
            ..remove(id);
          state = state.copyWith(players: updated);
          AppLogger.log.i('Multiplayer: jugador salió → $id');

        case 'players':
          // Lista inicial de jugadores al conectar
          final list = data['players'] as List<dynamic>?;
          if (list == null) return;
          final updated = <String, RemotePlayer>{};
          for (final p in list) {
            final m = p as Map<String, dynamic>;
            final id = m['id'] as String?;
            if (id == null || id == state.localPlayerId) continue;
            updated[id] = RemotePlayer(
              id: id,
              position: LatLng(
                (m['lat'] as num?)?.toDouble() ?? 19.5045,
                (m['lon'] as num?)?.toDouble() ?? -99.1465,
              ),
              name: m['name'] as String? ?? 'Jugador',
            );
          }
          state = state.copyWith(players: updated);

        case 'pong':
          break; // solo keepalive

        default:
          AppLogger.log.d('Multiplayer: mensaje desconocido → $type');
      }
    } catch (e) {
      AppLogger.log.w('Multiplayer: error al parsear mensaje: $e');
    }
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
    AppLogger.log.i('Multiplayer: stream cerrado por el servidor');
    _pingTimer?.cancel();
    _pingTimer = null;
    if (mounted) {
      state = state.copyWith(
        status: MultiplayerStatus.disconnected,
        players: {},
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

// ── Provider global ─────────────────────────────────────────────────
final multiplayerProvider =
    StateNotifierProvider<MultiplayerNotifier, MultiplayerState>(
  (ref) => MultiplayerNotifier(),
);