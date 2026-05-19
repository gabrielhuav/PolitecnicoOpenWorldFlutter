import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/session_providers.dart';
import '../../domain/entities/game_session.dart';
import '../state/player_movement_notifier.dart';
import '../widgets/session_list_tile.dart';
import 'world_map_screen.dart';

/// Pantalla "Cargar Partida". Muestra todas las partidas guardadas y
/// permite reanudarlas o eliminarlas.
class LoadGameScreen extends ConsumerWidget {
  const LoadGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allGameSessionsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1220),
              Color(0xFF152234),
              Color(0xFF1F3A5F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: sessionsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  ),
                  error: (e, _) => _buildError(e.toString()),
                  data: (sessions) =>
                      _buildSessionList(context, ref, sessions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Cargar Partida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No se pudieron cargar las partidas:\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildSessionList(
      BuildContext context, WidgetRef ref, List<GameSession> sessions) {
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, color: Colors.white24, size: 64),
              SizedBox(height: 16),
              Text(
                'Aún no tienes partidas guardadas.\nEmpieza una nueva aventura para crear la primera.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.tealAccent,
      onRefresh: () async {
        ref.invalidate(allGameSessionsProvider);
        await ref.read(allGameSessionsProvider.future);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sessions.length,
        itemBuilder: (context, i) {
          final session = sessions[i];
          return SessionListTile(
            session: session,
            onResume: () => _resume(context, ref, session),
            onDelete: () => _confirmDelete(context, ref, session),
          );
        },
      ),
    );
  }

  Future<void> _resume(
      BuildContext context, WidgetRef ref, GameSession session) async {
    final navigator = Navigator.of(context);
    final notifier = ref.read(activeGameSessionProvider.notifier);
    await notifier.resume(session.id);

    // Coloca al jugador en la última ubicación guardada.
    ref
        .read(playerMovementProvider.notifier)
        .teleport(LatLng(session.lastLat, session.lastLon));

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const WorldMapScreen()),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, GameSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar partida'),
        content: Text(
          '¿Seguro que deseas eliminar la partida de '
          '${session.characterName}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(gameSessionRepositoryProvider).delete(session.id);
    ref.invalidate(allGameSessionsProvider);
  }
}
