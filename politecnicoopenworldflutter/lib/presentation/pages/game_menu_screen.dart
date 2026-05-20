import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/session_providers.dart';
import '../state/player_movement_notifier.dart';
import '../widgets/menu_button.dart';
import 'game_settings_screen.dart';
import 'start_menu_screen.dart';

/// Menú de pausa accesible desde el mapa. Se renderiza como una capa
/// translúcida sobre el [WorldMapScreen] (estilo Minecraft): el mapa y el
/// marcador del jugador permanecen visibles detrás de un velo oscuro.
/// Permite continuar, guardar, configurar o salir al menú principal.
/// Se adapta de forma responsiva a pantallas verticales y horizontales para
/// que todo quepa sin hacer scroll.
class GameMenuScreen extends ConsumerWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // Velo oscuro semitransparente que deja ver el mapa de fondo.
        color: Colors.black.withValues(alpha: 0.55),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, theme),
              Expanded(
                // LayoutBuilder exposes constraints dynamically to determine device orientation
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape =
                        constraints.maxWidth > constraints.maxHeight;

                    if (isLandscape) {
                      return _buildLandscapeLayout(context, ref, theme);
                    } else {
                      return _buildPortraitLayout(context, ref, theme);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: theme.textPrimary, size: 28),
            tooltip: 'Continuar',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Vertical layout view layout (Portrait)
  Widget _buildPortraitLayout(
      BuildContext context, WidgetRef ref, AppTheme theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 90,
              color: theme.textSecondary,
            ),
            const SizedBox(height: 15),
            Text(
              'Menú de Pausa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            MenuButton(
              title: 'Continuar',
              icon: Icons.play_arrow_rounded,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 15),
            MenuButton(
              title: 'Guardar partida',
              icon: Icons.save_outlined,
              isSecondary: true,
              onPressed: () => _handleSaveGame(context, ref),
            ),
            const SizedBox(height: 15),
            MenuButton(
              title: 'Configuración',
              icon: Icons.settings_outlined,
              isSecondary: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GameSettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 15),
            MenuButton(
              title: 'Salir al menú principal',
              icon: Icons.exit_to_app,
              isSecondary: true,
              onPressed: () => _confirmExit(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal layout view layout (Landscape)
  /// Splits your screen cleanly into two halves: Header info on the left, buttons grid on the right.
  Widget _buildLandscapeLayout(
      BuildContext context, WidgetRef ref, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Header Branding & Icon Status
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pause_circle_outline,
                  size: 75,
                  color: theme.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  'Menú de Pausa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // Right Side: 2x2 Clean Grid of interactive controls without forcing a scroll down
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                physics:
                    const NeverScrollableScrollPhysics(), // Evita scroll innecesario ya que todo cabe
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MenuButton(
                      title: 'Continuar',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      title: 'Guardar partida',
                      icon: Icons.save_outlined,
                      isSecondary: true,
                      onPressed: () => _handleSaveGame(context, ref),
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      title: 'Configuración',
                      icon: Icons.settings_outlined,
                      isSecondary: true,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameSettingsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      title: 'Salir al menú principal',
                      icon: Icons.exit_to_app,
                      isSecondary: true,
                      onPressed: () => _confirmExit(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gestiona el guardado asíncrono leyendo la posición actual y enviándola a Drift
  Future<void> _handleSaveGame(BuildContext context, WidgetRef ref) async {
    /// Verificación de seguridad recomendada por Copilot
    final currentSession = ref.read(activeGameSessionProvider).value;
    if (currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay partida activa para guardar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Salimos temprano para no mostrar éxito falso
    }

    // 1. Obtenemos la posición actual exacta del jugador en el mapa
    final currentPosition = ref.read(playerMovementProvider);

    try {
      // 2. Invocamos al notifier para actualizar la BD local de SQLite en segundo plano
      await ref.read(activeGameSessionProvider.notifier).saveCurrentPosition(
            currentPosition.latitude,
            currentPosition.longitude,
          );

      // Esto borra la caché de la RAM y fuerza a que la próxima vez que entres
      // a "Cargar Partida", se lean los datos recién guardados de la BD.
      ref.invalidate(allGameSessionsProvider);

      // Verificación de seguridad si el widget fue destruido del árbol de UI durante la espera
      if (!context.mounted) return;

      // 3. Mostramos feedback positivo al usuario mediante un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('¡Partida guardada exitosamente!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Plan de contingencia si la base de datos devuelve un error (ej. disco lleno o bloqueo)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la partida: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir al menú principal'),
        content: const Text(
          '¿Seguro que deseas salir? Si no has guardado tu partida, '
          'se perderá el progreso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    ref.read(activeGameSessionProvider.notifier).clear();
    if (!context.mounted) return;

    await ref
        .read(activeGameSessionProvider.notifier)
        .deactivateActiveSession();
    ref.invalidate(allGameSessionsProvider);
    if (!context.mounted) return;

    // pushAndRemoveUntil limpia todo el stack: deja solo StartMenuScreen.
    // El WorldMapScreen, sus controles y el estado de movimiento se
    // destruyen cuando sus widgets salen del árbol.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartMenuScreen()),
      (route) => false,
    );
  }
}
