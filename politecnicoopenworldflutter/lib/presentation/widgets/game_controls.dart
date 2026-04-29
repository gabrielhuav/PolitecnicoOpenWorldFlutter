import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/player_movement_notifier.dart';

class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movement = ref.read(playerMovementProvider.notifier);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // D-PAD Simple
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 40, color: Colors.white),
              onPressed: () => movement.move(1, 0),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
                  onPressed: () => movement.move(0, -1),
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 40, color: Colors.white),
                  onPressed: () => movement.move(0, 1),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 40, color: Colors.white),
              onPressed: () => movement.move(-1, 0),
            ),
          ],
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
          shape: BoxCircle.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
