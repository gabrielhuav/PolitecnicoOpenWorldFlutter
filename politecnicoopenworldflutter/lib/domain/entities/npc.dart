import 'package:equatable/equatable.dart';
import 'geo_location.dart';
import 'map_way.dart';
import 'npc_enums.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class Npc extends Equatable {
  final String id;
  final NpcType type;
  GeoLocation location;
  double rotationAngle;
  final double speed;
  final MapWay? currentWay;
  int targetNodeIndex;
  int moveDirection;
  final int carColor;
  final CarModel carModel;

  Npc({
    String? id,
    required this.type,
    required this.location,
    this.rotationAngle = 0.0,
    required this.speed,
    this.currentWay,
    this.targetNodeIndex = 0,
    this.moveDirection = 1,
    this.carColor = 0xFFFFFFFF,
    this.carModel = CarModel.sedan,
  }) : id = id ?? const Uuid().v4();

  @override
  List<Object?> get props => [id];
}