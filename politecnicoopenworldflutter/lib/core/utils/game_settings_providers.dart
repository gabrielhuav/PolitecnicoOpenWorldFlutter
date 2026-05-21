  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:latlong2/latlong.dart';

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

/// Indica si el usuario ha habilitado explícitamente el uso de su GPS real.
/// Por defecto es 'false', forzando el uso de ESCOM.
final useRealLocationProvider = StateProvider<bool>((ref) => false);