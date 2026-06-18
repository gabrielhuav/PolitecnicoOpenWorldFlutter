import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/theme_extensions.dart';
import '../../../settings/state/game_settings_providers.dart';
import '../../state/vehicle_notifier.dart';

/// Controles que reemplazan al D-pad/joystick + ActionButtons cuando
/// el jugador esta conduciendo. Disposicion:
///
///   Izquierda: volante (giro izquierda / derecha)
///   Derecha:   Y=Salir (amarillo), B=Gas (verde), A=Freno (rojo)
///
/// Usa Listener (no GestureDetector) para detectar pulsaciones
/// continuas, igual que DPadControl.
class DrivingControls extends ConsumerWidget {
  const DrivingControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(controlSizeProvider);
    final inverted = ref.watch(invertControlsProvider);

    final steering = _SteeringButtons(scale: scale);
    final pedals = _PedalButtons(scale: scale);

    final Widget left = inverted ? pedals : steering;
    final Widget right = inverted ? steering : pedals;

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

// ── Volante (izquierda/derecha) ──────────────────────────────────────

class _SteeringButtons extends ConsumerWidget {
  final double scale;
  const _SteeringButtons({required this.scale});

  static const double _baseSize = 60;
  static const double _baseGap = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    final size = _baseSize * scale;
    final gap = _baseGap * scale;
    final notifier = ref.read(vehicleProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.textPrimary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HoldButton(
            icon: Icons.rotate_left,
            size: size,
            color: const Color(0xFF90CAF9),
            onDown: () => notifier.steeringLeft = true,
            onUp: () => notifier.steeringLeft = false,
          ),
          SizedBox(width: gap),
          _HoldButton(
            icon: Icons.rotate_right,
            size: size,
            color: const Color(0xFF90CAF9),
            onDown: () => notifier.steeringRight = true,
            onUp: () => notifier.steeringRight = false,
          ),
        ],
      ),
    );
  }
}

// ── Pedales + salir ─────────────────────────────────────────────────

class _PedalButtons extends ConsumerWidget {
  final double scale;
  const _PedalButtons({required this.scale});

  static const double _baseSize = 52;
  static const double _baseGap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    final size = _baseSize * scale;
    final gap = _baseGap * scale;
    final totalSize = 3 * size + 2 * gap;
    final notifier = ref.read(vehicleProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.textPrimary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          children: [
            // Salir (izquierda)
            Align(
              alignment: Alignment.centerLeft,
              child: _HoldButton(
                label: 'Salir',
                size: size,
                color: const Color(0xFFFDD835),
                onDown: () => notifier.exitVehicle(),
                onUp: () {},
              ),
            ),
            // Gas (arriba)
            Align(
              alignment: Alignment.topCenter,
              child: _HoldButton(
                label: 'Gas',
                size: size,
                color: const Color(0xFF43A047),
                onDown: () => notifier.gasPressed = true,
                onUp: () => notifier.gasPressed = false,
              ),
            ),
            // Freno (abajo)
            Align(
              alignment: Alignment.bottomCenter,
              child: _HoldButton(
                label: 'Freno',
                size: size,
                color: const Color(0xFFE53935),
                onDown: () => notifier.brakePressed = true,
                onUp: () => notifier.brakePressed = false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Boton con pulsacion continua ────────────────────────────────────
// Acepta [icon] O [label] (o ambos). Muestra el que se proporcione.

class _HoldButton extends StatefulWidget {
  final IconData? icon;
  final String? label;
  final double size;
  final Color color;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _HoldButton({
    this.icon,
    this.label,
    required this.size,
    required this.color,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        setState(() => _pressed = true);
        widget.onDown();
      },
      onPointerUp: (_) {
        setState(() => _pressed = false);
        widget.onUp();
      },
      onPointerCancel: (_) {
        setState(() => _pressed = false);
        widget.onUp();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _pressed ? 1.0 : 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: _pressed ? 0.5 : 0.25),
            width: _pressed ? 2 : 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.size * 0.45,
                )
              : Text(
                  widget.label ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.size * 0.28,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Boton de un solo tap (para Salir) ───────────────────────────────

class _TapButton extends StatefulWidget {
  final String label;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _TapButton({
    required this.label,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _pressed ? 1.0 : 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: _pressed ? 0.6 : 0.3),
            width: _pressed ? 2 : 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.4,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
