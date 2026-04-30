import 'package:flutter/material.dart';
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
  Future<void> loadInitialMapData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avisamos a la UI que empezamos a cargar

    try {
      // Aquí delegas el trabajo pesado al repositorio.
      // Idealmente, tu repositorio debería devolver un objeto o tupla con nodos y vías.
      // Ejemplo: final result = await _mapRepository.getOpenWorldData();

      // Simulación mientras terminas de cablear el MapRepositoryImpl:
      await Future.delayed(const Duration(seconds: 2));

      // _nodes = result.nodes;
      // _ways = result.ways;
    } catch (e) {
      _errorMessage = 'Fallo crítico al inicializar el mundo: $e';
      // Lanzamos la excepción para que el menú principal la cachee y muestre el SnackBar
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisamos a la UI que ya terminamos (éxito o fracaso)
    }
  }

  /// Ejemplo de función adicional: Refrescar una zona específica si el jugador se mueve mucho
  Future<void> loadChunk(
      double latitude, double longitude, double radius) async {
    // Aquí implementarías la lógica para descargar un nuevo "pedazo" de mapa
    // usando tu overpass_client.dart a través del repositorio.
  }
}
