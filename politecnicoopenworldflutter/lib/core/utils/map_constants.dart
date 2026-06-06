class MapConstants {
  MapConstants._();

  /// Radio de carga inicial (igual para SP y MP). El jugador entra
  /// al mapa en segundos y el resto se descarga en segundo plano.
  static const double initialLoadRadiusMeters = 10000;

  /// Radio de cobertura objetivo en singleplayer.
  static const double singleplayerRadiusMeters = 5000;

  /// Radio de cobertura objetivo en multiplayer.
  static const double multiplayerRadiusMeters = 30000;

  /// Distancia recorrida para disparar expansion de chunks.
  static const double chunkTriggerDistanceMeters = 500;

  /// TTL del cache de celdas (7 dias).
  static const int cellTtlMs = 7 * 24 * 60 * 60 * 1000;

  /// Lado del sub-bloque para batches a Overpass.
  static const int batchCellsPerSide = 6;

  /// Pausa entre batches de Overpass.
  static const Duration throttleBetweenBatches = Duration(milliseconds: 1500);
}