import 'package:dio/dio.dart';
import 'package:politecnicoopenworldflutter/core/utils/app_logger.dart';
import '../../domain/models/map_node.dart';
import '../../domain/models/map_way.dart';

class OverpassRepository {
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
      final response = await _dio.post(
        _baseUrl,
        data: {'data': query},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'User-Agent': 'politecnicoopenworldflutter/1.0',
          },
        ),
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return _parseOverpassResponse(responseData);
      }
      if (responseData is Map) {
        return _parseOverpassResponse(Map<String, dynamic>.from(responseData));
      }

      throw Exception(
        'Respuesta de Overpass no válida: ${responseData.runtimeType}',
      );
    } catch (e, stack) {
      AppLogger.log.e(
        'OverpassRepository.fetchRoads falló',
        error: e,
        stackTrace: stack,
      );
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
