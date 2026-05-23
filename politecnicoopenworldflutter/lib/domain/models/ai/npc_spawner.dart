import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../geo_location.dart';
import '../map_way.dart';
import '../npc.dart';
import '../npc_enums.dart';

class NpcSpawnPlan {
  final List<Npc> toSpawn;
  final List<String> toDespawnIds;
  const NpcSpawnPlan({required this.toSpawn, required this.toDespawnIds});
}

class NpcSpawner {
  static const double _spawnRadiusMeters = 800;
  static const double _despawnRadiusMeters = 1700;
  static const int _hardCap = 300;

  static const double _personSpeed = 1.4;
  static const double _carSpeed = 9.0;

  static const List<int> _carColors = [
    0xFFE53935, 0xFF1E88E5, 0xFF43A047, 0xFFFDD835,
    0xFF8E24AA, 0xFFFFFFFF, 0xFF424242, 0xFF6D4C41,
  ];

  static const Distance _dist = Distance();
  static const double _nearbyWaysRefreshDistanceMeters = 60;
  static const double _nearbyWaysRefreshViewportDeltaMeters = 30;
  final Random _random;
  LatLng? _lastNearbyCenter;
  double? _lastNearbyViewportRadius;
  List<MapWay>? _lastWaysRef;
  List<MapWay> _cachedNearbyWays = const [];

  NpcSpawner({Random? random}) : _random = random ?? Random();

  bool _shouldRefreshNearbyWays(
    List<MapWay> ways,
    LatLng playerPos,
    double viewportRadiusMeters,
  ) {
    if (_lastNearbyCenter == null ||
        _lastNearbyViewportRadius == null ||
        !identical(_lastWaysRef, ways)) {
      return true;
    }
    final movedMeters = _dist(_lastNearbyCenter!, playerPos);
    final viewportDelta =
        (_lastNearbyViewportRadius! - viewportRadiusMeters).abs();
    return movedMeters >= _nearbyWaysRefreshDistanceMeters ||
        viewportDelta >= _nearbyWaysRefreshViewportDeltaMeters;
  }

  List<MapWay> _getNearbyWays(
    List<MapWay> ways,
    LatLng playerPos,
    double viewportRadiusMeters,
  ) {
    if (_shouldRefreshNearbyWays(ways, playerPos, viewportRadiusMeters)) {
      final nearby = <MapWay>[];
      for (final w in ways) {
        if (w.nodes.length < 2) continue;
        if (_wayMinDistance(w, playerPos) <= _spawnRadiusMeters) {
          nearby.add(w);
        }
      }
      _cachedNearbyWays = nearby;
      _lastNearbyCenter = playerPos;
      _lastNearbyViewportRadius = viewportRadiusMeters;
      _lastWaysRef = ways;
    }
    return _cachedNearbyWays;
  }

  /// Distancia mínima entre el jugador y cualquier nodo de la way.
  double _wayMinDistance(MapWay w, LatLng playerPos) {
    var best = double.infinity;
    for (final n in w.nodes) {
      final d = _dist(LatLng(n.lat, n.lon), playerPos);
      if (d < best) best = d;
      if (best == 0) return 0;
    }
    return best;
  }

  NpcSpawnPlan plan({
    required List<Npc> current,
    required List<MapWay> ways,
    required LatLng playerPos,
    required int desiredCount,
    // Limita el spawn a un área específica, puedes usar esto.
    double viewportRadiusMeters = 0,
  }) {
    final effectiveDespawnRadiusMeters = viewportRadiusMeters > 0
        ? max(viewportRadiusMeters, _spawnRadiusMeters)
        : _despawnRadiusMeters;

    final toDespawn = <String>[];
    for (final npc in current) {
      final pos = LatLng(npc.location.latitude, npc.location.longitude);
      if (_dist(pos, playerPos) > effectiveDespawnRadiusMeters) {
        toDespawn.add(npc.id);
      }
    }

    final aliveAfter = current.length - toDespawn.length;
    final cap = desiredCount.clamp(0, _hardCap).toInt();
    final needed = (cap - aliveAfter).clamp(0, _hardCap).toInt();
    if (needed == 0 || ways.isEmpty) {
      return NpcSpawnPlan(toSpawn: const [], toDespawnIds: toDespawn);
    }

    final nearby = _getNearbyWays(ways, playerPos, viewportRadiusMeters);
    if (nearby.isEmpty) {
      return NpcSpawnPlan(toSpawn: const [], toDespawnIds: toDespawn);
    }

    final toSpawn = <Npc>[];
    for (int i = 0; i < needed; i++) {
      final way = nearby[_random.nextInt(nearby.length)];
      final wantsCar = _random.nextDouble() < 0.25;
      final type =
          (wantsCar && way.isForCars) ? NpcType.car : NpcType.person;

      final startIdx = _random.nextInt(way.nodes.length - 1);
      final startNode = way.nodes[startIdx];

      toSpawn.add(Npc(
        type: type,
        location:
            GeoLocation(latitude: startNode.lat, longitude: startNode.lon),
        speed: type == NpcType.car ? _carSpeed : _personSpeed,
        currentWay: way,
        targetNodeIndex: startIdx + 1,
        moveDirection: 1,
        carColor: type == NpcType.car
            ? _carColors[_random.nextInt(_carColors.length)]
            : 0xFFFFFFFF,
        carModel: CarModel.values[_random.nextInt(CarModel.values.length)],
      ));
    }

    return NpcSpawnPlan(toSpawn: toSpawn, toDespawnIds: toDespawn);
  }
}