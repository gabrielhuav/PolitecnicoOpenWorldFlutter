import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../core/utils/providers.dart';
import '../../domain/ai/npc_ai_coordinator.dart';
import '../../domain/entities/npc.dart';
import 'player_movement_notifier.dart';

class NpcNotifier extends StateNotifier<List<Npc>> {
  final Ref _ref;
  final NpcAiCoordinator _coordinator;

  Timer? _ticker;
  DateTime _lastTick = DateTime.now();
  int _tickCounter = 0;
  int _lastReportedCount = -1;

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
    AppLogger.log.i('NpcNotifier: bucle iniciado (intervalo ${_tickInterval.inMilliseconds}ms)');
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _coordinator.clear();
    if (mounted) state = const [];
    AppLogger.log.i('NpcNotifier: bucle detenido');
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

    final mapProvider = _ref.read(mapStateProvider);
    final ways = mapProvider.ways;
    _coordinator.setWays(ways);

    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMicroseconds / 1e6;
    _lastTick = now;

    final playerPos = _ref.read(playerMovementProvider);
    final updated = _coordinator.tick(dt, playerPos);
    state = updated;

    _tickCounter++;

    // Cada ~1 s (30 ticks) reporta estado general.
    if (_tickCounter % 30 == 0) {
      AppLogger.log.d(
        'NpcNotifier diag: ways=${ways.length} npcs=${updated.length} '
        'pos=(${playerPos.latitude.toStringAsFixed(5)}, '
        '${playerPos.longitude.toStringAsFixed(5)}) dt=${dt.toStringAsFixed(3)}s',
      );
    }

    // Y cuando el conteo cambia, reporta inmediatamente.
    if (updated.length != _lastReportedCount) {
      AppLogger.log.i(
        'NPC count: $_lastReportedCount -> ${updated.length} '
        '(ways disponibles: ${ways.length})',
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