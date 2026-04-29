import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/utils/providers.dart';
import '../state/map_provider.dart';
import '../widgets/game_controls.dart';
import '../state/player_movement_notifier.dart';

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos el nuevo provider de movimiento
    final playerPos = ref.watch(playerMovementProvider); 
    final permissionAsync = ref.watch(locationPermissionProvider);

    return Scaffold(
      // Mantenemos el AppBar o lo quitamos para modo inmersivo
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: playerPos,
              initialZoom: 17.0,
              // Evitamos que el usuario mueva el mapa con los dedos 
              // para forzar el uso de los controles del juego
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.drag),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ovh.gabrielhuav.pow',
              ),
              // Capa de calles (Overpass)
              ref.watch(roadsProvider(lat: playerPos.latitude, lon: playerPos.longitude)).when(
                data: (ways) => PolylineLayer(
                  polylines: ways.map((way) => Polyline(
                    points: way.nodes.map((n) => LatLng(n.lat, n.lon)).toList(),
                    color: Colors.white.withValues(alpha: 0.5),
                    strokeWidth: 3.0,
                  )).toList(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: playerPos,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.navigation, color: Colors.blue, size: 30),
                  ),
                ],
              ),
            ],
          ),
          
          // NUEVA CAPA: CONTROLES
          const GameControls(),
          const ActionButtons(),

          // Overlay de carga
          permissionAsync.when(
            data: (ok) => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
          ),
        ],
      ),
    );
  }
}