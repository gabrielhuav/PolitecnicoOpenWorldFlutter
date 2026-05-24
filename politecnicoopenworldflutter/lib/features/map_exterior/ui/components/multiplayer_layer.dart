import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/multiplayer_notifier.dart';

/// Capa de flutter_map que dibuja un marcador por cada jugador remoto
/// conectado al servidor. Se reconstruye solo cuando cambia el mapa
/// de jugadores remotos, no en cada tick de NPC.
class MultiplayerLayer extends ConsumerWidget {
  const MultiplayerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(
      multiplayerProvider.select((s) => s.players),
    );

    if (players.isEmpty) return const SizedBox.shrink();

    return MarkerLayer(
      markers: players.values.map(_buildMarker).toList(growable: false),
    );
  }

  Marker _buildMarker(RemotePlayer player) {
    return Marker(
      key: ValueKey('mp_${player.id}'),
      point: player.position,
      width: 56,
      height: 68,
      alignment: Alignment.bottomCenter,
      child: _RemotePlayerMarker(name: player.name),
    );
  }
}

class _RemotePlayerMarker extends StatelessWidget {
  final String name;
  const _RemotePlayerMarker({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Etiqueta con el nombre
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        // Marcador circular naranja (diferencia del jugador local que es azul)
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ),
      ],
    );
  }
}