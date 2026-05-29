import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../core/utils/app_logger.dart';
import '../domain/models/npc.dart';
import '../features/map_exterior/state/player_health_notifier.dart';

const double kMultiplayerMapRadiusMeters = 30000;
const String kDefaultMultiplayerServerUrl =
    'wss://politecnicoopenworldflutter.onrender.com/flutter';

final multiplayerServerUrlProvider =
    StateProvider<String>((ref) => kDefaultMultiplayerServerUrl);

// ── Modelos ──────────────────────────────────────────────────────────

class RemotePlayer {
  final String id;
  final LatLng position;
  final String displayName;
  final bool isHost;
  final bool isDriving;
  final String action;
  final bool facingRight;
  final double health;

  const RemotePlayer({
    required this.id,
    required this.position,
    required this.displayName,
    this.isHost = false,
    this.isDriving = false,
    this.action = 'idle',
    this.facingRight = true,
    this.health = 100,
  });

  RemotePlayer copyWith({
    LatLng? position,
    String? displayName,
    bool? isHost,
    bool? isDriving,
    String? action,
    bool? facingRight,
    double? health,
  }) =>
      RemotePlayer(
        id: id,
        position: position ?? this.position,
        displayName: displayName ?? this.displayName,
        isHost: isHost ?? this.isHost,
        isDriving: isDriving ?? this.isDriving,
        action: action ?? this.action,
        facingRight: facingRight ?? this.facingRight,
        health: health ?? this.health,
      );
}

class RemoteNpc {
  final String id;
  final LatLng position;
  final String type;
  final double rotation;
  final double speed;
  final int carColor;
  final String carModel;
  final String? ownerId;

  const RemoteNpc({
    required this.id,
    required this.position,
    required this.type,
    this.rotation = 0,
    this.speed = 0,
    this.carColor = 0xFFFFFFFF,
    this.carModel = 'sedan',
    this.ownerId,
  });
}

// ── Estado ───────────────────────────────────────────────────────────

enum MultiplayerStatus { disconnected, connecting, connected, error }

class MultiplayerState {
  final MultiplayerStatus status;
  final Map<String, RemotePlayer> players;
  final Map<String, RemoteNpc> remoteNpcs;
  final String? errorMessage;
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
        playerName: '',
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

// ── Notifier ─────────────────────────────────────────────────────────

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  final Ref _ref;
  MultiplayerNotifier(this._ref) : super(MultiplayerState.initial());

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  /// Keepalive cada 20 s para evitar el timeout de 30 s de Render Free.
  Timer? _keepaliveTimer;

  String _lastAction = 'idle';
  bool _lastFacingRight = true;
  bool _lastIsDriving = false;

