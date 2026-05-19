import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
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
                          onPressed: () => _showSavePlaceholder(context),
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

  void _showSavePlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardado de partidas próximamente...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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