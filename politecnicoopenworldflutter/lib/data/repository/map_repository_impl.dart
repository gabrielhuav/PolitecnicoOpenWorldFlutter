import 'dart:async';

import '../../core/utils/app_logger.dart';
import '../../core/utils/cell_key.dart';
import '../../domain/models/map_way.dart';
import '../local/dao/road_zone_dao.dart';
import '../network/overpass_repository.dart';

/// Fase del proceso de carga del mapa
enum MapLoadPhase {
  idle,
  cached,
  downloading,
  done,
}

/// Estado intermedio que el repositorio reporta hacia arriba mientras
/// descarga celdas. La UI lo usa para mostrar progreso en la pantalla
/// de carga.
class MapLoadProgress {
  final int totalCells;
  final int cachedCells;
  final int downloadedCells;
  final int currentBatchIndex;
  final int totalBatches;
  final String status;
  final MapLoadPhase phase;

  const MapLoadProgress({
    required this.totalCells,
    required this.cachedCells,
    required this.downloadedCells,
    required this.currentBatchIndex,
    required this.totalBatches,
    required this.status,
    required this.phase,
  });

  double get fraction => totalCells == 0
      ? 0
      : (cachedCells + downloadedCells) / totalCells;

  factory MapLoadProgress.idle() => const MapLoadProgress(
        totalCells: 0,
        cachedCells: 0,
        downloadedCells: 0,
        currentBatchIndex: 0,
        totalBatches: 0,
        status: 'Inicializando...',
        phase: MapLoadPhase.idle,
      );
}

class MapRepository {
  final RoadZoneDao _zoneDao;
  final OverpassRepository _client;

  /// Lado del sub-bloque en celdas. Cada batch a Overpass cubre
  /// [_batchCellsPerSide] x [_batchCellsPerSide] celdas. Con celdas
  /// de 0.005° (~555 m), 6x6 = bbox ~3.3 km de lado.
  static const int _batchCellsPerSide = 6;

  /// Pausa entre batches para no saturar Overpass.
  static const Duration _throttleBetweenBatches = Duration(milliseconds: 1500);

  /// TTL del caché por celda. 7 días.
  static const int _ttlMs = 7 * 24 * 60 * 60 * 1000;

  MapRepository(this._zoneDao, this._client);

  /// Carga las ways necesarias para un radio alrededor de (lat, lon).
  ///
  /// Lee de la caché las celdas vigentes, descarga las faltantes o
  /// vencidas y devuelve la unión. Reporta progreso vía [onProgress].
  Future<List<MapWay>> getRoadsForLocation(
    double lat,
    double lon, {
    double radiusMeters = 5000,
    void Function(MapLoadProgress)? onProgress,
  }) async {
    final allCells = cellKeysInRadius(lat, lon, radiusMeters);
    AppLogger.log.i(
      'MapRepository: radio ${radiusMeters}m → '
      '${allCells.length} celdas a evaluar',
    );

    // 1) ¿Cuáles están vencidas o faltan?
    final stale = await _zoneDao.findStaleCells(allCells, _ttlMs);
    final cachedCount = allCells.length - stale.length;
    AppLogger.log.i(
      'MapRepository: ${cachedCount}/${allCells.length} celdas en caché vigente',
    );

    // 2) Agrupar celdas vencidas en batches geográficos.
    final batches = _groupIntoBatches(stale.toList());
    AppLogger.log.i(
      'MapRepository: ${batches.length} batches Overpass a descargar',
    );

    onProgress?.call(MapLoadProgress(
      totalCells: allCells.length,
      cachedCells: cachedCount,
      downloadedCells: 0,
      currentBatchIndex: 0,
      totalBatches: batches.length,
      status: batches.isEmpty
          ? 'Cargando desde caché...'
          : 'Descargando datos del mundo...',
      phase: batches.isEmpty ? MapLoadPhase.cached : MapLoadPhase.downloading,
    ));

    // 3) Descargar batch a batch, persistir, reportar.
    var downloaded = 0;
    for (var i = 0; i < batches.length; i++) {
      final batchCells = batches[i].toSet();
      try {
        final bbox = bboxForCellKeys(batchCells);
        final ways = await _client.fetchRoadsInBbox(
          south: bbox.south,
          west: bbox.west,
          north: bbox.north,
          east: bbox.east,
        );
        await _zoneDao.saveBatch(targetCells: batchCells, ways: ways);
        downloaded += batchCells.length;
        AppLogger.log.i(
          'MapRepository: batch ${i + 1}/${batches.length} OK '
          '(${batchCells.length} celdas, ${ways.length} ways)',
        );
      } catch (e, st) {
        AppLogger.log.e(
          'MapRepository: batch ${i + 1}/${batches.length} falló',
          error: e,
          stackTrace: st,
        );
        // No abortamos: lo que ya está en caché sirve igual. Pero sí
        // contamos las celdas como "intentadas" para no quedarnos
        // colgados en la pantalla de carga.
        downloaded += batchCells.length;
      }
      onProgress?.call(MapLoadProgress(
        totalCells: allCells.length,
        cachedCells: cachedCount,
        downloadedCells: downloaded,
        currentBatchIndex: i + 1,
        totalBatches: batches.length,
        status: 'Descargando datos del mundo...',
        phase: MapLoadPhase.downloading,
      ));
      if (i < batches.length - 1) {
        await Future<void>.delayed(_throttleBetweenBatches);
      }
    }

    // 4) Leer la unión final desde la BD (lo recién descargado + lo
    //    que ya estaba en caché).
    final result = await _zoneDao.getWaysForCells(allCells);
    onProgress?.call(MapLoadProgress(
      totalCells: allCells.length,
      cachedCells: cachedCount,
      downloadedCells: downloaded,
      currentBatchIndex: batches.length,
      totalBatches: batches.length,
      status: 'Listo (${result.length} vías)',
      phase: MapLoadPhase.done,
    ));
    AppLogger.log.i('MapRepository: ${result.length} ways listas en memoria');
    return result;
  }

  /// Agrupa celdas en sub-bloques cuadrados de hasta
  /// [_batchCellsPerSide] x [_batchCellsPerSide]. El agrupamiento es
  /// por bloque entero según los índices: dos celdas caen en el mismo
  /// batch si `floor(idx/N) == floor(otraIdx/N)` en ambos ejes.
  List<List<String>> _groupIntoBatches(List<String> cells) {
    final groups = <String, List<String>>{};
    for (final k in cells) {
      final p = parseCellKey(k);
      final groupKey =
          '${(p.latIdx / _batchCellsPerSide).floor()}:'
          '${(p.lonIdx / _batchCellsPerSide).floor()}';
      groups.putIfAbsent(groupKey, () => []).add(k);
    }
    return groups.values.toList();
  }
}