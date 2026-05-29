import 'character_visual_config.dart';

/// Representa un personaje seleccionable o personalizado.
/// [imagePath] se utiliza para la vista previa en los menús.
/// [spritesheetPath] define la hoja de sprites con las animaciones de movimiento en el mapa.
class Character {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final String? spritesheetPath; // <-- NUEVO: Ruta dinámica de la animación
  final bool isCustomSlot;
  final CharacterVisualConfig? visualConfig;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.spritesheetPath, // <-- Agregado al constructor modular
    this.isCustomSlot = false,
    this.visualConfig,
  });
}
