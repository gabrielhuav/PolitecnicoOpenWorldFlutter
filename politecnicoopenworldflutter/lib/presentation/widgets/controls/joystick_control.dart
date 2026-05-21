import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/game_settings_providers.dart';
import '../../state/player_movement_notifier.dart';

/// Joystick analógico de tipo "static": la base permanece fija; el stick
/// se arrastra dentro de ella y vuelve al centro con animación al soltar.
///
/// Mientras el dedo está presionado, un Timer interno envía cada
/// [_tickInterval] el offset normalizado (en `[-1, 1]` por eje) a
/// [PlayerMovementNotifier.moveBy].
class JoystickControl extends ConsumerStatefulWidget {
  const JoystickControl({super.key});

  @override
  ConsumerState<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends ConsumerState<JoystickControl>
    with SingleTickerProviderStateMixin {
  static const Duration _tickInterval = Duration(milliseconds: 33);
  static const Duration _returnDuration = Duration(milliseconds: 180);
  static const double _baseDiameter = 140.0;
  static const double _stickDiameter = 56.0;

  late final AnimationController _returnController;
  Offset _stickOffset = Offset.zero;
  Offset _returnFrom = Offset.zero;
  int? _activePointerId;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: _returnDuration,
    )..addListener(_onReturnTick);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _returnController.dispose();
    super.dispose();
  }

  // ── Geometría dependiente del scale ──────────────────────────────────
  double _scale() => ref.read(controlSizeProvider);
  double _baseSize(double s) => _baseDiameter * s;
  double _stickSize(double s) => _stickDiameter * s;
  double _maxOffset(double s) => (_baseSize(s) - _stickSize(s)) / 2;

  // ── Animación de retorno al centro ───────────────────────────────────
  void _onReturnTick() {
    if (!mounted) return;
    final t = Curves.easeOut.transform(_returnController.value);
    setState(() {
      _stickOffset = Offset.lerp(_returnFrom, Offset.zero, t)!;
    });
  }

  // ── Cálculo de posición del stick desde el punto local del dedo ──────
  void _updateFromLocal(Offset local) {
    final scale = _scale();
    final base = _baseSize(scale);
    final maxOff = _maxOffset(scale);
    final center = Offset(base / 2, base / 2);
    var offset = local - center;
    final distance = offset.distance;
    if (distance > maxOff) {
      offset = offset / distance * maxOff;
    }
    setState(() => _stickOffset = offset);
  }

  // ── Eventos de puntero ───────────────────────────────────────────────
  void _onPointerDown(PointerDownEvent event) {
    if (_activePointerId != null) return; // ignora dedos secundarios
    _activePointerId = event.pointer;
    _returnController.stop();
    _updateFromLocal(event.localPosition);
    _ticker ??= Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointerId) return;
    _updateFromLocal(event.localPosition);
  }

  void _onPointerEnd(PointerEvent event) {
    if (event.pointer != _activePointerId) return;
    _activePointerId = null;
    _ticker?.cancel();
    _ticker = null;
    _returnFrom = _stickOffset;
    _returnController.forward(from: 0);
  }

  // ── Tick de movimiento ───────────────────────────────────────────────
  void _onTick() {
    final maxOff = _maxOffset(_scale());
    if (maxOff == 0) return;
    final dx = _stickOffset.dx / maxOff;
    final dy = _stickOffset.dy / maxOff;
    ref.read(playerMovementProvider.notifier).moveBy(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final scale = ref.watch(controlSizeProvider);
    final baseSize = _baseSize(scale);
    final stickSize = _stickSize(scale);
    final dragging = _activePointerId != null;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: SizedBox(
        width: baseSize,
        height: baseSize,
        child: Stack(
          children: [
            // Base
            Container(
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.textPrimary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            // Stick
            Positioned(
              left: (baseSize - stickSize) / 2 + _stickOffset.dx,
              top: (baseSize - stickSize) / 2 + _stickOffset.dy,
              child: Container(
                width: stickSize,
                height: stickSize,
                decoration: BoxDecoration(
                  color: dragging
                      ? theme.accentSecondary.withValues(alpha: 0.9)
                      : theme.accentPrimary.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.textPrimary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
