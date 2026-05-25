import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../ui/theme/app_theme.dart';
import '../../../ui/theme/theme_extensions.dart';
import '../../settings/state/map_tile_provider.dart';
import '../state/camera_providers.dart';
import '../../main_menu/state/character_provider.dart';
import '../state/player_movement_notifier.dart';
import '../state/chunk_streamer_notifier.dart';
import '../state/npc_notifier.dart';
import '../../../../Multiplayer/multiplayer_notifier.dart';
import '../../../../Multiplayer/multiplayer_layer.dart';
import 'components/npc_marker_layer.dart';
import 'components/game_controls.dart';
import 'components/map_status_indicator.dart';

import 'game_menu_screen.dart';

class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  late final MapController _mapController;

  NpcNotifier? _npcNotifierRef;
  ChunkStreamerNotifier? _chunkStreamerRef;

  static const double _initialZoom = 17.5;

  void _publishViewportRadius(LatLng center, double zoom) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final radius = _visibleRadiusMeters(center.latitude, zoom, size);
    ref.read(viewportRadiusProvider.notifier).state = radius;
  }

  static double _visibleRadiusMeters(
    double cameraLat,
    double cameraZoom,
    Size widgetSize,
  ) {
    final metersPerPixel = 156543.03392 *
        math.cos(cameraLat * math.pi / 180) /
        math.pow(2, cameraZoom);
    final halfDiagonalPx = math.sqrt(
          widgetSize.width * widgetSize.width +
              widgetSize.height * widgetSize.height,
        ) /
        2;
    return halfDiagonalPx * metersPerPixel;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initialCenter = ref.read(playerMovementProvider);
      _publishViewportRadius(initialCenter, _initialZoom);
      ref.read(npcNotifierProvider.notifier).start();
      ref.read(chunkStreamerProvider.notifier).start(initialCenter);
    });
  }

  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _npcNotifierRef ??= ref.read(npcNotifierProvider.notifier);
    _chunkStreamerRef ??= ref.read(chunkStreamerProvider.notifier);
  }

  @override
  void dispose() {
    _npcNotifierRef?.stop();
    _chunkStreamerRef?.stop();
    _mapController.dispose();
    super.dispose();
  }

  /// Abre el menú de pausa como ruta translúcida (opaque: false).
  /// Solo pausa/reanuda NPCs — NO registra ningún listener aquí.
  Future<void> _openPauseMenu() async {
    final isConnected = ref.read(multiplayerProvider).isConnected;

    // Solo pausar el bucle local si estamos en modo Singleplayer
    if (!isConnected) {
      ref.read(npcNotifierProvider.notifier).pause();
    }
    await Navigator.push(
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
    if (!mounted) return;
    // Solo reanudar si lo habíamos pausado nosotros
    if (!isConnected) {
      ref.read(npcNotifierProvider.notifier).resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final playerPosition = ref.watch(playerMovementProvider);
    final character = ref.watch(selectedCharacterProvider);
    final tileProvider = ref.watch(mapTileProviderProvider);

    // Mueve la cámara cada vez que el jugador se mueve.
    // TAMBIÉN transmite posición al servidor, SOLO si el jugador
    // está conectado al modo multijugador.
    ref.listen<LatLng>(playerMovementProvider, (prev, next) {
      if (!mounted) return;
      try {
        _mapController.move(next, _mapController.camera.zoom);
      } catch (_) {}

      // Guard: solo broadcast si la sesión multijugador está activa.
      final mpStatus = ref.read(multiplayerProvider).status;
      if (mpStatus == MultiplayerStatus.connected) {
        ref.read(multiplayerProvider.notifier).broadcastMovement(next);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: playerPosition,
              initialZoom: _initialZoom,
              minZoom: 15.5,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
              onPositionChanged: (position, hasGesture) {
                final center = position.center;
                final zoom = position.zoom;
                if (center == null || zoom == null) return;
                _publishViewportRadius(center, zoom);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: tileProvider.url,
                subdomains: tileProvider.subdomains,
                userAgentPackageName: 'com.politecnicoopenworld.flutter',
                maxNativeZoom: tileProvider.maxZoom,
              ),
              const NpcMarkerLayer(),
              const MultiplayerLayer(),
              // Capa de jugadores remotos: solo pinta marcadores cuando
              // hay una sesión multijugador conectada; no hace nada en
              // singleplayer porque players estará vacío.
              ///const MultiplayerLayer(),
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

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: const Center(child: MapStatusIndicator()),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.borderAccent, width: 1),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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