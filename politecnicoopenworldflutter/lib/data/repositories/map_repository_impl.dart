import '../../domain/entities/map_way.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/overpass_client.dart';

class MapRepositoryImpl {
  final AppDatabase _db;
  final OverpassClient _client;

  MapRepositoryImpl(this._db, this._client);

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
    print("Preparando caché en base de datos: ${_db.executor}");
  }
}