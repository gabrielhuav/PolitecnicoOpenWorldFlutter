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
  /// Radio mínimo de spawn cuando no se conoce el viewport (primer
  /// frame) o cuando el viewport es muy chico. En la práctica el
  /// viewport real (1000-4000m según zoom) suele ser mayor.
  static const double _baseSpawnRadiusMeters = 1000;

  /// El despawn se hace a 1.4x el spawn efectivo, para que los NPCs
  /// no parpadeen entrando y saliendo del cap, y para forzar que los
  /// que quedaron atrás del jugador se eliminen pronto y dejen sitio
  /// a nuevos delante.
  static const double _despawnMultiplier = 1.25;

  static const int _hardCap = 400;
  static const double _personSpeed = 1.4;
  static const double _carSpeed = 9.0;

  static const List<int> _carColors = [
    0xFFE53935, 0xFF1E88E5, 0xFF43A047, 0xFFFDD835,
    0xFF8E24AA, 0xFFFFFFFF, 0xFF424242, 0xFF6D4C41,
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
    final radiusDelta =
        (_lastNearbyRadius! - effectiveSpawnRadius).abs();
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
    // Radio efectivo: lo mayor entre el viewport publicado por la
    // pantalla y el baseline. Si la cámara está muy zoom-in, el
    // baseline gana y garantiza algo de relleno cercano.
    final effectiveSpawnRadius = viewportRadiusMeters > 0
        ? max(viewportRadiusMeters, _baseSpawnRadiusMeters)
        : _baseSpawnRadiusMeters;
    final effectiveDespawnRadius =
        effectiveSpawnRadius * _despawnMultiplier;

    // Marcar para despawn lo que esté fuera del anillo de despawn.
    final toDespawn = <String>[];
    for (final npc in current) {
      final pos = LatLng(npc.location.latitude, npc.location.longitude);
      if (_dist(pos, playerPos) > effectiveDespawnRadius) {
        toDespawn.add(npc.id);
      }
    }

    // El cap (densidad objetivo) aplica SOLO a la zona core, el spawn
    // radius. Los NPCs entre spawn y despawn radius siguen vivos pero
    // no bloquean la creación de nuevos hacia donde mira el jugador.
    // Esto resuelve el síntoma "los NPCs se quedan atrás": cuando
    // avanzas, los rezagados quedan en el anillo de buffer pero el cap
    // se libera y aparecen nuevos delante.
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

    // Particionar ways elegibles por tipo (filtro introducido en PR1).
    final carWays = nearby.where((w) => w.isForCars).toList();
    final peopleWays = nearby.where((w) => w.isForPeople).toList();
    if (carWays.isEmpty && peopleWays.isEmpty) {
      return NpcSpawnPlan(toSpawn: const [], toDespawnIds: toDespawn);
    }

    final toSpawn = <Npc>[];
    for (int i = 0; i < needed; i++) {
      final wantsCar = _random.nextDouble() < 0.25;
      final type = wantsCar
          ? (carWays.isNotEmpty ? NpcType.car : NpcType.person)
          : (peopleWays.isNotEmpty ? NpcType.person : NpcType.car);

      final pool = type == NpcType.car ? carWays : peopleWays;
      if (pool.isEmpty) continue;
      final way = pool[_random.nextInt(pool.length)];

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