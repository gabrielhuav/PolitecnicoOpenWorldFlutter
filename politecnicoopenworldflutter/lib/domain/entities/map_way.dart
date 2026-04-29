import 'package:equatable/equatable.dart';
import 'map_node.dart';

class MapWay extends Equatable {
  final int id;
  final List<MapNode> nodes;
  final bool isForCars;
  final bool isForPeople;

  const MapWay({
    required this.id,
    required this.nodes,
    required this.isForCars,
    required this.isForPeople,
  });

  @override
  List<Object?> get props => [id, nodes, isForCars, isForPeople];
}