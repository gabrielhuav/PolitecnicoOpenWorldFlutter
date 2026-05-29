import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/theme/app_theme.dart';
import '../../../ui/theme/theme_extensions.dart';
import '../../../domain/models/game_session.dart';
import '../../map_exterior/state/session_providers.dart';
import '../../map_exterior/ui/loading_screen.dart';
import 'components/session_list_tile.dart';

/// Pantalla "Cargar Partida". Muestra todas las partidas guardadas y
/// permite reanudarlas o eliminarlas.
class LoadGameScreen extends ConsumerWidget {
  const LoadGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;
    // Escuchamos la lista de partidas desde SQLite
    final sessionsAsync = ref.watch(allGameSessionsProvider);

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
              _buildHeader(context, theme),
              Expanded(
                child: sessionsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: theme.accentSecondary,
                    ),
                  ),
                  error: (e, _) => _buildError(e.toString()),
                  data: (sessions) =>
                      _buildSessionList(context, ref, theme, sessions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.textPrimary, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Cargar Partida',
            style: TextStyle(
              color: theme.textPrimary,
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
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
    List<GameSession> sessions,
  ) {
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, color: theme.textTertiary, size: 64),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes partidas guardadas.\n'
                'Empieza una nueva aventura para crear la primera.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: theme.accentSecondary,
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
            theme: theme,
            onResume: () => _resume(context, session),
            onDelete: () => _confirmDelete(context, ref, session),
          );
        },
      ),
    );
  }

  Future<void> _resume(
    BuildContext context,
    GameSession session,
  ) async {
    final navigator = Navigator.of(context);

    // Removemos la carga de la BD y la teletransportación de este método.
    // Ahora, en el instante en que tocas la partida, la app reemplaza de inmediato
    // esta pantalla por la de carga ('LoadingScreen'), pasándole el ID y la bandera de reanudación.
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoadingScreen(
          isResuming: true,
          resumeSessionId: session.id,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    GameSession session,
  ) async {
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
