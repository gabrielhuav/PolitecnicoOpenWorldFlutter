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

/// Controles peatonales con la lógica de X modificada:
/// X intenta subirse al coche mas cercano; si no hay coche, golpea.
class _WalkingControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inverted = ref.watch(invertControlsProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    const movement = MovementControl();
    final actions = ActionButtons(
      // X (izquierda): subir al coche
      onActionLeft: () {
        ref.read(vehicleProvider.notifier).tryEnterNearestVehicle();
      },
      // A (abajo): alternar correr
      onActionBottom: () {
        final isRunning = ref.read(playerMovementProvider).isRunning;
        ref.read(playerMovementProvider.notifier).setRunning(!isRunning);
      },
    );

    // ========================================================
    // AQUÍ CONFIGURAS LA OPACIDAD (0.0 invisible - 1.0 sólido)
    // ========================================================
    const double opacidadControles = 0.65; // 65% de opacidad

    // Envolvemos la asignación de botones con el widget Opacity
    final Widget left = Opacity(
      opacity: opacidadControles,
      child: inverted ? actions : movement,
    );

    final Widget right = Opacity(
      opacity: opacidadControles,
      child: inverted ? movement : actions,
    );

    // Dependiendo de la orientación del teléfono, llamamos a un layout distinto
    if (isLandscape) {
      return _buildLandscapeLayout(left, right);
    } else {
      return _buildPortraitLayout(left, right);
    }
  }

  /// Layout para cuando el teléfono está de pie (Vertical)
  Widget _buildPortraitLayout(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [left, right],
      ),
    );
  }

  /// Layout para cuando el teléfono está acostado (Horizontal)
  Widget _buildLandscapeLayout(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 70, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [left, right],
      ),
    );
  }
}
