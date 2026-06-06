import 'package:latlong2/latlong.dart';

import 'npc_enums.dart';

/// Vehiculo en el que el jugador puede subirse.
///
/// Usa [CarModel] de `npc_enums.dart` (no lo duplica).
class Vehicle {
  final String id;
  final LatLng position;
  final double rotationAngle;
  final CarModel carModel;
  final int carColor;

  const Vehicle({
    required this.id,
    required this.position,
    this.rotationAngle = 0,
    this.carModel = CarModel.sedan,
    this.carColor = 0xFFFFFFFF,
  });

  Vehicle copyWith({
    LatLng? position,
    double? rotationAngle,
  }) {
    return Vehicle(
      id: id,
      position: position ?? this.position,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      carModel: carModel,
      carColor: carColor,
    );
  }
}
