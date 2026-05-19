import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings_screen.dart';
import 'character_selection_screen.dart';
import 'debug_log_screen.dart';
import 'game_settings_screen.dart';
import 'load_game_screen.dart';
import '../widgets/menu_button.dart';

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo + contenido principal ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
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

          // ── Botón ajustes de app (top-right) ─────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.settings,
                      color: Colors.white70, size: 28),
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

// ── Layout vertical ──────────────────────────────────────────────────
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

// ── Layout horizontal ────────────────────────────────────────────────
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

// ── Logo y título ────────────────────────────────────────────────────
class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.map_outlined, size: 90, color: Colors.white70),
        SizedBox(height: 15),
        Text(
          'Politécnico\nOpen World',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
            shadows: [
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

// ── Botones de acción ────────────────────────────────────────────────
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoadGameScreen()),
    );
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
          onPressed: _isNavigating
              ? null
              : _goToLoadGame,
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

        // ── Solo visible en modo debug ────────────────────────────────
        if (kDebugMode) ...[
          const SizedBox(height: 15),
          MenuButton(
            title: 'Registros de depuración',
            icon: Icons.bug_report_outlined,
            isSecondary: true,
            onPressed: _isNavigating
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DebugLogScreen()),
                    );
                  },
          ),
        ],
      ],
    );
  }
}
