import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/character.dart';
import '../../../domain/models/character_visual_config.dart';

final availableCharactersProvider = Provider<List<Character>>((ref) {
  return const [
    Character(
      id: 'char_aventurera',
      name: 'Aventurera',
      description: 'Exploradora clásica del Politécnico',
      visualConfig: CharacterVisualConfig.adventurer,
      imagePath: 'assets/character/select_character/aventurera.png',
    ),
    Character(
      id: 'char_explorador',
      name: 'Explorador',
      description: 'Ágil y resistente al sol del DF',
      visualConfig: CharacterVisualConfig.explorer,
      imagePath: 'assets/character/select_character/explorador.png',
    ),
    Character(
      id: 'char_ingeniero',
      name: 'Ingeniero',
      description: 'Conoce todos los atajos del campus',
      visualConfig: CharacterVisualConfig.engineer,
      imagePath: 'assets/character/select_character/ingeniero.png',
    ),
    Character(
      id: 'char_custom',
      name: 'Personalizar',
      description: 'Diseña tu propio avatar',
      imagePath: 'assets/character/select_character/custom.png',
      isCustomSlot: true,
    ),
  ];
});

final selectedCharacterIndexProvider = StateProvider<int>((ref) => 0);

final selectedCharacterProvider = Provider<Character>((ref) {
  final list = ref.watch(availableCharactersProvider);
  final index = ref.watch(selectedCharacterIndexProvider);
  return list[index.clamp(0, list.length - 1)];
});
