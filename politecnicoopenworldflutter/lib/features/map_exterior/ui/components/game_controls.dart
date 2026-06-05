import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/state/game_settings_providers.dart';
import '../../state/combat_notifier.dart';
// Importamos el notificador de movimiento
import '../../state/player_movement_notifier.dart'; 
import 'action_buttons.dart';
import 'movement_control.dart';

/// Contenedor de los controles del jugador en pantalla. Coloca
/// [MovementControl] (D-pad o joystick, según ajustes) en un lado de la
/// pantalla y [ActionButtons] (rombo de 4 botones) en el otro.
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inverted = ref.watch(invertControlsProvider);

    const movement = MovementControl();
    final actions = ActionButtons(
      // Botón X (Izquierda)
      onActionLeft: () => ref.read(combatProvider.notifier).tryPunch(),
      
      // Botón A (Abajo) -> Activa o desactiva la mecánica de correr
      onActionBottom: () {
        final isRunning = ref.read(playerMovementProvider).isRunning;
        ref.read(playerMovementProvider.notifier).setRunning(!isRunning);
      },
    );

    final Widget left = inverted ? actions : movement;
    final Widget right = inverted ? movement : actions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          left,
          right,
        ],
      ),
    );
  }
}