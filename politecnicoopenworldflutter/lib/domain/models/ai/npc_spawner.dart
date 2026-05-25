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
  /// Radio mínimo de spawn cuando no se conoce el viewport.
  static const double _baseSpawnRadiusMeters = 1000;

  /// El despawn se hace a 1.25x el spawn efectivo.
  static const double _despawnMultiplier = 1.25;

  /// Tope absoluto.
  static const int _hardCap = 400;

  static const double _personSpeed = 1.4;
  static const double _carSpeed = 9.0;

  /// Probabilidad de intentar spawnear un coche. Se elevó al 30% para
  /// que haya una proporción más visible de vehículos en el mapa.
  /// El spawn real sigue dependiendo de que existan carWays disponibles,
  /// así que en zonas sin calles vehiculares aparecen personas de todas formas.
  static const double _carSpawnChance = 0.30;

  static const List<int> _carColors = [
    0xFFE53935, // rojo
    0xFF1E88E5, // azul
    0xFF43A047, // verde
    0xFFFDD835, // amarillo
    0xFF8E24AA, // morado
    0xFFFFFFFF, // blanco
    0xFF424242, // gris oscuro
    0xFF6D4C41, // marrón
    0xFFFF6F00, // naranja
    0xFF00ACC1, // cian
    0xFF546E7A, // gris azulado
    0xFFAD1457, // rosa oscuro
  ];

  static const Distance _dist = Distance();
  static const double _nearbyWaysRefreshDistanceMeters = 60;
  static const double _nearbyWaysRefreshRadiusDeltaMeters = 30;

  final Random _random;
  LatLng? _lastNearbyCenter;
  double? _lastNearbyRadius;
  List<MapWay>? _lastWaysRef;
  List<MapWay> _cachedNearbyWays = const [];

  NpcSpawner({Random? random}) : _random = random ?? Random();

  bool _shouldRefreshNearbyWays(
    List<MapWay> ways,
    LatLng playerPos,
    double effectiveSpawnRadius,
  ) {
    if (_lastNearbyCenter == null ||
        _lastNearbyRadius == null ||
        !identical(_lastWaysRef, ways)) {
      return true;
    }
    final movedMeters = _dist(_lastNearbyCenter!, playerPos);
    final radiusDelta = (_lastNearbyRadius! - effectiveSpawnRadius).abs();
    return movedMeters >= _nearbyWaysRefreshDistanceMeters ||
        radiusDelta >= _nearbyWaysRefreshRadiusDeltaMeters;
  }

  List<MapWay> _getNearbyWays(
    List<MapWay> ways,
    LatLng playerPos,
    double effectiveSpawnRadius,
  ) {
    if (_shouldRefreshNearbyWays(ways, playerPos, effectiveSpawnRadius)) {
      final nearby = <MapWay>[];
      for (final w in ways) {
        if (w.nodes.length < 2) continue;
        if (_wayMinDistance(w, playerPos) <= effectiveSpawnRadius) {
          nearby.add(w);
        }
      }
      _cachedNearbyWays = nearby;
      _lastNearbyCenter = playerPos;
      _lastNearbyRadius = effectiveSpawnRadius;
      _lastWaysRef = ways;
    }
    return _cachedNearbyWays;
  }

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
    double viewportRadiusMeters = 0,
  }) {
    final effectiveSpawnRadius = viewportRadiusMeters > 0
        ? max(viewportRadiusMeters, _baseSpawnRadiusMeters)
        : _baseSpawnRadiusMeters;
    final effectiveDespawnRadius =
        effectiveSpawnRadius * _despawnMultiplier;

    // Despawn de NPCs fuera del anillo.
    final toDespawn = <String>[];
    for (final npc in current) {
      final pos = LatLng(npc.location.latitude, npc.location.longitude);
      if (_dist(pos, playerPos) > effectiveDespawnRadius) {
        toDespawn.add(npc.id);
      }
    }

    final toDespawnIds = toDespawn.toSet();
    var aliveInSpawnRadius = 0;
    for (final npc in current) {
      if (toDespawnIds.contains(npc.id)) continue;
      final pos = LatLng(npc.location.latitude, npc.location.longitude);
      if (_dist(pos, playerPos) <= effectiveSpawnRadius) {
        aliveInSpawnRadius++;
      }
    }

    final cap = desiredCount.clamp(0, _hardCap).toInt();
    final needed = (cap - aliveInSpawnRadius).clamp(0, _hardCap).toInt();
    if (needed == 0 || ways.isEmpty) {
      return NpcSpawnPlan(toSpawn: const [], toDespawnIds: toDespawn);
    }

    final nearby = _getNearbyWays(ways, playerPos, effectiveSpawnRadius);
    if (nearby.isEmpty) {
      return NpcSpawnPlan(toSpawn: const [], toDespawnIds: toDespawn);
    }

    final carWays = nearby.where((w) => w.isForCars).toList();
    final peopleWays = nearby.where((w) => w.isForPeople).toList();
    if (carWays.isEmpty && peopleWays.isEmpty) {
      return NpcSpawnPlan(toSpawn: const [], toDespawnIds: toDespawn);
    }

    final toSpawn = <Npc>[];
    for (int i = 0; i < needed; i++) {
      // 40% de probabilidad de intentar coche, pero solo si hay carWays.
      // Si no hay carWays, cae a persona (y viceversa para peopleWays).
      final wantsCar = _random.nextDouble() < _carSpawnChance;
      final type = wantsCar
          ? (carWays.isNotEmpty ? NpcType.car : NpcType.person)
          : (peopleWays.isNotEmpty ? NpcType.person : NpcType.car);

      final pool = type == NpcType.car ? carWays : peopleWays;
      if (pool.isEmpty) continue;
      final way = pool[_random.nextInt(pool.length)];

      int initialDirection = 1;
      int initialTargetIndex = 0;
      int startIdx = 0;

      if (type == NpcType.car) {
        switch (way.direction) {
          case WayDirection.forward:
            initialDirection = 1;
            startIdx = _random.nextInt(way.nodes.length - 1);
            initialTargetIndex = startIdx + 1;
            break;
          case WayDirection.backward:
            initialDirection = -1;
            startIdx = 1 + _random.nextInt(way.nodes.length - 1);
            initialTargetIndex = startIdx - 1;
            break;
          case WayDirection.both:
            initialDirection = _random.nextBool() ? 1 : -1;
            if (initialDirection == 1) {
              startIdx = _random.nextInt(way.nodes.length - 1);
              initialTargetIndex = startIdx + 1;
            } else {
              startIdx = 1 + _random.nextInt(way.nodes.length - 1);
              initialTargetIndex = startIdx - 1;
            }
            break;
        }
      } else {
        initialDirection = 1;
        startIdx = _random.nextInt(way.nodes.length - 1);
        initialTargetIndex = startIdx + 1;
      }

      final startNode = way.nodes[startIdx];

      toSpawn.add(Npc(
        type: type,
        location:
            GeoLocation(latitude: startNode.lat, longitude: startNode.lon),
        speed: type == NpcType.car ? _carSpeed : _personSpeed,
        currentWay: way,
        targetNodeIndex: initialTargetIndex,
        moveDirection: initialDirection,
        carColor: type == NpcType.car
            ? _carColors[_random.nextInt(_carColors.length)]
            : 0xFFFFFFFF,
        carModel: CarModel.values[_random.nextInt(CarModel.values.length)],
      ));
    }

    return NpcSpawnPlan(toSpawn: toSpawn, toDespawnIds: toDespawn);
  }
}