import 'package:equatable/equatable.dart';

/// Estilo de cabello renderizable. Se mantiene pequeño a propósito;
/// se puede ampliar sin tocar el resto del dominio.
enum HairStyle { short, medium, long, bald, ponytail }

/// Datos puramente visuales de un personaje (jugador o NPC persona).
/// No contiene texto de UI ni lógica: sólo lo necesario para pintarlo.
class CharacterVisualConfig extends Equatable {
  final int skinColor;
  final int shirtColor;
  final int pantsColor;
  final int hairColor;
  final HairStyle hairStyle;

  const CharacterVisualConfig({
    required this.skinColor,
    required this.shirtColor,
    required this.pantsColor,
    required this.hairColor,
    required this.hairStyle,
  });

  static const adventurer = CharacterVisualConfig(
    skinColor: 0xFFE0AC69,
    shirtColor: 0xFF2E7D32,
    pantsColor: 0xFF3E2723,
    hairColor: 0xFF3E2723,
    hairStyle: HairStyle.short,
  );

  static const explorer = CharacterVisualConfig(
    skinColor: 0xFFD4A276,
    shirtColor: 0xFFD32F2F,
    pantsColor: 0xFF1565C0,
    hairColor: 0xFF000000,
    hairStyle: HairStyle.ponytail,
  );

  static const engineer = CharacterVisualConfig(
    skinColor: 0xFFC68642,
    shirtColor: 0xFF1976D2,
    pantsColor: 0xFF424242,
    hairColor: 0xFF212121,
    hairStyle: HairStyle.medium,
  );

  @override
  List<Object?> get props =>
      [skinColor, shirtColor, pantsColor, hairColor, hairStyle];
}