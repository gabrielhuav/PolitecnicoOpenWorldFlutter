import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../domain/models/npc.dart';
import '../../../../domain/models/npc_enums.dart';
import '../../state/npc_notifier.dart';

/// Capa de marcadores para todos los NPCs vivos. Se suscribe a
/// [npcNotifierProvider]; se reconstruye en cada frame de la simulación.
class NpcMarkerLayer extends ConsumerWidget {
  const NpcMarkerLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final npcs = ref.watch(npcNotifierProvider);
    return MarkerLayer(
      markers: npcs.map(_buildMarker).toList(growable: false),
    );
  }

  Marker _buildMarker(Npc npc) {
    final isCar = npc.type == NpcType.car;
    return Marker(
      key: ValueKey(npc.id),
      point: LatLng(npc.location.latitude, npc.location.longitude),
      width: isCar ? 22 : 14,
      height: isCar ? 22 : 14,
      alignment: Alignment.center,
      child: isCar
          ? _CarMarker(
              rotationDeg: npc.rotationAngle,
              color: Color(npc.carColor),
            )
          : const _PersonMarker(),
    );
  }
}

class _PersonMarker extends StatelessWidget {
  const _PersonMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
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

class _CarMarker extends StatelessWidget {
  final double rotationDeg;
  final Color color;
  const _CarMarker({required this.rotationDeg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDeg * math.pi / 180,
      child: Container(
        decoration: BoxDecoration(
          color: color,
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