/// Representa un personaje seleccionable.
/// Por ahora [imagePath] es opcional — cuando lo tengas, apunta al asset.
class Character {
  final String id;
  final String name;
  final String description;
  final String? imagePath; // null mientras no tengas la imagen
  final bool isCustomSlot;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.isCustomSlot = false,
  });
}
