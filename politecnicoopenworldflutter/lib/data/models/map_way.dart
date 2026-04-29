import 'map_node.dart';

class MapWay {
  final int id;
  final List<MapNode> nodes;
  final bool isForCars;
  final bool isForPeople;

  MapWay({
    required this.id,
    required this.nodes,
    required this.isForCars,
    required this.isForPeople,
  });
}
