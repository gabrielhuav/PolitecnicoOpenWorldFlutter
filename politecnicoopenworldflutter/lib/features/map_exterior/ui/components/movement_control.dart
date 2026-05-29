import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/state/game_settings_providers.dart';
import 'dpad_control.dart';
import 'joystick_control.dart';

/// Selector entre el D-pad y el joystick analógico según el valor actual
/// de [controlTypeProvider]. Se reconstruye automáticamente cuando el
/// usuario cambia el tipo de control desde la pantalla de ajustes.
///
/// No mantiene estado propio: delega por completo en el widget hijo.
class MovementControl extends ConsumerWidget {
  const MovementControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlType = ref.watch(controlTypeProvider);
    return switch (controlType) {
      ControlType.buttons => const DPadControl(),
      ControlType.joystick => const JoystickControl(),
    };
  }
}
