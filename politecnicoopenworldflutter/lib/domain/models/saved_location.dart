import 'package:equatable/equatable.dart';

/// Tipos de ubicación que se pueden guardar dentro de una partida.
enum SavedLocationKind {
  spawn,
  visited,
  waypoint,
  poi;

  String get storageValue => name;

  static SavedLocationKind fromStorage(String value) {
    return SavedLocationKind.values.firstWhere(
      (k) => k.name == value,
      orElse: () => SavedLocationKind.waypoint,
    );
  }
}

/// Entidad pura de dominio para una ubicación geográfica vinculada a una
/// partida. Sin dependencias de Flutter ni de Drift.
class SavedLocation extends Equatable {
  final String id;
  final String sessionId;
  final String label;
  final double lat;
  final double lon;
  final SavedLocationKind kind;
  final DateTime createdAt;

  const SavedLocation({
    required this.id,
    required this.sessionId,
    required this.label,
    required this.lat,
    required this.lon,
    required this.kind,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, sessionId, label, lat, lon, kind, createdAt];
}
