import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/game_settings_providers.dart';
import 'controls/action_buttons.dart';
import 'controls/movement_control.dart';

/// Contenedor de los controles del jugador en pantalla. Coloca
/// [MovementControl] (D-pad o joystick, según ajustes) en un lado de la
/// pantalla y [ActionButtons] (rombo de 4 botones) en el otro.
///
/// El lado de cada uno depende de [invertControlsProvider]:
///  - false (por defecto): movimiento a la izquierda, acción a la derecha.
///  - true: posiciones invertidas (zurdos o preferencia personal).
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inverted = ref.watch(invertControlsProvider);

    const movement = MovementControl();
    const actions = ActionButtons();

    final left = inverted ? actions : movement;
    final right = inverted ? movement : actions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [left, right],
      ),
    );
  }
}
