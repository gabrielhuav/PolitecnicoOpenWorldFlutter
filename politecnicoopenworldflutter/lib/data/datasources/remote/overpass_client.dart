import 'package:dio/dio.dart';
import '../../../domain/entities/map_node.dart';
import '../../../domain/entities/map_way.dart';

class OverpassClient {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://overpass-api.de/api/interpreter';

  Future<List<MapWay>> fetchRoads(double lat, double lon, double radius) async {
    final query = '''
    [out:json];
    (
      way(around:$radius, $lat, $lon)["highway"]["highway"!~"footway|cycleway|path|service|track"];
    );
    out body;
    >;
    out skel qt;
    ''';

    try {
      final response = await _dio.post(_baseUrl, data: 'data=$query');
      return _parseOverpassResponse(response.data);
    } catch (e) {
      throw Exception('Error descargando calles: $e');
    }
  }

  List<MapWay> _parseOverpassResponse(Map<String, dynamic> data) {
    final List<dynamic> elements = data['elements'];
    final Map<int, MapNode> nodesMap = {};
    final List<MapWay> ways = [];

    // 1. Mapear nodos
    for (var element in elements.where((e) => e['type'] == 'node')) {
      nodesMap[element['id']] = MapNode(
        id: element['id'],
        lat: element['lat'],
        lon: element['lon'],
      );
    }

    // 2. Construir caminos
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
          name: tags['name'],
          nodes: wayNodes,
          isForCars: true,
          isForPeople: tags['foot'] == 'yes' || tags['sidewalk'] != null,
        ));
      }
    }
    return ways;
  }
}