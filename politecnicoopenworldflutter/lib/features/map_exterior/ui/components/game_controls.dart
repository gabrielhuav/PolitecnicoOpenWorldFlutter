import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/state/game_settings_providers.dart';
import '../../state/combat_notifier.dart';
import '../../state/player_movement_notifier.dart';
import '../../state/vehicle_notifier.dart';
import 'action_buttons.dart';
import 'driving_controls.dart';
import 'movement_control.dart';

/// Contenedor de los controles del jugador en pantalla.
///
/// Cuando [vehicleProvider.isDriving] es false, muestra los controles
/// peatonales (D-pad/joystick + ActionButtons).
/// Cuando es true, muestra [DrivingControls] (volante + pedales).
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDriving = ref.watch(
      vehicleProvider.select((s) => s.isDriving),
    );

    if (isDriving) {
      return const DrivingControls();
    }

    return _WalkingControls();
  }
}

/// Controles peatonales originales con la logica de X modificada:
/// X intenta subirse al coche mas cercano; si no hay coche, golpea.
class _WalkingControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inverted = ref.watch(invertControlsProvider);

    const movement = MovementControl();
    final actions = ActionButtons(
      // X (izquierda): subir al coche
      onActionLeft: () {
        final entered =
            ref.read(vehicleProvider.notifier).tryEnterNearestVehicle();
      },

      // A (abajo): alternar correr
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
        children: [left, right],
      ),
    );
  }
}