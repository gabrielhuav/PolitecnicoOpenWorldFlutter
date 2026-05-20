import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/map_tile_provider.dart';
import '../state/character_provider.dart';
import '../state/player_movement_notifier.dart';
import '../state/npc_notifier.dart';
import '../widgets/npc_marker_layer.dart';
import '../widgets/game_controls.dart';

import 'game_menu_screen.dart';

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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    ref.read(npcNotifierProvider.notifier).start();
  });
}

@override
void dispose() {
  ref.read(npcNotifierProvider.notifier).stop();
  _mapController.dispose();
  super.dispose();
}

  /// Abre el menú de pausa como una ruta translúcida (opaque: false) para
  /// que el mapa y el marcador del jugador sigan visibles detrás del
  /// overlay, al estilo Minecraft.
  void _openPauseMenu() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (_, __, ___) => const GameMenuScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final playerPosition = ref.watch(playerMovementProvider);
    final character = ref.watch(selectedCharacterProvider);
    final tileProvider = ref.watch(mapTileProviderProvider);

    ref.listen<LatLng>(playerMovementProvider, (prev, next) {
      try {
        _mapController.move(next, _mapController.camera.zoom);
      } catch (_) {}
    });

    return Scaffold(
      body: Stack(
        children: [
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
                urlTemplate: tileProvider.url,
                subdomains: tileProvider.subdomains,
                userAgentPackageName: 'com.politecnicoopenworld.flutter',
                maxNativeZoom: tileProvider.maxZoom,
              ),
              const NpcMarkerLayer(),
              MarkerLayer(
                markers: [
                  Marker(
                    point: playerPosition,
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    child: _PlayerMarker(theme: theme),
                  ),
                ],
              ),
            ],
          ),

          // Botón menú
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'fab_menu',
              mini: true,
              backgroundColor: theme.surfacePrimary,
              foregroundColor: theme.textPrimary,
              onPressed: _openPauseMenu,
              child: const Icon(Icons.menu),
            ),
          ),

          // HUD del personaje
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.borderAccent,
                  width: 1,
                ),
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

          // Recentrar
          Positioned(
            bottom: 220,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'fab_recentrar',
              mini: true,
              backgroundColor: theme.surfacePrimary,
              foregroundColor: theme.textPrimary,
              onPressed: () {
                _mapController.move(playerPosition, _initialZoom);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // Controles
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GameControls(),
          ),

          // Atribución
          Positioned(
            bottom: 4,
            right: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tileProvider.attribution,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  final AppTheme theme;
  const _PlayerMarker({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.accentSecondary.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.buttonPrimary,
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
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}