  // ── Warmup HTTP ─────────────────────────────────────────────────────
  /// Render Free duerme el proceso tras inactividad. Un GET al /status
  /// lo despierta. Esperamos hasta que responda antes de abrir el WS.
  Future<void> _warmupServer(String serverUrl) async {
    final httpUrl = serverUrl
        .replaceFirst('wss://', 'https://')
        .replaceFirst('ws://', 'http://')
        .replaceFirst('/flutter', '/status');

    AppLogger.log.i('Multiplayer: warmup -> $httpUrl');

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 12);

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final request = await client.getUrl(Uri.parse(httpUrl));
        final response = await request.close();
        await response.drain<void>();
        if (response.statusCode == 200) {
          AppLogger.log.i('Multiplayer: servidor activo (warmup OK)');
          break;
        }
      } catch (e) {
        AppLogger.log.d('Multiplayer: warmup intento $attempt: $e');
        if (attempt < 3) {
          await Future<void>.delayed(const Duration(seconds: 5));
        }
      }
    }
    client.close();
  }

  // ── Conexión ────────────────────────────────────────────────────────

  Future<void> connect({
    required String serverUrl,
    String playerName = '',
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
    AppLogger.log.i('Multiplayer: conectando a $serverUrl como "$playerName"');

    try {
      // 1. Despertar Render antes de abrir el WebSocket.
      await _warmupServer(serverUrl);

      // 2. Abrir WebSocket. pingInterval mantiene el socket vivo a nivel
      //    de protocolo WS; el keepalive JSON cubre la capa de Render.
      _channel = IOWebSocketChannel.connect(
        Uri.parse(serverUrl),
        pingInterval: const Duration(seconds: 20),
      );

      await _channel!.ready;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // 3. Keepalive JSON cada 20 s.
      _keepaliveTimer?.cancel();
      _keepaliveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (state.isConnected) {
          _sendJson({'type': 'PING'});
        }
      });

      if (!mounted) return;
      state = state.copyWith(status: MultiplayerStatus.connected);
      AppLogger.log.i('Multiplayer: conexion establecida');
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

  void broadcastMovement(
    LatLng pos, {
    String action = 'walk',
    bool facingRight = true,
    bool isDriving = false,
  }) {
    if (!state.isConnected) return;
    _lastAction = action;
    _lastFacingRight = facingRight;
    _lastIsDriving = isDriving;
    _sendJson({
      'type': 'PLAYER_UPDATE',
      'x': pos.longitude,
      'y': pos.latitude,
      'displayName': state.playerName.isNotEmpty
          ? state.playerName
          : 'Jugador Flutter',
      'action': action,
      'facingRight': facingRight,
      'isDriving': isDriving,
      'health': _ref.read(playerHealthProvider).health,
    });
  }

  void broadcastNpcs(List<Npc> localNpcs) {
    if (!state.isConnected || !state.isZoneHost) return;
    final myId = state.sessionId;
    final npcList = localNpcs.map((npc) => {
          'id': npc.id,
          'x': npc.location.longitude,
          'y': npc.location.latitude,
          'type': npc.type.name,
          'rotation': npc.rotationAngle,
          'speed': npc.speed,
          'carColor': npc.carColor,
          'carModel': npc.carModel.name,
          'ownerId': myId,
        }).toList();
    _sendJson({'type': 'NPC_BATCH_UPDATE', 'npcs': npcList});
  }

  void sendPlayerDamage(String targetId, double damage) {
    if (!state.isConnected) return;
    _sendJson({'type': 'PLAYER_DAMAGE', 'targetId': targetId, 'damage': damage});
  }

  void disconnect() {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close(1000);
    _channel = null;
    if (mounted) {
      state = MultiplayerState.initial().copyWith(playerName: state.playerName);
    }
    AppLogger.log.i('Multiplayer: desconectado');
  }

  // ── Mensajes entrantes ───────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'PING':
        case 'PONG':
          break; // silencio

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
          _handleDisconnect(data);

        case 'SYNC_ALL_NPCS':
          _handleSyncAllNpcs(data);

        case 'NPC_SPAWN':
        case 'NPC_UPDATE':
          _handleSingleNpc(data);

        case 'NPC_BATCH_UPDATE':
          _handleBatchNpcs(data);

        case 'NPC_DESTROY':
          _handleNpcDestroy(data);

        case 'PLAYER_UPDATE':
        case null:
          _handleRemotePlayerUpdate(data);

        case 'MASTER_SYNC_CHECK':
          _handleMasterSyncCheck(data);

        case 'PLAYER_DAMAGE':
          _handlePlayerDamage(data);

        default:
          AppLogger.log.d('Multiplayer: tipo desconocido "$type"');
      }
    } catch (e) {
      AppLogger.log.w('Multiplayer: parse error: $e');
    }
  }

  void _handleDisconnect(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final orphans = data['orphanedNpcs'];
    var players = state.players;
    var npcs = state.remoteNpcs;

    if (id != null && players.containsKey(id)) {
      players = Map.from(players)..remove(id);
      AppLogger.log.i('Multiplayer: salio $id');
    }
    if (orphans is List) {
      npcs = Map.from(npcs);
      for (final o in orphans) {
        if (o is String) (npcs as Map).remove(o);
      }
    }
    state = state.copyWith(players: players, remoteNpcs: npcs);
  }

  void _handleSyncAllNpcs(Map<String, dynamic> data) {
    final list = data['npcs'];
    if (list is! List) return;
    final myId = state.sessionId;
    final npcs = <String, RemoteNpc>{};
    for (final n in list) {
      if (n is! Map) continue;
      final parsed = _parseNpc(Map<String, dynamic>.from(n));
      if (parsed == null || parsed.ownerId == myId) continue;
      npcs[parsed.id] = parsed;
    }
    state = state.copyWith(remoteNpcs: npcs);
  }

  void _handleSingleNpc(Map<String, dynamic> data) {
    final n = data['npc'];
    if (n is! Map) return;
    final parsed = _parseNpc(Map<String, dynamic>.from(n));
    if (parsed == null || parsed.ownerId == state.sessionId) return;
    final npcs = Map<String, RemoteNpc>.from(state.remoteNpcs)..[parsed.id] = parsed;
    state = state.copyWith(remoteNpcs: npcs);
  }

  void _handleBatchNpcs(Map<String, dynamic> data) {
    final list = data['npcs'];
    if (list is! List) return;
    final myId = state.sessionId;
    final npcs = Map<String, RemoteNpc>.from(state.remoteNpcs);
    final incoming = <String>{};
    String? batchOwner;

    for (final n in list) {
      if (n is! Map) continue;
      final parsed = _parseNpc(Map<String, dynamic>.from(n));
      if (parsed == null || parsed.ownerId == myId) continue;
      batchOwner ??= parsed.ownerId;
      npcs[parsed.id] = parsed;
      incoming.add(parsed.id);
    }
    if (batchOwner != null) {
      npcs.removeWhere((id, n) => n.ownerId == batchOwner && !incoming.contains(id));
    }
    state = state.copyWith(remoteNpcs: npcs);
  }

  void _handleNpcDestroy(Map<String, dynamic> data) {
    final id = data['npcId'] as String?;
    if (id != null && state.remoteNpcs.containsKey(id)) {
      final npcs = Map<String, RemoteNpc>.from(state.remoteNpcs)..remove(id);
      state = state.copyWith(remoteNpcs: npcs);
    }
  }

  void _handleRemotePlayerUpdate(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    if (id == null || id == state.sessionId) return;
    final x = (data['x'] as num?)?.toDouble();
    final y = (data['y'] as num?)?.toDouble();
    if (x == null || y == null) return;

    final pos = LatLng(y, x);
    final updated = Map<String, RemotePlayer>.from(state.players);
    final existing = updated[id];
    final displayName = data['displayName'] as String? ?? 'Jugador';
    final isHost = data['isHost'] as bool? ?? false;
    final isDriving = data['isDriving'] as bool? ?? false;
    final action = data['action'] as String? ?? 'idle';
    final facingRight = data['facingRight'] as bool? ?? true;
    final health = (data['health'] as num?)?.toDouble() ?? 100;

    if (existing == null) {
      updated[id] = RemotePlayer(
        id: id, position: pos, displayName: displayName,
        isHost: isHost, isDriving: isDriving,
        action: action, facingRight: facingRight, health: health,
      );
      AppLogger.log.i('Multiplayer: nuevo remoto $id ($displayName)');
    } else {
      updated[id] = existing.copyWith(
        position: pos, displayName: displayName, isHost: isHost,
        isDriving: isDriving, action: action,
        facingRight: facingRight, health: health,
      );
    }
    state = state.copyWith(players: updated);
  }

  void _handleMasterSyncCheck(Map<String, dynamic> data) {
    final ids = data['activeNpcIds'];
    if (ids is! List) return;
    final official = ids.whereType<String>().toSet();
    final filtered = Map.fromEntries(
      state.remoteNpcs.entries.where((e) => official.contains(e.key)),
    );
    if (filtered.length != state.remoteNpcs.length) {
      state = state.copyWith(remoteNpcs: filtered);
    }
  }

  void _handlePlayerDamage(Map<String, dynamic> data) {
    final targetId = data['targetId'] as String?;
    if (targetId == null || targetId != state.sessionId) return;
    final damage = (data['damage'] as num?)?.toDouble() ?? 0;
    if (damage <= 0) return;
    _ref.read(playerHealthProvider.notifier).takeDamage(damage);
    AppLogger.log.i('Multiplayer: recibi dano $damage');
  }

  RemoteNpc? _parseNpc(Map<String, dynamic> data) {
    final id = data['id'];
    if (id is! String) return null;
    final x = (data['x'] as num?)?.toDouble();
    final y = (data['y'] as num?)?.toDouble();
    if (x == null || y == null) return null;
    return RemoteNpc(
      id: id,
      position: LatLng(y, x),
      type: (data['type'] as String?) ?? 'person',
      rotation: (data['rotation'] as num?)?.toDouble() ?? 0.0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0.0,
      carColor: (data['carColor'] as int?) ?? 0xFFFFFFFF,
      carModel: (data['carModel'] as String?) ?? 'sedan',
      ownerId: data['ownerId'] as String?,
    );
  }

  void _onError(Object e) {
    AppLogger.log.e('Multiplayer: error de stream', error: e);
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
    if (mounted) {
      state = state.copyWith(
        status: MultiplayerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _onDone() {
    AppLogger.log.i('Multiplayer: stream cerrado');
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
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
    _keepaliveTimer?.cancel();
    disconnect();
    super.dispose();
  }
}

final multiplayerProvider =
    StateNotifierProvider<MultiplayerNotifier, MultiplayerState>(
  (ref) => MultiplayerNotifier(ref),
);
