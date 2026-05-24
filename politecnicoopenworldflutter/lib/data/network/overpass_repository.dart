import 'package:dio/dio.dart';
import 'package:politecnicoopenworldflutter/core/utils/app_logger.dart';
import '../../domain/models/map_node.dart';
import '../../domain/models/map_way.dart';

/// Tipos de highway que SÍ descargamos. El resto se ignora.
const _highwayWhitelist = {
  // Vehiculares puros o mixtos.
  'motorway',
  'trunk',
  'primary',
  'secondary',
  'tertiary',
  'residential',
  'unclassified',
  'living_street',
  'service',
  // Peatonales (sin cycleway por decisión del proyecto).
  'footway',
  'path',
  'pedestrian',
  'steps',
};

/// Tipos que permiten coches. Subset del whitelist.
const _carHighways = {
  'motorway',
  'trunk',
  'primary',
  'secondary',
  'tertiary',
  'residential',
  'unclassified',
  'living_street',
  'service',
};

/// Tipos que permiten personas. Subset del whitelist.
/// Nota: residential/unclassified NO se incluyen aquí intencionalmente:
/// las personas solo caminan por ways peatonales explícitas (footway,
/// path, etc.) o mixtas (living_street, service). Esto evita que los
/// NPCs persona caminen sobre el carril en calles sin banqueta mapeada.
const _peopleHighways = {
  'footway',
  'path',
  'pedestrian',
  'steps',
  'living_street',
  'service',
};

class OverpassRepository {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://overpass-api.de/api/interpreter';

  /// Descarga todas las ways de un bbox geográfico cuyo tipo
  /// [highway] está en el whitelist. Devuelve los objetos de
  /// dominio ya clasificados.
  ///
  /// Lanza si la respuesta no es válida o si la red falla; el
  /// repositorio superior decide cómo reintentar.
  Future<List<MapWay>> fetchRoadsInBbox({
    required double south,
    required double west,
    required double north,
    required double east,
  }) async {
    final highwayRegex = _highwayWhitelist.join('|');
    final query = '''
[out:json][timeout:60];
(
  way($south,$west,$north,$east)["highway"~"^($highwayRegex)\$"];
);
out body;
>;
out skel qt;
''';

    final response = await _dio.post(
      _baseUrl,
      data: {'data': query},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 90),
        headers: const {
          'User-Agent': 'politecnicoopenworldflutter/1.0',
        },
      ),
    );

    final responseData = response.data;
    final Map<String, dynamic> map;
    if (responseData is Map<String, dynamic>) {
      map = responseData;
    } else if (responseData is Map) {
      map = Map<String, dynamic>.from(responseData);
    } else {
      throw Exception(
        'Respuesta de Overpass no válida: ${responseData.runtimeType}',
      );
    }
    return _parseOverpassResponse(map);
  }

  List<MapWay> _parseOverpassResponse(Map<String, dynamic> data) {
    final elements = data['elements'] as List<dynamic>?;
    if (elements == null) return const [];

    // 1. Mapear nodos por id.
    final nodesMap = <int, MapNode>{};
    for (final element in elements) {
      if (element is! Map) continue;
      if (element['type'] != 'node') continue;
      final id = element['id'];
      final lat = element['lat'];
      final lon = element['lon'];
      if (id is! int || lat is! num || lon is! num) continue;
      nodesMap[id] = MapNode(id: id, lat: lat.toDouble(), lon: lon.toDouble());
    }

    // 2. Construir ways con clasificación correcta.
    final ways = <MapWay>[];
    for (final element in elements) {
      if (element is! Map) continue;
      if (element['type'] != 'way') continue;
      final id = element['id'];
      if (id is! int) continue;
      final rawNodeIds = element['nodes'];
      if (rawNodeIds is! List) continue;

      final tags = (element['tags'] is Map)
          ? Map<String, dynamic>.from(element['tags'])
          : const <String, dynamic>{};
      final highway = tags['highway'] as String?;
      if (highway == null || !_highwayWhitelist.contains(highway)) continue;

      final wayNodes = <MapNode>[];
      for (final nodeId in rawNodeIds) {
        if (nodeId is! int) continue;
        final n = nodesMap[nodeId];
        if (n != null) wayNodes.add(n);
      }
      if (wayNodes.length < 2) continue;

      ways.add(MapWay(
        id: id,
        name: tags['name'] as String?,
        nodes: wayNodes,
        isForCars: _classifyCars(highway, tags),
        isForPeople: _classifyPeople(highway, tags),
        direction: _classifyDirection(tags),
      ));
    }

    AppLogger.log.d(
      'Overpass parseado: ${ways.length} ways en bbox '
      '(nodos referenciados: ${nodesMap.length})',
    );
    return ways;
  }

  bool _classifyCars(String highway, Map<String, dynamic> tags) {
    if (!_carHighways.contains(highway)) return false;
    final mv = tags['motor_vehicle'];
    if (mv == 'no') return false;
    final v = tags['vehicle'];
    if (v == 'no') return false;
    final access = tags['access'];
    if (access == 'no' || access == 'private') return false;
    return true;
  }

  bool _classifyPeople(String highway, Map<String, dynamic> tags) {
    if (!_peopleHighways.contains(highway)) return false;
    final foot = tags['foot'];
    if (foot == 'no') return false;
    final access = tags['access'];
    if (access == 'no' || access == 'private') return false;
    return true;
  }
}

WayDirection _classifyDirection(Map<String, dynamic> tags) {
  final oneway = tags['oneway']?.toString().toLowerCase();
  if (oneway == 'yes' || oneway == '1' || oneway == 'true') {
    return WayDirection.forward;
  }
  if (oneway == '-1' || oneway == 'reverse') {
    return WayDirection.backward;
  }
  return WayDirection.both;
}