import 'dart:math' as math;

/// Tamaño de celda en grados. ~555 m a lat 19.5° en latitud,
/// ~525 m en longitud (varía con cos(lat)).
const double cellDegrees = 0.005;

/// Aproximaciones constantes para grados a metros en la latitud de
/// CDMX (~19.5°). Suficiente para decidir qué celdas caen en un
/// radio. No las uses para distancias precisas; para eso, latlong2.
const double _metersPerLatDegree = 111000.0;

double _metersPerLonDegreeAt(double lat) =>
    111000.0 * math.cos(lat * math.pi / 180);

/// Convierte (lat, lon) en una cellKey serializable.
/// Formato: "<latIdx>:<lonIdx>" donde idx = floor(coord / cellDegrees).
String cellKeyFor(double lat, double lon) {
  final latIdx = (lat / cellDegrees).floor();
  final lonIdx = (lon / cellDegrees).floor();
  return '$latIdx:$lonIdx';
}

/// Parsea una cellKey y devuelve (latIdx, lonIdx). Lanza si el
/// formato no es válido (no se espera, pero hace explícito el fail).
({int latIdx, int lonIdx}) parseCellKey(String key) {
  final parts = key.split(':');
  if (parts.length != 2) {
    throw FormatException('cellKey inválida: "$key"');
  }
  return (latIdx: int.parse(parts[0]), lonIdx: int.parse(parts[1]));
}

/// Bbox (south, west, north, east) en grados para una cellKey.
({double south, double west, double north, double east}) bboxForCellKey(
    String key) {
  final p = parseCellKey(key);
  final south = p.latIdx * cellDegrees;
  final west = p.lonIdx * cellDegrees;
  return (
    south: south,
    west: west,
    north: south + cellDegrees,
    east: west + cellDegrees,
  );
}

/// Devuelve las cellKeys que tienen al menos parte de su área dentro
/// de un círculo de [radiusMeters] alrededor de (centerLat, centerLon).
///
/// Estrategia: calcula el bbox circunscrito al círculo, recorre las
/// celdas de ese bbox y descarta las que están claramente fuera del
/// círculo (centro de la celda más allá de radius + media diagonal).
List<String> cellKeysInRadius(
  double centerLat,
  double centerLon,
  double radiusMeters,
) {
  final mLatDeg = 1 / _metersPerLatDegree;
  final mLonDeg = 1 / _metersPerLonDegreeAt(centerLat);

  final latRangeDeg = radiusMeters * mLatDeg;
  final lonRangeDeg = radiusMeters * mLonDeg;

  final minLatIdx = ((centerLat - latRangeDeg) / cellDegrees).floor();
  final maxLatIdx = ((centerLat + latRangeDeg) / cellDegrees).floor();
  final minLonIdx = ((centerLon - lonRangeDeg) / cellDegrees).floor();
  final maxLonIdx = ((centerLon + lonRangeDeg) / cellDegrees).floor();

  // Media diagonal de una celda en metros (límite superior).
  final cellDiagMeters = cellDegrees * _metersPerLatDegree * math.sqrt(2);
  final maxAllowedMeters = radiusMeters + cellDiagMeters / 2;

  final result = <String>[];
  for (int li = minLatIdx; li <= maxLatIdx; li++) {
    for (int lo = minLonIdx; lo <= maxLonIdx; lo++) {
      final cellCenterLat = (li + 0.5) * cellDegrees;
      final cellCenterLon = (lo + 0.5) * cellDegrees;
      final dLatMeters = (cellCenterLat - centerLat) / mLatDeg;
      final dLonMeters = (cellCenterLon - centerLon) / mLonDeg;
      final dist = math.sqrt(dLatMeters * dLatMeters + dLonMeters * dLonMeters);
      if (dist <= maxAllowedMeters) {
        result.add('$li:$lo');
      }
    }
  }
  return result;
}

/// Bbox que cubre una lista de cellKeys. Útil para una query Overpass
/// por batch (varias celdas contiguas en una sola request).
({double south, double west, double north, double east}) bboxForCellKeys(
    Iterable<String> keys) {
  if (keys.isEmpty) {
    throw ArgumentError('keys no puede estar vacío');
  }
  int? minLat, maxLat, minLon, maxLon;
  for (final k in keys) {
    final p = parseCellKey(k);
    minLat = (minLat == null || p.latIdx < minLat) ? p.latIdx : minLat;
    maxLat = (maxLat == null || p.latIdx > maxLat) ? p.latIdx : maxLat;
    minLon = (minLon == null || p.lonIdx < minLon) ? p.lonIdx : minLon;
    maxLon = (maxLon == null || p.lonIdx > maxLon) ? p.lonIdx : maxLon;
  }
  return (
    south: minLat! * cellDegrees,
    west: minLon! * cellDegrees,
    north: (maxLat! + 1) * cellDegrees,
    east: (maxLon! + 1) * cellDegrees,
  );
}