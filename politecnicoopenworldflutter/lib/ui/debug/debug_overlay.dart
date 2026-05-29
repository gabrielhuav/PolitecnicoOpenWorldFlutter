import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../multiplayer/multiplayer_notifier.dart';

/// Overlay de debug temporal para diagnosticar el multijugador.
/// Muestra estado de conexión, sessionId y jugadores remotos en tiempo real.
/// Eliminar cuando el multijugador funcione correctamente.
class MultiplayerDebugOverlay extends ConsumerWidget {
  const MultiplayerDebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mp = ref.watch(multiplayerProvider);

    final statusColor = switch (mp.status) {
      MultiplayerStatus.connected => Colors.greenAccent,
      MultiplayerStatus.connecting => Colors.orangeAccent,
      MultiplayerStatus.disconnected => Colors.white38,
      MultiplayerStatus.error => Colors.redAccent,
    };

    final statusLabel = switch (mp.status) {
      MultiplayerStatus.connected => 'CONECTADO',
      MultiplayerStatus.connecting => 'CONECTANDO',
      MultiplayerStatus.disconnected => 'DESCONECTADO',
      MultiplayerStatus.error => 'ERROR',
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (mp.sessionId != null) ...[
            const SizedBox(height: 2),
            Text(
              'ID: ${mp.sessionId!.substring(0, 8)}...',
              style: const TextStyle(color: Colors.white54, fontSize: 9),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            'Remotos: ${mp.players.length}',
            style: TextStyle(
              color: mp.players.isEmpty ? Colors.white38 : Colors.greenAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Lista de jugadores remotos
          for (final p in mp.players.values)
            Text(
              '  ${p.displayName} (${p.position.latitude.toStringAsFixed(4)}, ${p.position.longitude.toStringAsFixed(4)})',
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          if (mp.isZoneHost)
            const Text(
              'HOST',
              style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
