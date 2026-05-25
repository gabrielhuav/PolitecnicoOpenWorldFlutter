import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/models/ai/npc_ai_coordinator.dart';
import '../../../domain/models/npc.dart';
import '../../../Multiplayer/multiplayer_notifier.dart';
import 'camera_providers.dart';
import 'map_providers.dart';
import 'player_movement_notifier.dart';

class NpcNotifier extends StateNotifier<List<Npc>> {
  final Ref _ref;
  final NpcAiCoordinator _coordinator;

  Timer? _ticker;
  DateTime _lastTick = DateTime.now();
  int _tickCounter = 0;
  int _lastReportedCount = -1;

  /// Cada cuántos ticks se hace broadcast al servidor.
  /// Con _tickInterval = 33ms, cada 3 ticks = ~100ms = 10 veces por segundo.
  /// Suficiente para que el cliente vea movimiento fluido sin saturar la red.
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
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
    AppLogger.log.i(
        'NpcNotifier: bucle iniciado (${_tickInterval.inMilliseconds}ms)');
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _coordinator.clear();
    if (mounted) state = const [];
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
    MultiplayerState? mpState;
    try {
      mpState = _ref.read(multiplayerProvider);
    } catch (_) {
      mpState = null;
    }

    final isConnected = mpState?.isConnected ?? false;
    final isZoneHost = mpState?.isZoneHost ?? false;

    if (isConnected) {
      if (isZoneHost) {
        // HOST: corre la IA local y cada N ticks transmite al servidor.
        _runLocalAiLogic();
        if (_tickCounter % _broadcastEveryNTicks == 0) {
          try {
            _ref.read(multiplayerProvider.notifier).broadcastNpcs(state);
          } catch (_) {}
        }
      } else {
        // CLIENTE: no simula nada localmente; los NPCs vienen como
        // remoteNpcs en multiplayerProvider y NpcMarkerLayer los dibuja.
        if (state.isNotEmpty) state = const [];
      }
    } else {
      // SINGLEPLAYER: IA local normal, sin transmisión.
      _runLocalAiLogic();
    }
  }

  void _runLocalAiLogic() {
    final ways = _ref.read(mapStateProvider).ways;
    if (ways.isEmpty) return;

    _coordinator.setWays(ways);

    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMicroseconds / 1e6;
    _lastTick = now;

    // Acota dt para evitar teleportaciones si la app estuvo en background.
    final safeDt = dt.clamp(0.0, 0.1);

    final playerPos = _ref.read(playerMovementProvider);
    final viewportRadius = _ref.read(viewportRadiusProvider);

    final updated = _coordinator.tick(safeDt, playerPos, viewportRadius);
    state = updated;

    _tickCounter++;

    if (_tickCounter % 30 == 0) {
      AppLogger.log.d(
        'NpcNotifier: ways=${ways.length} npcs=${updated.length} '
        'dt=${safeDt.toStringAsFixed(3)}s',
      );
    }

    if (updated.length != _lastReportedCount) {
      AppLogger.log.i(
        'NPC count: $_lastReportedCount → ${updated.length} '
        '(ways=${ways.length})',
      );
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