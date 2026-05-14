import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../state/character_provider.dart';
import '../state/player_movement_notifier.dart';
import 'start_menu_screen.dart';
import '../widgets/game_controls.dart';

import '../../core/utils/map_tile_provider.dart';

class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  late final MapController _mapController;
  static const double _initialZoom = 17.5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerPosition = ref.watch(playerMovementProvider);
    final character = ref.watch(selectedCharacterProvider);
    final TileProvider = ref.watch(mapTileProviderProvider);

    // Cuando el jugador se mueve con los controles, recentramos el mapa.
    ref.listen<LatLng>(playerMovementProvider, (prev, next) {
      try {
        _mapController.move(next, _mapController.camera.zoom);
      } catch (_) {
        // El controller aún no está listo en el primer frame; lo ignoramos.
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ============================================
          // CAPA 0: MAPA NATIVO (flutter_map + OSM tiles)
          // ============================================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: playerPosition,
              initialZoom: _initialZoom,
              minZoom: 12.0,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: TileProvider.url, // URL del proveedor seleccionado
                userAgentPackageName: 'com.politecnicoopenworld.flutter',
                maxNativeZoom: 19,
              ),
              // Marker del jugador
              MarkerLayer(
                markers: [
                  Marker(
                    point: playerPosition,
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    child: _PlayerMarker(),
                  ),
                ],
              ),
            ],
          ),

          // ============================================
          // CAPA 1: BOTÓN MENÚ (top-left)
          // ============================================
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'fab_menu',
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StartMenuScreen(),
                  ),
                );
              },
              child: const Icon(Icons.menu),
            ),
          ),

          // ============================================
          // CAPA 2: HUD del personaje + coordenadas
          // ============================================
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.tealAccent.withValues(alpha: 0.4), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${playerPosition.latitude.toStringAsFixed(5)}, '
                    '${playerPosition.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // CAPA 3: BOTÓN DE RECENTRAR (sobre los controles)
          // ============================================
          Positioned(
            bottom: 220,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'fab_recentral',
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: () {
                _mapController.move(playerPosition, _initialZoom);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // ============================================
          // CAPA 4: CONTROLES (D-PAD)
          // ============================================
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GameControls(),
          ),
        ],
      ),
    );
  }
}

/// Marker visual del jugador.
class _PlayerMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.tealAccent.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        // Punto principal
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.tealAccent.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}
