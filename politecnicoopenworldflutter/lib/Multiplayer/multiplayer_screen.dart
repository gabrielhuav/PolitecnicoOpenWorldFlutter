import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/providers.dart';
import '../features/main_menu/state/character_provider.dart';
import '../features/map_exterior/ui/loading_screen.dart';
import '../features/map_exterior/state/location_providers.dart';
import 'multiplayer_notifier.dart';

/// Pantalla de multijugador simplificada.
/// Muestra el estado de la conexión y un único botón para conectar/desconectar.
/// Tras conectarse, redirige directamente al mapa.
class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  bool _navigating = false;

  Future<void> _connect() async {
    if (_navigating) return;

    final url = ref.read(multiplayerServerUrlProvider);
    final character = ref.read(selectedCharacterProvider);

    await ref.read(multiplayerProvider.notifier).connect(
          serverUrl: url,
          playerName: character.name,
        );

    if (!mounted) return;
    final status = ref.read(multiplayerProvider).status;
    if (status == MultiplayerStatus.error) return;

    // Emitir posición inicial para que otros jugadores nos vean
    final locationService = ref.read(locationServiceProvider);
    final currentLatLng = await locationService.getCurrent();
    if (currentLatLng != null) {
      ref.read(multiplayerProvider.notifier).broadcastMovement(currentLatLng);
    }

    setState(() => _navigating = true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoadingScreen(isResuming: false),
      ),
    );
  }

  void _disconnect() =>
      ref.read(multiplayerProvider.notifier).disconnect();

  @override
  Widget build(BuildContext context) {
    final mpState = ref.watch(multiplayerProvider);
    final isConnecting = mpState.status == MultiplayerStatus.connecting;
    final isConnected = mpState.isConnected;
    final hasError = mpState.status == MultiplayerStatus.error;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 26),
                    onPressed: () {
                      _disconnect();
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Multijugador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Cuerpo ──────────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono de estado animado
                      _StatusIcon(status: mpState.status),
                      const SizedBox(height: 20),

                      // Título de estado
                      Text(
                        _statusTitle(mpState.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtítulo / descripción
                      Text(
                        _statusSubtitle(mpState.status),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Error
                      if (hasError && mpState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    Colors.redAccent.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            mpState.errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // Chips informativos cuando está conectado
                      if (isConnected) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            if (mpState.players.isNotEmpty)
                              _Chip(
                                icon: Icons.people_rounded,
                                label: '${mpState.players.length} en línea',
                                color: Colors.greenAccent,
                              ),
                            _Chip(
                              icon: mpState.isZoneHost
                                  ? Icons.star_rounded
                                  : Icons.person_rounded,
                              label: mpState.isZoneHost
                                  ? 'Host de zona'
                                  : 'Cliente',
                              color: mpState.isZoneHost
                                  ? Colors.amberAccent
                                  : Colors.white54,
                            ),
                            if (mpState.remoteNpcs.isNotEmpty)
                              _Chip(
                                icon: Icons.directions_car_rounded,
                                label: '${mpState.remoteNpcs.length} NPCs',
                                color: Colors.lightBlueAccent,
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 40),

                      // ── BOTÓN PRINCIPAL ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _navigating
                              ? null
                              : isConnected
                                  ? _navigateToMap
                                  : isConnecting
                                      ? null
                                      : _connect,
                          icon: isConnecting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isConnected
                                      ? Icons.play_arrow_rounded
                                      : hasError
                                          ? Icons.refresh_rounded
                                          : Icons.people_rounded,
                                  size: 22,
                                ),
                          label: Text(
                            isConnecting
                                ? 'Conectando...'
                                : isConnected
                                    ? 'Entrar al mapa'
                                    : hasError
                                        ? 'Reintentar'
                                        : 'Conectarse',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConnected
                                ? const Color(0xFF0F766E)
                                : hasError
                                    ? Colors.redAccent
                                    : const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            disabledBackgroundColor:
                                const Color(0xFF0F766E).withValues(alpha: 0.4),
                            disabledForegroundColor: Colors.white54,
                          ),
                        ),
                      ),

                      // Botón desconectar (solo si está conectado)
                      if (isConnected) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _disconnect,
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Desconectar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white60,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToMap() async {
    if (_navigating) return;
    final locationService = ref.read(locationServiceProvider);
    final currentLatLng = await locationService.getCurrent();
    if (currentLatLng != null) {
      ref.read(multiplayerProvider.notifier).broadcastMovement(currentLatLng);
    }
    setState(() => _navigating = true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoadingScreen(isResuming: false),
      ),
    );
  }

  String _statusTitle(MultiplayerStatus s) => switch (s) {
        MultiplayerStatus.disconnected => 'Sin conexión',
        MultiplayerStatus.connecting => 'Conectando...',
        MultiplayerStatus.connected => '¡Conectado!',
        MultiplayerStatus.error => 'Error de conexión',
      };

  String _statusSubtitle(MultiplayerStatus s) => switch (s) {
        MultiplayerStatus.disconnected =>
          'Presiona el botón para unirte a la partida multijugador.',
        MultiplayerStatus.connecting =>
          'Estableciendo conexión con el servidor...',
        MultiplayerStatus.connected =>
          'Listo para explorar con otros jugadores.',
        MultiplayerStatus.error =>
          'No se pudo alcanzar el servidor.\nVerifica tu conexión a internet.',
      };
}

// ── Widgets auxiliares ───────────────────────────────────────────────

class _StatusIcon extends StatefulWidget {
  final MultiplayerStatus status;
  const _StatusIcon({required this.status});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.status) {
      MultiplayerStatus.disconnected => Colors.white38,
      MultiplayerStatus.connecting => Colors.orangeAccent,
      MultiplayerStatus.connected => Colors.greenAccent,
      MultiplayerStatus.error => Colors.redAccent,
    };
    final icon = switch (widget.status) {
      MultiplayerStatus.disconnected => Icons.wifi_off_rounded,
      MultiplayerStatus.connecting => Icons.sync_rounded,
      MultiplayerStatus.connected => Icons.people_rounded,
      MultiplayerStatus.error => Icons.error_outline_rounded,
    };
    return ScaleTransition(
      scale: _scale,
      child: Icon(icon, size: 80, color: color),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}