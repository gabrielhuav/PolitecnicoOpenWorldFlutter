import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_tile_provider.dart';

// ── Enum de tipo de control ──────────────────────────────────────────
enum ControlType {
  buttons('Botones'),
  joystick('Joystick');

  final String label;
  const ControlType(this.label);
}

// ── Providers individuales de ajustes del juego ──────────────────────
final controlTypeProvider =
    StateProvider<ControlType>((ref) => ControlType.buttons);

final invertControlsProvider = StateProvider<bool>((ref) => false);

final controlSizeProvider = StateProvider<double>((ref) => 1.0);

final showFpsProvider = StateProvider<bool>((ref) => false);

final showDatabaseProvider = StateProvider<bool>((ref) => false);

final freeMovementProvider = StateProvider<bool>((ref) => false);
