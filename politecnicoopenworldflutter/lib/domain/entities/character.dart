import 'character_visual_config.dart';

/// Representa un personaje seleccionable.
/// Por ahora [imagePath] es opcional. [visualConfig] funciona como puente
/// entre la UI (nombre, descripción) y el motor del juego (datos visuales).
class Character {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final bool isCustomSlot;
  final CharacterVisualConfig? visualConfig;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.isCustomSlot = false,
    this.visualConfig,
  });
}