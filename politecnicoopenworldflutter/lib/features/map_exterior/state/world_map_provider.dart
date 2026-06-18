import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/repository/map_repository_impl.dart';
import '../../../domain/models/map_node.dart';
import '../../../domain/models/map_way.dart';
import '../../../core/utils/map_constants.dart';

class WorldMapProvider extends ChangeNotifier {
  final MapRepository _mapRepository;

  WorldMapProvider({required MapRepository mapRepository})
      : _mapRepository = mapRepository;

  // Estado del mapa
  List<MapNode> _nodes = [];
  List<MapWay> _ways = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Progreso reactivo
  MapLoadProgress _progress = MapLoadProgress.idle();

  List<MapNode> get nodes => _nodes;
  List<MapWay> get ways => _ways;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MapLoadProgress get progress => _progress;

  /// Bootstrap inicial: lo invoca [LoadingScreen] una sola vez.
  Future<void> loadInitialMapData({
    required double initialLat,
    required double initialLon,
    double radiusMeters = MapConstants.singleplayerRadiusMeters,
  }) async {
    AppLogger.log.i(
      'loadInitialMapData: centro=($initialLat, $initialLon) '
      'radio=${radiusMeters}m',
    );
    _isLoading = true;
    _errorMessage = null;
    _progress = MapLoadProgress.idle();
    notifyListeners();

    try {
      final ways = await _mapRepository.getRoadsForLocation(
        initialLat,
        initialLon,
        radiusMeters: radiusMeters,
        onProgress: (p) {
          _progress = p;
          notifyListeners();
        },
      );
      // Fusionar: mantener ways existentes fuera del nuevo radio
      // y agregar/actualizar las del nuevo radio. Dedup por way ID.
      final merged = <int, MapWay>{};
      for (final w in _ways) {
        merged[w.id] = w;
      }
      for (final w in ways) {
        merged[w.id] = w; // actualiza si ya existia, agrega si es nueva
      }
      _ways = merged.values.toList();
      _nodes = _ways.expand((w) => w.nodes).toList();
    } catch (e, stack) {
      _errorMessage = 'Fallo crítico al inicializar el mundo: $e';
      AppLogger.log.e('loadInitialMapData falló', error: e, stackTrace: stack);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga la cobertura alrededor de un nuevo centro sin reiniciar
  /// el estado. Lo invoca [ChunkStreamerNotifier] cuando detecta que
  /// el jugador se movió más de un umbral desde la última recarga.
  ///
  /// Si las celdas que entran al nuevo círculo ya están en caché y
  /// no han vencido, es casi instantáneo. Si no, sólo se descarga
  /// la franja anular nueva.
  Future<void> expandCoverage({
    required double initialLat,
    required double initialLon,
    double radiusMeters = MapConstants.singleplayerRadiusMeters,
  }) async {
    if (_isLoading) {
      AppLogger.log.d('expandCoverage saltado: ya hay una carga en curso');
      return;
    }
    AppLogger.log.i(
      'expandCoverage: centro=($initialLat, $initialLon) '
      'radio=${radiusMeters}m',
    );
    _isLoading = true;
    notifyListeners();
    try {
      final ways = await _mapRepository.getRoadsForLocation(
        initialLat,
        initialLon,
        radiusMeters: radiusMeters,
        onProgress: (p) {
          _progress = p;
          notifyListeners();
        },
      );
      _ways = ways;
      _nodes = ways.expand((w) => w.nodes).toList();
      AppLogger.log.i('expandCoverage: ${ways.length} ways tras recentrar');
    } catch (e, stack) {
      AppLogger.log.e('expandCoverage falló', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}