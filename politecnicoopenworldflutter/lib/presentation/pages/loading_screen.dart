import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';       
import '../../core/theme/theme_extensions.dart'; 
import '../../core/utils/app_logger.dart';
import '../../core/utils/location_providers.dart';
import '../../core/utils/providers.dart';
import '../../core/utils/session_providers.dart';
import '../../services/location/location_permission_status.dart';
import '../state/character_provider.dart';
import '../state/player_movement_notifier.dart';
import 'character_selection_screen.dart';
import 'start_menu_screen.dart';
import 'world_map_screen.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  final bool isResuming;
  final String? resumeSessionId;

  const LoadingScreen({
    Key? key,
    this.isResuming = false,
    this.resumeSessionId,
  }) : super(key: key);

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  // ── Consejos rotativos ───────────────────────────────────────────────
  static const List<String> _tips = [
    'ESCOM fue fundada en 1974 como parte del IPN.',
    'El campus tiene más de 6,000 estudiantes activos.',
    'Puedes explorar las calles reales del campus con datos de OpenStreetMap.',
    'Usa el D-pad para moverte por el mapa del Politécnico.',
    'El botón de recentrar te regresa a tu posición actual en el mapa.',
    'Próximamente podrás personalizar tu propio personaje.',
  ];

  // Fallback usado cuando el GPS no está disponible.
  static const LatLng _escomFallback = LatLng(19.5045, -99.1465);

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _tipTimer;

  bool _loadStarted = false;
  String _statusText = 'Inicializando el mundo...';
  bool _hasError = false;
  String _errorMessage = '';
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _hasError || _tips.length < 2) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    AppLogger.log.d('LoadingScreen: bootstrap iniciado (isResuming: ${widget.isResuming})');
    if (_loadStarted) return;
    _loadStarted = true;

    try {
      _setStatus('Descargando calles del campus...');
      await ref.read(mapStateProvider).loadInitialMapData();

      LatLng targetCoords = _escomFallback; 

      if (widget.isResuming) {
        _setStatus('Recuperando partida guardada...');
        final sessionId = widget.resumeSessionId;
        if (sessionId == null) {
          throw Exception('ID de sesión inválido para reanudar.');
        }

        final session = await ref.read(activeGameSessionProvider.notifier).resume(sessionId);
        if (session == null) {
          throw Exception('No se encontró el registro de la partida guardada.');
        }

        targetCoords = LatLng(session.lastLat, session.lastLon);
      } else {
        _setStatus('Solicitando permiso de ubicación...');
        final spawn = await _resolveSpawnLocation();
        targetCoords = spawn;

        _setStatus('Guardando nueva partida...');
        final character = ref.read(selectedCharacterProvider);
        await ref.read(activeGameSessionProvider.notifier).startNewSession(
              characterId: character.id,
              characterName: character.name,
              spawnLat: spawn.latitude,
              spawnLon: spawn.longitude,
            );
      }

      ref.read(playerMovementProvider.notifier).teleport(targetCoords);
      AppLogger.log.i('Jugador colocado en: ${targetCoords.latitude}, ${targetCoords.longitude}');

      if (!mounted) return;
      _setStatus('Listo para jugar!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorldMapScreen()),
      );
    } catch (e, stack) {
      AppLogger.log.e('LoadingScreen bootstrap falló', error: e, stackTrace: stack);
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Error al iniciar la partida: $e';
        _statusText = 'Error al iniciar';
      });
    }
  }

  Future<LatLng> _resolveSpawnLocation() async {
    final permissionService = ref.read(locationPermissionServiceProvider);
    final locationService = ref.read(locationServiceProvider);

    final status = await permissionService.request();
    switch (status) {
      case LocationPermissionStatus.granted:
        _setStatus('Obteniendo tu ubicación...');
        final pos = await locationService.getCurrent();
        if (pos != null) return pos;
        return _escomFallback;
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
      case LocationPermissionStatus.serviceDisabled:
        return _escomFallback;
    }
  }

  void _setStatus(String text) {
    if (!mounted) return;
    setState(() => _statusText = text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Icon(
                  Icons.map_outlined,
                  size: 72,
                  color: theme.textPrimary.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Politécnico Open World',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary, 
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(flex: 2),
                if (!_hasError) ...[
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentSecondary.withOpacity(0.12),
                        border: Border.all(
                          color: theme.accentSecondary,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: CircularProgressIndicator(
                          color: theme.accentSecondary, 
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _statusText,
                    style: TextStyle(
                      color: theme.textSecondary, 
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => widget.isResuming 
                              ? const StartMenuScreen() 
                              : const CharacterSelectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.surfaceOverlay, 
                      foregroundColor: theme.textPrimary,     
                    ),
                  ),
                ],
                const Spacer(flex: 2),
                _TipCard(tip: _tips[_tipIndex], theme: theme),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final AppTheme theme; 

  const _TipCard({
    required this.tip,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surfaceOverlay, 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.borderAccent.withOpacity(0.4), 
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.accentSecondary, 
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONSEJO',
                  style: TextStyle(
                    color: theme.accentSecondary, 
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    color: theme.textSecondary, 
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}