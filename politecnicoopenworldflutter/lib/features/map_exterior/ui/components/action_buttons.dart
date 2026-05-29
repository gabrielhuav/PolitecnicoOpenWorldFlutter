import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/theme_extensions.dart';
import '../../../settings/state/game_settings_providers.dart';

/// Cuatro botones de acción dispuestos en rombo (norte, este, sur, oeste),
/// estilo gamepad clásico. Pensados como entrada para interacciones con
/// el entorno (NPCs, vehículos, objetos). Cada uno recibe una callback
/// opcional; si no se proporciona, el botón sigue mostrando feedback
/// visual al presionarse pero no dispara ninguna acción.
class ActionButtons extends ConsumerWidget {
  final VoidCallback? onActionTop; // Y
  final VoidCallback? onActionRight; // B
  final VoidCallback? onActionBottom; // A
  final VoidCallback? onActionLeft; // X

  const ActionButtons({
    super.key,
    this.onActionTop,
    this.onActionRight,
    this.onActionBottom,
    this.onActionLeft,
  });

  static const double _baseButtonSize = 52.0;
  static const double _baseGap = 8.0;

  // Convención Xbox / Nintendo: Y arriba, B derecha, A abajo, X izquierda.
  static const Color _colorTop = Color(0xFFFDD835); // Y amarillo
  static const Color _colorRight = Color(0xFFE53935); // B rojo
  static const Color _colorBottom = Color(0xFF43A047); // A verde
  static const Color _colorLeft = Color(0xFF1E88E5); // X azul

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    final scale = ref.watch(controlSizeProvider);
    final buttonSize = _baseButtonSize * scale;
    final gap = _baseGap * scale;
    final totalSize = 3 * buttonSize + 2 * gap;

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
            Align(
              alignment: Alignment.topCenter,
              child: _ActionButton(
                label: 'Y',
                size: buttonSize,
                color: _colorTop,
                onPressed: onActionTop,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _ActionButton(
                label: 'B',
                size: buttonSize,
                color: _colorRight,
                onPressed: onActionRight,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _ActionButton(
                label: 'A',
                size: buttonSize,
                color: _colorBottom,
                onPressed: onActionBottom,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _ActionButton(
                label: 'X',
                size: buttonSize,
                color: _colorLeft,
                onPressed: onActionLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón circular con etiqueta y color propios. Mantiene su propio
/// estado `_pressed` para animar el feedback al tap.
class _ActionButton extends ConsumerStatefulWidget {
  final String label;
  final double size;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.size,
    required this.color,
    this.onPressed,
  });

  @override
  ConsumerState<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends ConsumerState<_ActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _pressed ? 1.0 : 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.textPrimary.withValues(alpha: _pressed ? 0.6 : 0.3),
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
