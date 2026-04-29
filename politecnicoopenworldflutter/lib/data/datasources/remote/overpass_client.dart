import 'package:dio/dio.dart';
import '../../models/map_node.dart';
import '../../models/map_way.dart';

class OverpassClient {
  final Dio _dio = Dio();
  final String _baseUrl = "https://overpass-api.de/api/interpreter";

  Future<List<MapWay>> fetchRoads(double lat, double lon, double radius) async {
    // Query exacta que usas en Android para filtrar calles
    final query = """
    [out:json];
    (
      way(around:$radius, $lat, $lon)["highway"]["highway"!~"footway|cycleway|path|service|track"];
    );
    out body;
    >;
    out skel qt;
    """;

    try {
      final response = await _dio.post(_baseUrl, data: 'data=$query');
      return _parseOverpassResponse(response.data);
    } catch (e) {
      throw Exception("Error descargando calles: $e");
    }
  }

  List<MapWay> _parseOverpassResponse(Map<String, dynamic> data) {
    final List<dynamic> elements = data['elements'];
    final Map<int, MapNode> nodesMap = {};
    final List<MapWay> ways = [];

    // 1. Mapear Nodos
    for (var element in elements.where((e) => e['type'] == 'node')) {
      nodesMap[element['id']] = MapNode(
        id: element['id'],
        lat: element['lat'],
        lon: element['lon'],
      );
    }

    // 2. Construir Caminos (Ways)
    for (var element in elements.where((e) => e['type'] == 'way')) {
      final List<int> nodeIds = List<int>.from(element['nodes']);
      final List<MapNode> wayNodes = nodeIds
          .where((id) => nodesMap.containsKey(id))
          .map((id) => nodesMap[id]!)
          .toList();

      if (wayNodes.isNotEmpty) {
        final tags = element['tags'] ?? {};
        ways.add(MapWay(
          id: element['id'],
          nodes: wayNodes,
          isForCars: true, // Lógica simplificada de tu regex de Android
          isForPeople: tags['foot'] == 'yes' || tags['sidewalk'] != null,
        ));
      }
    }
    return ways;
  }
}