import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/utils/providers.dart';
import '../state/map_provider.dart';

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerPos = ref.watch(playerLocationProvider);
    final permissionAsync = ref.watch(locationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politecnico Open World', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6E0000),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: playerPos,
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ovh.gabrielhuav.pow',
              ),
              ref.watch(roadsProvider((lat: playerPos.latitude, lon: playerPos.longitude))).when(
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
          permissionAsync.when(
            data: (ok) => ok ? const SizedBox.shrink() : const Center(child: Text("Permisos GPS denegados")),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error: $err")),
          ),
        ],
      ),
    );
  }
}