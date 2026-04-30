import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos el archivo global de providers
import '../../core/utils/providers.dart';
import 'world_map_screen.dart';
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
              if (orientation == Orientation.portrait) {
                return const _PortraitLayout();
              } else {
                return const _LandscapeLayout();
              }
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================
// DISEÑO VERTICAL (Portrait)
// ==========================================
class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
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

// ==========================================
// DISEÑO HORIZONTAL (Landscape)
// ==========================================
class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Expanded(
              child: SingleChildScrollView(
                child: _LogoAndTitle(),
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              child: SingleChildScrollView(
                child: _ActionButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// COMPONENTES REUTILIZABLES
// ==========================================
class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.map_outlined,
          size: 90,
          color: Colors.white70,
        ),
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

// Usamos ConsumerStatefulWidget para tener estado local (el spinner) y leer a Riverpod
class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({Key? key}) : super(key: key);

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _isLoadingMap = false;

  Future<void> _startPreloading() async {
    setState(() {
      _isLoadingMap = true;
    });

    try {
      // AQUÍ LA MAGIA DE RIVERPOD: Usamos ref.read() para llamar a la función sin escuchar reconstrucciones
      final mapProv = ref.read(mapStateProvider.notifier);

      await mapProv.loadInitialMapData();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WorldMapScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el mapa: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMap = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuButton(
          title: 'Empezar Aventura',
          icon: Icons.play_arrow_rounded,
          isLoading: _isLoadingMap,
          onPressed: _startPreloading,
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Cargar Partida',
          icon: Icons.folder_open_rounded,
          isSecondary: true,
          onPressed: _isLoadingMap
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
          onPressed: _isLoadingMap
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
