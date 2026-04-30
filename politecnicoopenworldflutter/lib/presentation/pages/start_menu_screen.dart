import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos la pantalla de selección de personaje y el widget del botón
import 'character_selection_screen.dart';
import '../widgets/menu_button.dart';

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
    );
  }
}

// --- VERTICAL ---
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

// --- HORIZONTAL ---
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

// --- LOGO Y TÍTULO ---
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

// --- BOTONES Y NAVEGACIÓN ---
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

    // Pequeño "tick" visual para que el spinner alcance a verse en la transición.
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterSelectionScreen(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
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
          onPressed: _isNavigating
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Buscando partidas guardadas...')),
                  );
                },
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Configuración',
          icon: Icons.settings,
          isSecondary: true,
          onPressed: _isNavigating
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Configuración próximamente...')),
                  );
                },
        ),
      ],
    );
  }
}
