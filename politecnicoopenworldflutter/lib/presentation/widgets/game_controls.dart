import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_extensions.dart';
import '../state/player_movement_notifier.dart';

class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    final movement = ref.read(playerMovementProvider.notifier);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
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
                onPressed: () => movement.move(1, 0),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DPadButton(
                    icon: Icons.arrow_back,
                    onPressed: () => movement.move(0, -1),
                  ),
                  const SizedBox(width: 40),
                  _DPadButton(
                    icon: Icons.arrow_forward,
                    onPressed: () => movement.move(0, 1),
                  ),
                ],
              ),
              _DPadButton(
                icon: Icons.arrow_downward,
                onPressed: () => movement.move(-1, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DPadButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _DPadButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    return Material(
      color: theme.textPrimary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 32, color: theme.textPrimary),
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircularButton("A", Colors.green, () {}),
            const SizedBox(width: 12),
            _buildCircularButton("B", Colors.red, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
