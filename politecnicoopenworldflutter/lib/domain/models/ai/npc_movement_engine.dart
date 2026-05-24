import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../geo_location.dart';
import '../map_way.dart';
import '../npc.dart';
import '../npc_enums.dart';

class NpcMovementEngine {
  static const Distance _dist = Distance();

  /// Avanza un NPC un paso de simulación. Devuelve `null` si el NPC
  /// debe despawnear (coche atascado en oneway sin salida).
  static Npc? step(
    Npc npc,
    double dtSeconds,
    List<MapWay> allWays,
    Random random,
  ) {
    final way = npc.currentWay;
    if (way == null || way.nodes.length < 2 || dtSeconds <= 0) return npc;

    var working = npc;
    var remaining = working.speed * dtSeconds;

    for (int i = 0; i < 4 && remaining > 0; i++) {
      final w = working.currentWay;
      if (w == null || w.nodes.length < 2) break;

      final idx = working.targetNodeIndex.clamp(0, w.nodes.length - 1);
      final target = w.nodes[idx];
      final current = LatLng(
        working.location.latitude,
        working.location.longitude,
      );
      final targetLatLng = LatLng(target.lat, target.lon);
      final distToTarget = _dist(current, targetLatLng);

      if (distToTarget <= remaining) {
        working = working.copyWith(
          location:
              GeoLocation(latitude: target.lat, longitude: target.lon),
        );
        final advanced =
            _advanceToNextNode(working, w, allWays, random);
        if (advanced == null) return null;
        working = advanced;
        remaining -= distToTarget;
      } else {
        final bearing = _dist.bearing(current, targetLatLng);
        final newPos = _dist.offset(current, remaining, bearing);
        working = working.copyWith(
          location: GeoLocation(
            latitude: newPos.latitude,
            longitude: newPos.longitude,
          ),
          rotationAngle: bearing,
        );
        remaining = 0;
      }
    }
    return working;
  }

  static Npc? _advanceToNextNode(
    Npc npc,
    MapWay way,
    List<MapWay> allWays,
    Random random,
  ) {
    final nextIdx = npc.targetNodeIndex + npc.moveDirection;
    if (nextIdx >= 0 && nextIdx < way.nodes.length) {
      return npc.copyWith(targetNodeIndex: nextIdx);
    }

    final atEnd = npc.moveDirection > 0;
    final connection = _findConnectedWay(
      current: way,
      allWays: allWays,
      npcType: npc.type,
      atEnd: atEnd,
      random: random,
    );
    if (connection != null) {
      return npc.copyWith(
        currentWay: connection.way,
        targetNodeIndex: connection.initialTargetIndex,
        moveDirection: connection.direction,
      );
    }

    // Sin conexión: si el coche está en una way oneway, no puede
    // dar media vuelta. Despawn.
    if (npc.type == NpcType.car && way.direction != WayDirection.both) {
      return null;
    }
    // Para todo lo demás (personas o calles de doble sentido), reversa.
    final reversedDirection = -npc.moveDirection;
    final reversedTarget = (npc.targetNodeIndex + reversedDirection)
        .clamp(0, way.nodes.length - 1);
    return npc.copyWith(
      moveDirection: reversedDirection,
      targetNodeIndex: reversedTarget,
      rotationAngle: (npc.rotationAngle + 180) % 360,
    );
  }

  static _Connection? _findConnectedWay({
    required MapWay current,
    required List<MapWay> allWays,
    required NpcType npcType,
    required bool atEnd,
    required Random random,
  }) {
    if (current.nodes.isEmpty) return null;
    final pivotNodeId =
        atEnd ? current.nodes.last.id : current.nodes.first.id;

    final candidates = <_Connection>[];
    for (final w in allWays) {
      if (w.id == current.id) continue;
      if (w.nodes.length < 2) continue;
      if (npcType == NpcType.car && !w.isForCars) continue;
      if (npcType == NpcType.person && !w.isForPeople) continue;

      final pivotIdx = w.nodes.indexWhere((n) => n.id == pivotNodeId);
      if (pivotIdx == -1) continue;

      // Direcciones posibles de entrada por ese pivote:
      //   pivote en nodo 0           → solo dirección +1
      //   pivote en último nodo      → solo dirección -1
      //   pivote intermedio          → ambas
      final possibleDirs = <int>[];
      if (pivotIdx == 0) {
        possibleDirs.add(1);
      } else if (pivotIdx == w.nodes.length - 1) {
        possibleDirs.add(-1);
      } else {
        possibleDirs.addAll([1, -1]);
      }

      for (final dir in possibleDirs) {
        // Coches respetan oneway. Personas no.
        if (npcType == NpcType.car) {
          if (w.direction == WayDirection.forward && dir != 1) continue;
          if (w.direction == WayDirection.backward && dir != -1) continue;
        }
        final initialTarget = pivotIdx + dir;
        if (initialTarget < 0 || initialTarget >= w.nodes.length) continue;
        candidates.add(_Connection(
          way: w,
          initialTargetIndex: initialTarget,
          direction: dir,
        ));
      }
    }
    if (candidates.isEmpty) return null;
    return candidates[random.nextInt(candidates.length)];
  }
}

class _Connection {
  final MapWay way;
  final int initialTargetIndex;
  final int direction;
  const _Connection({
    required this.way,
    required this.initialTargetIndex,
    required this.direction,
  });
}