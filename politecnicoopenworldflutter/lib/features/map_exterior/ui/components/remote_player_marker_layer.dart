import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../multiplayer/multiplayer_notifier.dart';

/// Capa de marcadores para todos los jugadores remotos conectados.
/// Solo se renderiza algo cuando [multiplayerProvider] tiene jugadores
/// en línea; en singleplayer la lista está vacía y el widget no pinta nada.
class RemotePlayerMarkerLayer extends ConsumerWidget {
  const RemotePlayerMarkerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(
      multiplayerProvider.select((s) => s.players),
    );

    if (players.isEmpty) return const SizedBox.shrink();

    final markers = players.values.map(_buildMarker).toList(growable: false);
    return MarkerLayer(markers: markers);
  }

  Marker _buildMarker(RemotePlayer player) {
    return Marker(
      key: ValueKey('remote_${player.id}'),
      point: player.position,
      width: 56,
      height: 72,
      alignment: Alignment.bottomCenter,
      child: _RemotePlayerWidget(player: player),
    );
  }
}

class _RemotePlayerWidget extends StatelessWidget {
  final RemotePlayer player;
  const _RemotePlayerWidget({required this.player});

  @override
  Widget build(BuildContext context) {
    final isHost = player.isHost;
    final healthRatio = (player.health / 100).clamp(0.0, 1.0);
    final healthColor = healthRatio > 0.6
        ? const Color(0xFF4CAF50)
        : healthRatio > 0.3
            ? const Color(0xFFFFB300)
            : const Color(0xFFE53935);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre y rol
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHost
                  ? const Color(0xFFFFD700)
                  : Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHost) ...[
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFD700), size: 10),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  player.displayName.isEmpty ? 'Jugador' : player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // Barra de vida (solo si está dañado)
        if (player.health < 100) ...[
          SizedBox(
            width: 44,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: healthRatio,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
        // Icono del jugador
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Sombra elíptica en el suelo
            Positioned(
              bottom: -3,
              child: Container(
                width: 22,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isHost
                    ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                    : const Color(0xFF1976D2).withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                player.isDriving ? Icons.directions_car : Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
