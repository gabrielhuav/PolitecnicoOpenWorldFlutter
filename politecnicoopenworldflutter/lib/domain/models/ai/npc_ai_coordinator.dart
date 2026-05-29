import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../map_way.dart';
import '../npc.dart';
import 'npc_movement_engine.dart';
import 'npc_spawner.dart';

/// Único punto de entrada para la simulación. Mantiene la lista viva de
/// NPCs y de ways disponibles. En cada [tick], delega al [NpcSpawner] el
/// nacimiento/muerte y al [NpcMovementEngine] el avance individual.
class NpcAiCoordinator {
  final NpcSpawner _spawner;
  final Random _random;

  List<Npc> _npcs = const [];
  List<MapWay> _ways = const [];
  int _desiredCount = 400;

  NpcAiCoordinator({NpcSpawner? spawner, Random? random})
      : this._(
          spawner: spawner,
          random: random ?? Random(),
        );

  NpcAiCoordinator._({NpcSpawner? spawner, required Random random})
      : _random = random,
        _spawner = spawner ?? NpcSpawner(random: random);

  List<Npc> get npcs => List.unmodifiable(_npcs);

  void setWays(List<MapWay> ways) {
    _ways = ways;
  }

  void setDesiredCount(int count) {
    _desiredCount = count;
  }

  void clear() {
    _npcs = const [];
  }

  /// Avanza la simulación. Devuelve la lista nueva de NPCs.
  List<Npc> tick(
    double dtSeconds,
    LatLng playerPos, [
    double viewportRadiusMeters = 0,
  ]) {
    if (_ways.isEmpty) return _npcs;

    final plan = _spawner.plan(
      current: _npcs,
      ways: _ways,
      playerPos: playerPos,
      desiredCount: _desiredCount,
      viewportRadiusMeters: viewportRadiusMeters,
    );

    final toDespawnIds = plan.toDespawnIds.toSet();
    final updated = <Npc>[];
    for (final npc in _npcs) {
      if (toDespawnIds.contains(npc.id)) continue;
      final stepped = NpcMovementEngine.step(npc, dtSeconds, _ways, _random);
      if (stepped != null) updated.add(stepped);
    }
    updated.addAll(plan.toSpawn);
    
    _npcs = updated;
    return _npcs;
  }
}