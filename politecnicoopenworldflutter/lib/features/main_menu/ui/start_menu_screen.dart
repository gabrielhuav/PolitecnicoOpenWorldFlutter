import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/theme/theme_extensions.dart';
import '../../../../multiplayer/multiplayer_screen.dart';
import '../../settings/ui/app_settings_screen.dart';
import '../../settings/ui/game_settings_screen.dart';
import 'character_selection_screen.dart';
import 'components/menu_button.dart';
import 'load_game_screen.dart';

class StartMenuScreen extends ConsumerWidget {
  const StartMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.backgroundGradient,
              ),
            ),
            child: SafeArea(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  return orientation == Orientation.portrait
                      ? const _PortraitLayout()
                      : const _LandscapeLayout();
                },
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Icon(Icons.settings,
                      color: theme.textSecondary, size: 28),
                  tooltip: 'Ajustes de la aplicación',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AppSettingsScreen()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LogoAndTitle(),
              SizedBox(height: 60),
              _ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SingleChildScrollView(child: _LogoAndTitle()),
            ),
            SizedBox(width: 40),
            Expanded(
              child: SingleChildScrollView(child: _ActionButtons()),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoAndTitle extends ConsumerWidget {
  const _LogoAndTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.map_outlined, size: 90, color: theme.textSecondary),
        const SizedBox(height: 15),
        Text(
          'Politécnico\nOpen World',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
            letterSpacing: 2.0,
            shadows: const [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({Key? key}) : super(key: key);

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _isNavigating = false;

  Future<void> _goToCharacterSelection() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CharacterSelectionScreen()),
    ).then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  void _goToLoadGame() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoadGameScreen()),
    ).then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  /// Navega a la pantalla de multijugador.
  /// MultiplayerScreen gestiona su propia conexión; el singleplayer
  /// (CharacterSelectionScreen → LoadingScreen → WorldMapScreen) nunca
  /// toca multiplayerProvider, así que los dos modos son completamente
  /// independientes.
  void _goToMultiplayer() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MultiplayerScreen()),
    ).then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuButton(
          title: 'Empezar Aventura',
          icon: Icons.play_arrow_rounded,
          isLoading: _isNavigating,
          onPressed: _goToCharacterSelection,
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Cargar Partida',
          icon: Icons.folder_open_rounded,
          isSecondary: true,
          onPressed: _isNavigating ? null : _goToLoadGame,
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Multijugador',
          icon: Icons.people_outline,
          isSecondary: true,
          // Reemplaza el SnackBar de "Próximamente" por la pantalla real.
          onPressed: _isNavigating ? null : _goToMultiplayer,
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Configuración',
          icon: Icons.videogame_asset_outlined,
          isSecondary: true,
          onPressed: _isNavigating
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GameSettingsScreen()),
                  );
                },
        ),
      ],
    );
  }
}