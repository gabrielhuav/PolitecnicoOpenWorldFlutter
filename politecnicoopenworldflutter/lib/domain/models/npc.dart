import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'geo_location.dart';
import 'map_way.dart';
import 'npc_enums.dart';

/// NPC inmutable. Cada paso de simulación produce un nuevo [Npc] vía
/// [copyWith]. La igualdad se basa sólo en [id] para mantener identidad
/// estable entre frames aunque los demás campos cambien.
class Npc extends Equatable {
  final String id;
  final NpcType type;
  final GeoLocation location;
  final double rotationAngle;
  final double speed;
  final MapWay? currentWay;
  final int targetNodeIndex;
  final int moveDirection;
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

  Npc copyWith({
    GeoLocation? location,
    double? rotationAngle,
    MapWay? currentWay,
    int? targetNodeIndex,
    int? moveDirection,
  }) {
    return Npc(
      id: id,
      type: type,
      location: location ?? this.location,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      speed: speed,
      currentWay: currentWay ?? this.currentWay,
      targetNodeIndex: targetNodeIndex ?? this.targetNodeIndex,
      moveDirection: moveDirection ?? this.moveDirection,
      carColor: carColor,
      carModel: carModel,
    );
  }

  @override
  List<Object?> get props => [id];
}