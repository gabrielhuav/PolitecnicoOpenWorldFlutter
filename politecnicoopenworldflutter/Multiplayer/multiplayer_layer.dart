import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'multiplayer_notifier.dart';

/// Capa de flutter_map que dibuja:
///   • Marcadores de jugadores remotos (círculo naranja).
///   • NPCs remotos controlados por el Host de otra zona (círculo azul claro).
///
/// Solo se reconstruye cuando cambia `players` o `remoteNpcs`; no depende
/// del ticker de NPCs locales.
class MultiplayerLayer extends ConsumerWidget {
  const MultiplayerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(
      multiplayerProvider.select((s) => s.players),
    );
    final remoteNpcs = ref.watch(
      multiplayerProvider.select((s) => s.remoteNpcs),
    );

    if (players.isEmpty && remoteNpcs.isEmpty) {
      return const SizedBox.shrink();
    }

    return MarkerLayer(
      markers: [
        ...players.values.map(_buildPlayerMarker),
        ...remoteNpcs.values.map(_buildNpcMarker),
      ],
    );
  }

  // ── Marcador de jugador remoto ────────────────────────────────────

  Marker _buildPlayerMarker(RemotePlayer player) {
    return Marker(
      key: ValueKey('mp_player_${player.id}'),
      point: player.position,
      width: 56,
      height: 68,
      alignment: Alignment.bottomCenter,
      child: _RemotePlayerMarker(player: player),
    );
  }

  // ── Marcador de NPC remoto ────────────────────────────────────────

  Marker _buildNpcMarker(RemoteNpc npc) {
    final isCar = npc.type == 'car';
    return Marker(
      key: ValueKey('mp_npc_${npc.id}'),
      point: npc.position,
      width: isCar ? 22 : 14,
      height: isCar ? 22 : 14,
      alignment: Alignment.center,
      child: isCar
          ? _RemoteCarMarker(rotation: npc.rotation)
          : const _RemotePersonMarker(),
    );
  }
}

// ── Widgets de marcadores ────────────────────────────────────────────

class _RemotePlayerMarker extends StatelessWidget {
  final RemotePlayer player;
  const _RemotePlayerMarker({required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre + rol
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (player.isHost) ...[
                const Icon(Icons.star_rounded,
                    size: 9, color: Colors.amberAccent),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // Círculo del jugador (naranja para diferenciarlo del jugador local)
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
                color: player.isDriving
                    ? const Color(0xFFFF9800)
                    : const Color(0xFFFF6B35),
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
              child: Icon(
                player.isDriving
                    ? Icons.directions_car
                    : Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// NPC persona remoto — círculo azul claro para distinguirlo
/// de los NPCs locales (azul oscuro).
class _RemotePersonMarker extends StatelessWidget {
  const _RemotePersonMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF29B6F6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

/// NPC coche remoto — rectángulo rotado con color del servidor.
class _RemoteCarMarker extends StatelessWidget {
  final double rotation;
  const _RemoteCarMarker({required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF29B6F6),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black87, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.arrow_drop_up, size: 14, color: Colors.black87),
        ),
      ),
    );
  }
}