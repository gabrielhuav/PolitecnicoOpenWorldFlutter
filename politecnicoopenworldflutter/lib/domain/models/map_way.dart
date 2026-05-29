import 'map_node.dart';

/// Sentido permitido para recorrer una [MapWay]. OSM lo expresa con el
/// tag `oneway`. Las personas pueden ignorarlo; los coches no.
enum WayDirection {
  both,
  forward,
  backward;

  String get storageValue => name;

  static WayDirection fromStorage(String? value) {
    if (value == null) return WayDirection.both;
    return WayDirection.values.firstWhere(
      (d) => d.name == value,
      orElse: () => WayDirection.both,
    );
  }
}

class MapWay {
  final int id;
  final String? name;
  final List<MapNode> nodes;
  final bool isForCars;
  final bool isForPeople;
  final WayDirection direction;

  const MapWay({
    required this.id,
    this.name,
    required this.nodes,
    required this.isForCars,
    required this.isForPeople,
    this.direction = WayDirection.both,
  });

  @override
  String toString() =>
      'MapWay(id: $id, name: $name, nodes: ${nodes.length}, dir: $direction)';
}