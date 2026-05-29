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
import '../../../../multiplayer/multiplayer_notifier.dart';
import '../../../../multiplayer/multiplayer_layer.dart';
import 'components/npc_marker_layer.dart';
import 'components/game_controls.dart';
import 'components/map_status_indicator.dart';
import 'components/player_sprite.dart';

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
      final initialCenter = ref.read(playerMovementProvider).position;
      _publishViewportRadius(initialCenter, _initialZoom);
      ref.read(npcNotifierProvider.notifier).start();
      ref.read(chunkStreamerProvider.notifier).start(initialCenter);

      // ── BROADCAST INICIAL ──────────────────────────────────────────
      // Manda la posición al servidor inmediatamente al entrar al mapa,
      // sin esperar a que el jugador mueva el joystick.
      // Sin esto, el servidor no registra al jugador y los demás
      // no lo ven hasta que se mueve por primera vez.
      final mp = ref.read(multiplayerProvider);
      if (mp.status == MultiplayerStatus.connected) {
        ref.read(multiplayerProvider.notifier).broadcastMovement(
              initialCenter,
              action: 'idle',
              facingRight: true,
              isDriving: false,
            );
      }
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

  Future<void> _openPauseMenu() async {
    final isConnected = ref.read(multiplayerProvider).isConnected;

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
    if (!isConnected) {
      ref.read(npcNotifierProvider.notifier).resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final playerState = ref.watch(playerMovementProvider);
    final playerPosition = playerState.position;

    final character = ref.watch(selectedCharacterProvider);
    final tileProvider = ref.watch(mapTileProviderProvider);

    ref.listen<PlayerState>(playerMovementProvider, (prev, next) {
      if (!mounted) return;
      try {
        _mapController.move(next.position, _mapController.camera.zoom);
      } catch (_) {}

      // Broadcast SOLO en multijugador.
      final mp = ref.read(multiplayerProvider);
      if (mp.status == MultiplayerStatus.connected) {
        ref.read(multiplayerProvider.notifier).broadcastMovement(
              next.position,
              action: next.isMoving ? 'walk' : 'idle',
              facingRight: next.facing == PlayerDirection.right,
              isDriving: false,
            );
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
              MarkerLayer(
                markers: [
                  Marker(
                    point: playerPosition,
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    child: _PlayerMarker(
                      theme: theme,
                      playerState: playerState,
                      spritesheetPath: character.spritesheetPath ??
                          'assets/character/move_character/spiritiesheet-aventurera.png',
                    ),
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

          // HUD del personaje + estado multijugador
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: theme.borderAccent, width: 1),
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
                // Badge de estado multijugador
                _MultiplayerBadge(),
              ],
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

/// Badge pequeño que muestra el estado de la conexión multijugador.
/// Visible solo cuando está conectado; muestra jugadores remotos y rol.
class _MultiplayerBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mp = ref.watch(multiplayerProvider);
    if (!mp.isConnected) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'CONECTADO',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${(mp.sessionId ?? '').substring(0, math.min(8, (mp.sessionId ?? '').length))}...',
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
          Text(
            'Remotos: ${mp.players.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          if (mp.isZoneHost)
            const Text(
              'HOST',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  final AppTheme theme;
  final PlayerState playerState;
  final String spritesheetPath;

  const _PlayerMarker({
    required this.theme,
    required this.playerState,
    required this.spritesheetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: -3,
          child: Container(
            width: 25,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        SizedBox(
          width: 56,
          height: 56,
          child: PlayerSprite(
            playerState: playerState,
            spritesheetPath: spritesheetPath,
          ),
        ),
      ],
    );
  }
}