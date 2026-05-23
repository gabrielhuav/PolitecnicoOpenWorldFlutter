import 'map_node.dart';

class MapWay {
  final int id;
  final String? name;
  final List<MapNode> nodes;
  final bool isForCars;
  final bool isForPeople;

  const MapWay({
    required this.id,
    this.name,
    required this.nodes,
    required this.isForCars,
    required this.isForPeople,
  });

  @override
  String toString() => 'MapWay(id: $id, name: $name, nodes: ${nodes.length})';
}