import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../geo_location.dart';
import '../map_way.dart';
import '../npc.dart';
import '../npc_enums.dart';

/// Motor de movimiento puro: a partir de un [Npc] y un delta temporal,
/// devuelve un nuevo [Npc] avanzado. No mantiene estado interno.
///
/// Lógica básica por paso:
///  1. Avanzar hacia el nodo objetivo dentro de la way actual.
///  2. Si se alcanza el nodo, saltar al siguiente según [moveDirection].
///  3. Si se acaba la way, intentar saltar a otra way conectada (mismo nodo
///     en el extremo); si no hay conexión, invertir la dirección.
class NpcMovementEngine {
  static const Distance _dist = Distance();

  /// Avanza un NPC un paso de simulación. [allWays] se usa sólo para
  /// resolver continuaciones cuando llega al final de su way.
  static Npc step(
    Npc npc,
    double dtSeconds,
    List<MapWay> allWays,
    Random random,
  ) {
    final way = npc.currentWay;
    if (way == null || way.nodes.length < 2 || dtSeconds <= 0) return npc;

    var working = npc;
    var remaining = working.speed * dtSeconds;

    // Permitimos cruzar hasta 4 nodos por tick para deltas largos.
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
          location: GeoLocation(latitude: target.lat, longitude: target.lon),
        );
        working = _advanceToNextNode(working, w, allWays, random);
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

  static Npc _advanceToNextNode(
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

    // Callejón sin salida: media vuelta.
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

    final candidates = <MapWay>[];
    for (final w in allWays) {
      if (w.id == current.id) continue;
      if (w.nodes.length < 2) continue;
    // Los coches sólo pueden continuar por ways de coches.
    // Las personas sólo pueden continuar por ways peatonales.
      if (npcType == NpcType.car && !w.isForCars) continue;
      if (npcType == NpcType.person && !w.isForPeople) continue;
      if (w.nodes.any((n) => n.id == pivotNodeId)) {
        candidates.add(w);
      }
    }
    if (candidates.isEmpty) return null;

    final chosen = candidates[random.nextInt(candidates.length)];
    final pivotIdx = chosen.nodes.indexWhere((n) => n.id == pivotNodeId);
    if (pivotIdx == -1) return null;

    final newDirection = pivotIdx == 0 ? 1 : -1;
    final initialTarget = pivotIdx + newDirection;
    if (initialTarget < 0 || initialTarget >= chosen.nodes.length) {
      return null;
    }
    return _Connection(
      way: chosen,
      initialTargetIndex: initialTarget,
      direction: newDirection,
    );
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