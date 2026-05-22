import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_visual_config.dart';

final availableCharactersProvider = Provider<List<Character>>((ref) {
  return const [
    Character(
      id: 'char_aventurero',
      name: 'Aventurero',
      description: 'Explorador clásico del Politécnico',
      visualConfig: CharacterVisualConfig.adventurer,
    ),
    Character(
      id: 'char_exploradora',
      name: 'Exploradora',
      description: 'Ágil y resistente al sol del DF',
      visualConfig: CharacterVisualConfig.explorer,
    ),
    Character(
      id: 'char_ingeniero',
      name: 'Ingeniero',
      description: 'Conoce todos los atajos del campus',
      visualConfig: CharacterVisualConfig.engineer,
    ),
    Character(
      id: 'char_custom',
      name: 'Personalizar',
      description: 'Diseña tu propio avatar',
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