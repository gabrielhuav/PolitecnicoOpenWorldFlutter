import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/theme_extensions.dart';
import '../../../settings/state/game_settings_providers.dart';
import '../../state/player_movement_notifier.dart';

/// D-pad de cuatro botones en cruz. Mientras al menos un botón está
/// presionado, un Timer interno llama a [PlayerMovementNotifier.moveBy]
/// cada [_tickInterval]. Soporta presión simultánea de dos botones
/// adyacentes para producir movimiento diagonal.
class DPadControl extends ConsumerStatefulWidget {
  const DPadControl({super.key});

  @override
  ConsumerState<DPadControl> createState() => _DPadControlState();
}

enum _DPadDir { north, south, east, west }

class _DPadControlState extends ConsumerState<DPadControl> {
  static const Duration _tickInterval = Duration(milliseconds: 33);
  static const double _baseButtonSize = 52.0;
  static const double _baseGap = 40.0;
  static const double _baseIconSize = 32.0;

  final Set<_DPadDir> _active = {};
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _press(_DPadDir dir) {
    _active.add(dir);
    _ticker ??= Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _release(_DPadDir dir) {
    _active.remove(dir);
    if (_active.isEmpty) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _tick() {
    if (_active.isEmpty) return;
    double dx = 0;
    double dy = 0;
    if (_active.contains(_DPadDir.north)) dy -= 1;
    if (_active.contains(_DPadDir.south)) dy += 1;
    if (_active.contains(_DPadDir.east)) dx += 1;
    if (_active.contains(_DPadDir.west)) dx -= 1;

    // Normaliza diagonales para que la magnitud nunca exceda 1.
    if (dx != 0 && dy != 0) {
      final mag = math.sqrt(dx * dx + dy * dy);
      dx /= mag;
      dy /= mag;
    }
    ref.read(playerMovementProvider.notifier).moveBy(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final scale = ref.watch(controlSizeProvider);
    final buttonSize = _baseButtonSize * scale;
    final gap = _baseGap * scale;
    final iconSize = _baseIconSize * scale;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DPadButton(
            icon: Icons.arrow_upward,
            size: buttonSize,
            iconSize: iconSize,
            onPress: () => _press(_DPadDir.north),
            onRelease: () => _release(_DPadDir.north),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DPadButton(
                icon: Icons.arrow_back,
                size: buttonSize,
                iconSize: iconSize,
                onPress: () => _press(_DPadDir.west),
                onRelease: () => _release(_DPadDir.west),
              ),
              SizedBox(width: gap),
              _DPadButton(
                icon: Icons.arrow_forward,
                size: buttonSize,
                iconSize: iconSize,
                onPress: () => _press(_DPadDir.east),
                onRelease: () => _release(_DPadDir.east),
              ),
            ],
          ),
          _DPadButton(
            icon: Icons.arrow_downward,
            size: buttonSize,
            iconSize: iconSize,
            onPress: () => _press(_DPadDir.south),
            onRelease: () => _release(_DPadDir.south),
          ),
        ],
      ),
    );
  }
}

/// Botón individual del D-pad. Mantiene un estado `_pressed` interno
/// para dar feedback visual mientras el dedo está sobre él.
class _DPadButton extends ConsumerStatefulWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  const _DPadButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onPress,
    required this.onRelease,
  });

  @override
  ConsumerState<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends ConsumerState<_DPadButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _setPressed(true);
        widget.onPress();
      },
      onPointerUp: (_) {
        _setPressed(false);
        widget.onRelease();
      },
      onPointerCancel: (_) {
        _setPressed(false);
        widget.onRelease();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _pressed
              ? theme.accentSecondary.withValues(alpha: 0.35)
              : theme.textPrimary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: _pressed
              ? Border.all(color: theme.accentSecondary, width: 1.5)
              : null,
        ),
        child: Icon(
          widget.icon,
          size: widget.iconSize,
          color: theme.textPrimary,
        ),
      ),
    );
  }
}
