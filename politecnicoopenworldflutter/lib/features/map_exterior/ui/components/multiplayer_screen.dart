import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/theme_extensions.dart';
import '../../../main_menu/state/character_provider.dart';
import '../../../main_menu/ui/components/menu_button.dart';
import '../../../map_exterior/ui/loading_screen.dart';
import '../../state/multiplayer_notifier.dart';

class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  bool _navigating = false;

  Future<void> _connect() async {
    if (_navigating) return;

    final character = ref.read(selectedCharacterProvider);
    await ref
        .read(multiplayerProvider.notifier)
        .connect(playerName: character.name);

    if (!mounted) return;

    final status = ref.read(multiplayerProvider).status;
    if (status == MultiplayerStatus.error) return;

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
    final theme = ref.appTheme;
    final mpState = ref.watch(multiplayerProvider);
    final character = ref.watch(selectedCharacterProvider);

    final isConnecting = mpState.status == MultiplayerStatus.connecting;
    final isConnected = mpState.isConnected;
    final hasError = mpState.status == MultiplayerStatus.error;

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
          child: Column(
            children: [
              // ── Barra superior ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: theme.textPrimary, size: 28),
                      onPressed: () {
                        _disconnect();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Multijugador',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenido ───────────────────────────────────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusIcon(status: mpState.status),
                        const SizedBox(height: 24),

                        Text(
                          _statusTitle(mpState.status),
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          _statusSubtitle(mpState.status, character.name),
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Session ID (debug)
                        if (isConnected && mpState.sessionId != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'ID: ${mpState.sessionId!.substring(0, 8)}…',
                            style: TextStyle(
                              color: theme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],

                        // Error
                        if (hasError && mpState.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.redAccent
                                      .withValues(alpha: 0.4)),
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

                        // Chips de estado (jugadores + rol)
                        if (isConnected) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (mpState.players.isNotEmpty)
                                _InfoChip(
                                  icon: Icons.people_rounded,
                                  label:
                                      '${mpState.players.length} en línea',
                                  color: Colors.greenAccent,
                                ),
                              if (mpState.players.isNotEmpty)
                                const SizedBox(width: 10),
                              _InfoChip(
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
                              if (mpState.remoteNpcs.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                _InfoChip(
                                  icon: Icons.directions_car_rounded,
                                  label:
                                      '${mpState.remoteNpcs.length} NPCs',
                                  color: Colors.lightBlueAccent,
                                ),
                              ],
                            ],
                          ),
                        ],

                        const SizedBox(height: 40),

                        // Botones de acción
                        if (!isConnected && !isConnecting)
                          MenuButton(
                            title: hasError
                                ? 'Reintentar conexión'
                                : 'Conectar y jugar',
                            icon: Icons.people_rounded,
                            isLoading: false,
                            onPressed: _navigating ? null : _connect,
                          ),

                        if (isConnecting)
                          MenuButton(
                            title: 'Conectando...',
                            icon: Icons.sync,
                            isLoading: true,
                            onPressed: null,
                          ),

                        if (isConnected) ...[
                          MenuButton(
                            title: 'Entrar al mapa',
                            icon: Icons.play_arrow_rounded,
                            isLoading: _navigating,
                            onPressed: _navigating ? null : _connect,
                          ),
                          const SizedBox(height: 15),
                          MenuButton(
                            title: 'Desconectar',
                            icon: Icons.logout,
                            isSecondary: true,
                            onPressed: _disconnect,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ── Pie ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  kMultiplayerServerUrl,
                  style: TextStyle(
                    color: theme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusTitle(MultiplayerStatus s) => switch (s) {
        MultiplayerStatus.disconnected => 'Sin conexión',
        MultiplayerStatus.connecting => 'Conectando...',
        MultiplayerStatus.connected => '¡Conectado!',
        MultiplayerStatus.error => 'Error de conexión',
      };

  String _statusSubtitle(MultiplayerStatus s, String name) => switch (s) {
        MultiplayerStatus.disconnected =>
          'Toca el botón para unirte al servidor\ny jugar como $name.',
        MultiplayerStatus.connecting =>
          'Estableciendo conexión con el servidor...',
        MultiplayerStatus.connected =>
          'Listo para explorar con otros jugadores.',
        MultiplayerStatus.error =>
          'No se pudo alcanzar el servidor.\nVerifica tu conexión.',
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
      child: Icon(icon, size: 90, color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
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