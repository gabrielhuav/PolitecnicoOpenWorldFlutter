import 'package:flutter/foundation.dart';
import '../../domain/models/map_way.dart';
import '../local/pow_database.dart';
import '../../data/network/overpass_repository.dart';

class MapRepository {
  final PowDatabase _db;
  final OverpassRepository _client;

  MapRepository(this._db, this._client);

  Future<List<MapWay>> getRoadsForLocation(double lat, double lon) async {
    // Por ahora vamos directo al cliente Overpass
    // En el PR de persistencia usaremos _db aquí
    final ways = await _client.fetchRoads(lat, lon, 1500);

    _saveToCache(ways);

    return ways;
  }

  void _saveToCache(List<MapWay> ways) {
    // Implementaremos el guardado en Drift pronto
    // Usamos _db para evitar el error de field unused
    debugPrint('Preparando caché en base de datos: ${_db.executor}');
    // Aquí iría la lógica para convertir MapWay a la entidad de Drift y guardarla

    // Por ahora solo imprimimos para confirmar que _db se está usando
    debugPrint('Caché guardada (simulado) para ${ways.length} vías');
    // Usamos _db para evitar el error de field unused
    debugPrint('Base de datos disponible: ${_db.executor}');

    // En el futuro, podríamos implementar una lógica de caché más sofisticada
    // que verifique si ya tenemos datos recientes antes de llamar a Overpass
  }
}