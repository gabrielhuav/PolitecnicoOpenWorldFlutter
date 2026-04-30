import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/character.dart';

/// Lista fija de personajes disponibles + slot de personalización.
final availableCharactersProvider = Provider<List<Character>>((ref) {
  return const [
    Character(
      id: 'char_aventurero',
      name: 'Aventurero',
      description: 'Explorador clásico del Politécnico',
    ),
    Character(
      id: 'char_exploradora',
      name: 'Exploradora',
      description: 'Ágil y resistente al sol del DF',
    ),
    Character(
      id: 'char_ingeniero',
      name: 'Ingeniero',
      description: 'Conoce todos los atajos del campus',
    ),
    Character(
      id: 'char_custom',
      name: 'Personalizar',
      description: 'Diseña tu propio avatar',
      isCustomSlot: true,
    ),
  ];
});

/// Índice del personaje actualmente seleccionado en la lista.
final selectedCharacterIndexProvider = StateProvider<int>((ref) => 0);

/// Personaje resuelto a partir del índice seleccionado.
final selectedCharacterProvider = Provider<Character>((ref) {
  final list = ref.watch(availableCharactersProvider);
  final index = ref.watch(selectedCharacterIndexProvider);
  return list[index.clamp(0, list.length - 1)];
});
