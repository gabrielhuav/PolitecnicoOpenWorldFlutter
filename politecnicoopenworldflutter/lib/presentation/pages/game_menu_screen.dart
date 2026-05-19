import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/session_providers.dart'; 
import '../state/game_session_notifier.dart';     
import '../state/player_movement_notifier.dart';  
import '../widgets/menu_button.dart';
import 'game_settings_screen.dart';
import 'start_menu_screen.dart';

/// Menú de pausa accesible desde el mapa. Se navega con push (no
/// pushReplacement) para que el WorldMapScreen siga vivo en el stack
/// y "Continuar" sea un simple Navigator.pop.
class GameMenuScreen extends ConsumerWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Column(
            children: [
              _buildTopBar(context, theme),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
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
                          onPressed: () => _confirmExit(context),
                        ),
                      ],
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
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

 /// Gestiona el guardado asíncrono leyendo la posición actual y enviándola a Drift
  Future<void> _handleSaveGame(BuildContext context, WidgetRef ref) async {
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

  Future<void> _confirmExit(BuildContext context) async {
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
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