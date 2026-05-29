import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importa tu provider real del mapa
import '../../state/map_providers.dart';
import '../../../../data/repository/map_repository_impl.dart';

class MapStatusIndicator extends ConsumerWidget {
  const MapStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los cambios del provider que controla tu MapRepository
    final mapState = ref.watch(mapStateProvider);
    final progress = mapState.progress;

    IconData icon;
    String text;
    Color color;

    // Lógica para determinar qué mostrar basado en la fase de carga
    if (mapState.isLoading) {
      switch (progress.phase) {
        case MapLoadPhase.downloading:
          icon = Icons.cloud_download;
          text = 'Descargando mundo... ${(progress.fraction * 100).toInt()}%';
          color = Colors.orangeAccent;
        case MapLoadPhase.cached:
          icon = Icons.storage;
          text = progress.status;
          color = Colors.yellowAccent;
        case MapLoadPhase.idle:
          icon = Icons.storage;
          text = progress.status;
          color = Colors.yellowAccent;
        case MapLoadPhase.done:
          icon = Icons.cloud_done;
          text = progress.status;
          color = Colors.greenAccent;
      }
    } else if (mapState.errorMessage != null) {
      // Manejo de errores
      icon = Icons.error_outline;
      text = 'Error de red';
      color = Colors.redAccent;
    } else {
      // Si no está cargando y no hay error, el mapa actual está en memoria/caché
      icon = Icons.cloud_done;
      text = 'Zona Descargada';
      color = Colors.greenAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}