import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/player_movement_notifier.dart';
import '../state/settings_provider.dart';

// Constante compartida para el tamaño de los controles
const double controllerBaseSize = 160.0;

enum Direction { up, down, left, right }
enum GameAction { y, x, b, a }

// ==========================================
// WIDGET PRINCIPAL: D-PAD (Conectado a Riverpod)
// ==========================================
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movement = ref.read(playerMovementProvider.notifier);
    final isSwapped = ref.watch(settingsProvider).swapControls;

    return Align(
      // Invertimos la alineación dinámicamente
      alignment: isSwapped ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _DPadController(
          onDirectionPressed: (Direction direction) {
            // Mapeo de coordenadas de Flutter
            switch (direction) {
              case Direction.up:
                movement.move(1, 0);
                break;
              case Direction.down:
                movement.move(-1, 0);
                break;
              case Direction.left:
                movement.move(0, -1);
                break;
              case Direction.right:
                movement.move(0, 1);
                break;
            }
          },
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET PRINCIPAL: BOTONES DE ACCIÓN
// ==========================================
class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos si los controles están invertidos
    final isSwapped = ref.watch(settingsProvider).swapControls;
    return Align(
      alignment: isSwapped ? Alignment.bottomLeft : Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _ActionButtonsController(
          onActionChanged: (GameAction action, bool isPressed) {

            if (isPressed) {
              debugPrint("Acción presionada: $action");
            }
          },
        ),
      ),
    );
  }
}

// ==========================================
// COMPONENTES INTERNOS
// ==========================================

class _DPadController extends StatelessWidget {
  final double backgroundAlpha;
  final Function(Direction) onDirectionPressed;

  const _DPadController({
    Key? key,
    this.backgroundAlpha = 0.45,
    required this.onDirectionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: controllerBaseSize,
      height: controllerBaseSize,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: backgroundAlpha.clamp(0.0, 1.0)),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DPadButton(
            icon: Icons.keyboard_arrow_up,
            onClick: () => onDirectionPressed(Direction.up),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DPadButton(
                icon: Icons.keyboard_arrow_left,
                onClick: () => onDirectionPressed(Direction.left),
              ),
              const SizedBox(width: 48.0),
              _DPadButton(
                icon: Icons.keyboard_arrow_right,
                onClick: () => onDirectionPressed(Direction.right),
              ),
            ],
          ),
          _DPadButton(
            icon: Icons.keyboard_arrow_down,
            onClick: () => onDirectionPressed(Direction.down),
          ),
        ],
      ),
    );
  }
}

class _DPadButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onClick;

  const _DPadButton({Key? key, required this.icon, required this.onClick}) : super(key: key);

  @override
  State<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<_DPadButton> {
  Timer? _timer;

  void _startRepeating() {
    widget.onClick(); // Disparo inicial
    // Repite la acción cada 40ms (~25fps)
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      widget.onClick();
    });
  }

  void _stopRepeating() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRepeating(),
      onTapUp: (_) => _stopRepeating(),
      onTapCancel: () => _stopRepeating(),
      child: Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 32.0),
      ),
    );
  }
}

class _ActionButtonsController extends StatelessWidget {
  final double backgroundAlpha;
  final void Function(GameAction action, bool isPressed) onActionChanged;

  const _ActionButtonsController({
    Key? key,
    this.backgroundAlpha = 0.45,
    required this.onActionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: controllerBaseSize,
      height: controllerBaseSize,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(backgroundAlpha.clamp(0.0, 1.0)),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Y - Amarillo
          _ActionButton(
            text: "Y",
            color: const Color(0xFFF1C40F),
            onHoldEvent: (isPressed) => onActionChanged(GameAction.y, isPressed),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // X - Azul
              _ActionButton(
                text: "X",
                color: const Color(0xFF3498DB),
                onHoldEvent: (isPressed) => onActionChanged(GameAction.x, isPressed),
              ),
              const SizedBox(width: 40.0),
              // B - Rojo
              _ActionButton(
                text: "B",
                color: const Color(0xFFE74C3C),
                onHoldEvent: (isPressed) => onActionChanged(GameAction.b, isPressed),
              ),
            ],
          ),
          // A - Verde
          _ActionButton(
            text: "A",
            color: const Color(0xFF2ECC71),
            onHoldEvent: (isPressed) => onActionChanged(GameAction.a, isPressed),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function(bool) onHoldEvent;

  const _ActionButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onHoldEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onHoldEvent(true),
      onTapUp: (_) => onHoldEvent(false),
      onTapCancel: () => onHoldEvent(false),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}