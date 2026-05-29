// lib/features/map_exterior/state/npc_notifier.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/models/ai/npc_ai_coordinator.dart';
import '../../../domain/models/npc.dart';
import '../../../domain/models/geo_location.dart';
import '../../../domain/models/npc_enums.dart';
import 'camera_providers.dart';
import 'map_providers.dart';
import 'player_movement_notifier.dart';

/// Tres modos en los que puede operar el notifier:
///   - offline:    no hay sesión multijugador, corre IA local.
///   - host:       conectado y soy Host de zona; simulo NPCs y los
///                 transmito al servidor cada N ticks.
///   - client:     conectado pero NO soy Host; mi lista de NPCs es
///                 espejo del estado remoto, sin IA local.
enum _NpcMode { offline, host, client }

class NpcNotifier extends StateNotifier<List<Npc>> {
  final Ref _ref;
  final NpcAiCoordinator _coordinator;

  Timer? _ticker;
  DateTime _lastTick = DateTime.now();
  int _tickCounter = 0;
  int _lastReportedCount = -1;
  _NpcMode _lastMode = _NpcMode.offline;

  static const int _broadcastEveryNTicks = 3;
  static const Duration _tickInterval = Duration(milliseconds: 33);

  NpcNotifier(this._ref, this._coordinator) : super(const []);

  void start() {
    if (_ticker != null) return;
    _coordinator.clear();
    if (mounted) state = const [];
    _lastTick = DateTime.now();
    _tickCounter = 0;
    _lastReportedCount = -1;
    _lastMode = _NpcMode.offline;
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
    AppLogger.log.i('NpcNotifier: bucle iniciado');
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _coordinator.clear();
    AppLogger.log.i('NpcNotifier: bucle detenido');
  }

  void pause() {
    if (_ticker == null) return;
    _ticker?.cancel();
    _ticker = null;
    AppLogger.log.d('NpcNotifier: bucle pausado');
  }

  void resume() {
    if (_ticker != null) return;
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
    AppLogger.log.d('NpcNotifier: bucle reanudado');
  }

  void setDesiredCount(int count) {
    _coordinator.setDesiredCount(count);
  }

  void _onTick() {
    if (!mounted) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    try {
      _tick();
    } catch (e) {
      AppLogger.log.w('NpcNotifier: error en tick ignorado: $e');
    }
  }

  void _tick() {
    final mode = _detectMode();
    if (mode != _lastMode) {
      _onModeChanged(_lastMode, mode);
      _lastMode = mode;
    }

    switch (mode) {
      case _NpcMode.host:
        _runLocalAiLogic();
        _tickCounter++;
        if (_tickCounter % _broadcastEveryNTicks == 0) {
          try {
            _ref.read(multiplayerProvider.notifier).broadcastNpcs(state);
          } catch (_) {}
        }
      case _NpcMode.client:
        _syncFromRemoteNpcs();
      case _NpcMode.offline:
        _runLocalAiLogic();
        _tickCounter++;
    }
  }

  _NpcMode _detectMode() {
    MultiplayerState? mp;
    try {
      mp = _ref.read(multiplayerProvider);
    } catch (_) {
      mp = null;
    }
    if (mp == null || !mp.isConnected) return _NpcMode.offline;
    return mp.isZoneHost ? _NpcMode.host : _NpcMode.client;
  }

  /// Transiciones limpias para evitar fantasmas al cambiar de modo:
  ///   host  → client : dejé de ser Host (otro me ganó). Mis NPCs locales
  ///                    ya no me pertenecen; me los reenviará el otro Host
  ///                    o el GC del servidor los borrará. Aquí solo dejo
  ///                    de simular.
  ///   client → host  : me promovieron a Host. Empiezo a simular desde
  ///                    cero alrededor del jugador (el coordinator hace
  ///                    el spawn inicial en el primer tick).
  ///   * → offline    : me desconecté. Reseteo todo y arranco singleplayer
  ///                    con el coordinator limpio.
  ///   offline → *    : me conecté. Tiro lo local y dejo que el servidor
  ///                    dicte el estado mientras se decide mi rol.
  void _onModeChanged(_NpcMode prev, _NpcMode next) {
    AppLogger.log.i('NpcNotifier: modo $prev → $next');
    _coordinator.clear();
    _tickCounter = 0;
    if (mounted) state = const [];
  }

  /// Cliente puro: convierte el estado remoto del servidor en Npc
  /// locales para que la capa de marcadores los dibuje. No corre IA.
  void _syncFromRemoteNpcs() {
    final mp = _ref.read(multiplayerProvider);
    final remoteNpcs = mp.remoteNpcs;
    if (remoteNpcs.isEmpty) {
      if (state.isNotEmpty) state = const [];
      return;
    }

    final synced = remoteNpcs.values.map((remote) {
      final model = CarModel.values.firstWhere(
        (m) => m.name == remote.carModel,
        orElse: () => CarModel.sedan,
      );
      return Npc(
        id: remote.id,
        type: remote.type == 'car' ? NpcType.car : NpcType.person,
        location: GeoLocation(
          latitude: remote.position.latitude,
          longitude: remote.position.longitude,
        ),
        rotationAngle: remote.rotation,
        speed: remote.speed,
        carColor: remote.carColor,
        carModel: model,
      );
    }).toList();

    state = synced;
  }

  /// Host u offline: corre la simulación local.
  void _runLocalAiLogic() {
    final ways = _ref.read(mapStateProvider).ways;
    if (ways.isEmpty) return;

    _coordinator.setWays(ways);

    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMicroseconds / 1e6;
    _lastTick = now;

    final safeDt = dt.clamp(0.0, 0.1);
    final playerPos = _ref.read(playerMovementProvider).position;
    final viewportRadius = _ref.read(viewportRadiusProvider);

    final updated = _coordinator.tick(safeDt, playerPos, viewportRadius);
    state = updated;

    if (_tickCounter % 30 == 0) {
      AppLogger.log.d(
        'NpcNotifier: ways=${ways.length} npcs=${updated.length} '
        'dt=${safeDt.toStringAsFixed(3)}s',
      );
    }

    if (updated.length != _lastReportedCount) {
      AppLogger.log.i('NPC count: $_lastReportedCount → ${updated.length}');
      _lastReportedCount = updated.length;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final npcCoordinatorProvider = Provider<NpcAiCoordinator>((ref) {
  return NpcAiCoordinator();
});

final npcNotifierProvider =
    StateNotifierProvider<NpcNotifier, List<Npc>>((ref) {
  return NpcNotifier(ref, ref.read(npcCoordinatorProvider));
});