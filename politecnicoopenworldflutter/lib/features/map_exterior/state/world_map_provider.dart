import 'package:flutter/material.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/repository/map_repository_impl.dart';
import '../../../domain/models/map_node.dart';
import '../../../domain/models/map_way.dart';

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

  /// Carga inicial. [radiusMeters] es el radio total a cubrir; el
  /// repositorio decide cuántos batches Overpass usa.
  Future<void> loadInitialMapData({
    double initialLat = 19.5045,
    double initialLon = -99.1465,
    double radiusMeters = 5000,
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
      _ways = ways;
      _nodes = ways.expand((w) => w.nodes).toList();
    } catch (e, stack) {
      _errorMessage = 'Fallo crítico al inicializar el mundo: $e';
      AppLogger.log.e('loadInitialMapData falló', error: e, stackTrace: stack);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}