/// Representa un nodo geográfico (punto en el mapa).
/// Entidad pura de dominio — sin dependencias de Flutter ni de librerías externas.
class MapNode {
  final int id;
  final double lat;
  final double lon;

  const MapNode({
    required this.id,
    required this.lat,
    required this.lon,
  });

  @override
  String toString() => 'MapNode(id: $id, lat: $lat, lon: $lon)';
}