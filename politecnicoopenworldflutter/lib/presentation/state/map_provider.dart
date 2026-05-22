import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
// Importamos tus entidades del dominio
import '../../domain/entities/map_node.dart';
import '../../domain/entities/map_way.dart';
// Importamos el repositorio (Asegúrate de que la clase se llame así en tu archivo)
import '../../data/repositories/map_repository_impl.dart';

class MapProvider extends ChangeNotifier {
  // Inyectamos el repositorio que se encargará de decidir si usa Overpass o la DB local
  final MapRepositoryImpl _mapRepository;

  MapProvider({required MapRepositoryImpl mapRepository})
      : _mapRepository = mapRepository;

  // ==========================================
  // ESTADO INTERNO DEL MAPA
  // ==========================================
  List<MapNode> _nodes = [];
  List<MapWay> _ways = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ==========================================
  // GETTERS (Para que la UI lea los datos de forma segura)
  // ==========================================
  List<MapNode> get nodes => _nodes;
  List<MapWay> get ways => _ways;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // LÓGICA PRINCIPAL
  // ==========================================

  /// Descarga o lee los datos iniciales del mapa.
  /// Esta es la función que se llama desde el StartMenuScreen.
  Future<void> loadInitialMapData({
    double initialLat = 19.5045,
    double initialLon = -99.1465,
  }) async {
    AppLogger.log.i('loadInitialMapData: centro=($initialLat, $initialLon)');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final ways = await _mapRepository.getRoadsForLocation(initialLat, initialLon);
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

  /// Ejemplo de función adicional: Refrescar una zona específica si el jugador se mueve mucho
  Future<void> loadChunk(
      double latitude, double longitude, double radius) async {
    // Aquí implementarías la lógica para descargar un nuevo "pedazo" de mapa
    // usando tu overpass_client.dart a través del repositorio.
  }
}
