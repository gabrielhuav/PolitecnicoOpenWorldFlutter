import 'package:flutter/material.dart';
import 'world_map_screen.dart'; // Asegúrate de que esta ruta sea correcta
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
        // SafeArea evita que la interfaz se meta en el "notch" o la barra de estado
        child: SafeArea(
          // OrientationBuilder detecta los giros de pantalla
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
            // Lado Izquierdo: Título e Icono
            Expanded(
              child: SingleChildScrollView(
                child: _LogoAndTitle(),
              ),
            ),
            SizedBox(width: 40), // Espacio en el centro
            // Lado Derecho: Botones
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
// COMPONENTES REUTILIZABLES (Como clases puras)
// ==========================================

class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuButton(
          title: 'Empezar Aventura',
          icon: Icons.play_arrow_rounded,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // NOTA: Si aquí te marca error rojo, quítale el "const" a WorldMapScreen()
                builder: (context) => const WorldMapScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Cargar Partida',
          icon: Icons.folder_open_rounded,
          isSecondary: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Buscando partidas guardadas...')),
            );
          },
        ),
        const SizedBox(height: 15),
        MenuButton(
          title: 'Configuración',
          icon: Icons.settings,
          isSecondary: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuración próximamente...')),
            );
          },
        ),
      ],
    );
  }
}
