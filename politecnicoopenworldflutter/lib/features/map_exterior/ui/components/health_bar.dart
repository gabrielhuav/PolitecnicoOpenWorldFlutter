import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/player_health_notifier.dart';

/// Barra de salud que aparece automáticamente al recibir daño y se
/// oculta sola tras 3 s si la vida está por encima de 30. Se monta
/// en la esquina superior derecha del WorldMapScreen.
///
/// No requiere ningún cambio si el jugador no recibe daño: el estado
/// inicial es showBar=false y el widget no pinta nada.
class HealthBar extends ConsumerWidget {
  const HealthBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(playerHealthProvider);
    if (!health.showBar) return const SizedBox.shrink();

    final ratio = (health.health / health.maxHealth).clamp(0.0, 1.0);
    final color = _colorFor(ratio);

    return AnimatedOpacity(
      opacity: health.showBar ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VIDA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${health.health.toInt()}',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(double ratio) {
    if (ratio > 0.6) return const Color(0xFF4CAF50);
    if (ratio > 0.3) return const Color(0xFFFFB300);
    return const Color(0xFFE53935);
  }
}
