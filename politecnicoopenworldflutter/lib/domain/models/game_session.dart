import 'package:equatable/equatable.dart';

/// Representa una partida persistida del jugador.
/// Entidad pura de dominio sin dependencias de Flutter ni de Drift.
class GameSession extends Equatable {
  final String id;
  final String characterId;
  final String characterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double lastLat;
  final double lastLon;
  final bool isActive;

  const GameSession({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLat,
    required this.lastLon,
    required this.isActive,
  });

  GameSession copyWith({
    String? characterId,
    String? characterName,
    DateTime? updatedAt,
    double? lastLat,
    double? lastLon,
    bool? isActive,
  }) {
    return GameSession(
      id: id,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLat: lastLat ?? this.lastLat,
      lastLon: lastLon ?? this.lastLon,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        characterId,
        characterName,
        createdAt,
        updatedAt,
        lastLat,
        lastLon,
        isActive,
      ];
}
