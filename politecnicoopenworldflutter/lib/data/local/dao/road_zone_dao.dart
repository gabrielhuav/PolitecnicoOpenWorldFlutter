import 'package:drift/drift.dart';

import '../pow_database.dart';
import '../entity/tables.dart';
import '../../../domain/models/map_node.dart';
import '../../../domain/models/map_way.dart';
import '../../../core/utils/cell_key.dart';

/// Acceso a [RoadZones], [RoadWays] y [RoadNodes].
///
/// Cada celda se identifica por su [cellKey]. Una way completa se
/// asigna a la celda donde cae el centro geométrico de sus nodos, no
/// a la celda donde se ejecutó la descarga: así dos batches solapados
/// no duplican la misma way.
class RoadZoneDao {
  final PowDatabase _db;

  RoadZoneDao(this._db);

  /// Edad de una celda en milisegundos. Si no existe, devuelve null.
  Future<int?> getZoneAgeMs(String cellKey) async {
    final row = await (_db.select(_db.roadZones)
          ..where((t) => t.cellKey.equals(cellKey))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return DateTime.now().millisecondsSinceEpoch - row.timestamp;
  }

  /// Devuelve qué celdas, de la lista pasada, NO están en caché o
  /// están vencidas (edad mayor que [ttlMs]).
  Future<Set<String>> findStaleCells(
    Iterable<String> cellKeys,
    int ttlMs,
  ) async {
    if (cellKeys.isEmpty) return <String>{};
    final rows = await (_db.select(_db.roadZones)
          ..where((t) => t.cellKey.isIn(cellKeys.toList())))
        .get();
    final now = DateTime.now().millisecondsSinceEpoch;
    final freshCells = <String>{};
    for (final r in rows) {
      if (now - r.timestamp <= ttlMs) {
        freshCells.add(r.cellKey);
      }
    }
    return cellKeys.toSet().difference(freshCells);
  }

  /// Lee todas las ways guardadas en las celdas dadas y reconstruye
  /// los objetos de dominio. Devuelve [] si no hay nada.
  Future<List<MapWay>> getWaysForCells(Iterable<String> cellKeys) async {
    if (cellKeys.isEmpty) return const [];
    final wayRows = await (_db.select(_db.roadWays)
          ..where((t) => t.cellKey.isIn(cellKeys.toList())))
        .get();
    if (wayRows.isEmpty) return const [];

    final wayIds = wayRows.map((w) => w.wayId).toList();
    final nodeRows = await (_db.select(_db.roadNodes)
          ..where((t) => t.wayId.isIn(wayIds))
          ..orderBy([
            (t) => OrderingTerm(expression: t.wayId),
            (t) => OrderingTerm(expression: t.sequenceIndex),
          ]))
        .get();

    final nodesByWay = <int, List<MapNode>>{};
    for (final n in nodeRows) {
      nodesByWay.putIfAbsent(n.wayId, () => []).add(
            MapNode(id: n.nodeId, lat: n.lat, lon: n.lon),
          );
    }

    return wayRows
        .map((w) => MapWay(
              id: w.wayId,
              name: null,
              nodes: nodesByWay[w.wayId] ?? const [],
              isForCars: w.isForCars,
              isForPeople: w.isForPeople,
              direction: WayDirection.fromStorage(w.direction),
            ))
        .where((w) => w.nodes.isNotEmpty)
        .toList(growable: false);
  }

  /// Persiste las ways recibidas, asignando cada una a la cellKey de
  /// su centro geométrico. Solo persiste las que caen en alguna
  /// [targetCells]: ways de un batch que se desbordan a celdas fuera
  /// del set objetivo se ignoran (porque le tocan a otro batch o
  /// están fuera del radio).
  ///
  /// Borra cualquier dato previo de las [targetCells] antes de
  /// insertar, asegurando que una re-descarga deje el estado
  /// consistente sin duplicados.
  Future<void> saveBatch({
    required Set<String> targetCells,
    required List<MapWay> ways,
  }) async {
    if (targetCells.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Agrupa las ways por cellKey según su centro.
    final waysByCell = <String, List<MapWay>>{};
    for (final w in ways) {
      if (w.nodes.isEmpty) continue;
      final centerLat =
          w.nodes.map((n) => n.lat).reduce((a, b) => a + b) / w.nodes.length;
      final centerLon =
          w.nodes.map((n) => n.lon).reduce((a, b) => a + b) / w.nodes.length;
      final key = cellKeyFor(centerLat, centerLon);
      if (!targetCells.contains(key)) continue;
      waysByCell.putIfAbsent(key, () => []).add(w);
    }

    await _db.transaction(() async {
      // 1) Borra datos previos de las celdas objetivo.
      final oldWayIds = await (_db.select(_db.roadWays)
            ..where((t) => t.cellKey.isIn(targetCells.toList())))
          .map((r) => r.wayId)
          .get();
      if (oldWayIds.isNotEmpty) {
        await (_db.delete(_db.roadNodes)
              ..where((t) => t.wayId.isIn(oldWayIds)))
            .go();
      }
      await (_db.delete(_db.roadWays)
            ..where((t) => t.cellKey.isIn(targetCells.toList())))
          .go();
      await (_db.delete(_db.roadZones)
            ..where((t) => t.cellKey.isIn(targetCells.toList())))
          .go();

      // 2) Inserta las RoadZones (todas las objetivo, incluso si
      // quedaron sin ways: el TTL las marca como "ya descargadas").
      await _db.batch((batch) {
        batch.insertAll(
          _db.roadZones,
          targetCells.map(
            (k) => RoadZonesCompanion.insert(cellKey: k, timestamp: now),
          ),
        );
      });

      // 3) Inserta RoadWays y RoadNodes.
      final wayRows = <RoadWaysCompanion>[];
      final nodeRows = <RoadNodesCompanion>[];
      for (final entry in waysByCell.entries) {
        for (final w in entry.value) {
          wayRows.add(RoadWaysCompanion.insert(
            wayId: w.id,
            cellKey: entry.key,
            isForCars: w.isForCars,
            isForPeople: w.isForPeople,
            direction: Value(w.direction.storageValue),
          ));
          for (var i = 0; i < w.nodes.length; i++) {
            final n = w.nodes[i];
            nodeRows.add(RoadNodesCompanion.insert(
              nodeId: n.id,
              wayId: w.id,
              lat: n.lat,
              lon: n.lon,
              sequenceIndex: i,
            ));
          }
        }
      }
      if (wayRows.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.roadWays, wayRows,
              mode: InsertMode.insertOrReplace);
        });
      }
      if (nodeRows.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.roadNodes, nodeRows);
        });
      }
    });
  }
}