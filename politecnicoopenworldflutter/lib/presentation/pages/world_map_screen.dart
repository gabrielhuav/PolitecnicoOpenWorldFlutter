import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos el archivo global de providers
import '../../core/utils/providers.dart';
import 'start_menu_screen.dart';
import '../widgets/game_controls.dart';

// Usamos ConsumerWidget para escuchar el estado general del mapa
class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  // Riverpod inyecta la variable "ref" automáticamente en el método build
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los cambios del mapa en tiempo real
    final mapProvider = ref.watch(mapStateProvider);

    // 1. Estado de Carga
    if (mapProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Estado de Error
    if (mapProvider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                mapProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StartMenuScreen()),
                  );
                },
                child: const Text('Volver al Menú'),
              )
            ],
          ),
        ),
      );
    }

    // 3. Estado de Éxito: El Mapa y la Interfaz
    return Scaffold(
      body: Stack(
        children: [
          // CAPA 0: EL MAPA
          _buildMapCanvas(mapProvider),

          // CAPA 1: BOTÓN DE REGRESO
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StartMenuScreen()),
                );
              },
              child: const Icon(Icons.menu),
            ),
          ),

          // CAPA 2: CONTROLES DEL JUGADOR
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GameControls(),
          ),
        ],
      ),
    );
  }

  // Área interactiva donde eventualmente se dibujarán los nodos del mundo
  Widget _buildMapCanvas(dynamic provider) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 4.0,
      child: Container(
        color: const Color(0xFFE8E5DF), // Color tipo "terreno"
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 80, color: Colors.black26),
              const SizedBox(height: 10),
              Text(
                'Mundo Generado\nNodos cargados: ${provider.nodes.length}\nVías cargadas: ${provider.ways.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
