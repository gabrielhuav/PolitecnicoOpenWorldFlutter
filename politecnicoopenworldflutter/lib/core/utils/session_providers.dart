import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/daos/game_session_dao.dart';
import '../../data/datasources/local/daos/saved_location_dao.dart';
import '../../data/repositories/game_session_repository.dart';
import '../../data/repositories/saved_location_repository.dart';
import '../../domain/entities/game_session.dart';
import '../../presentation/state/game_session_notifier.dart';
import 'providers.dart';

/// Providers para todo lo relacionado con persistencia de partidas.
///
/// Mantenidos en su propio archivo para no interferir con `providers.dart`
/// (DB, mapa) ni con `location_providers.dart` (GPS).

// ── DAOs ─────────────────────────────────────────────────────────────
final gameSessionDaoProvider = Provider<GameSessionDao>((ref) {
  return GameSessionDao(ref.read(localDbProvider));
});

final savedLocationDaoProvider = Provider<SavedLocationDao>((ref) {
  return SavedLocationDao(ref.read(localDbProvider));
});

// ── Repositorios ─────────────────────────────────────────────────────
final gameSessionRepositoryProvider = Provider<GameSessionRepository>((ref) {
  return GameSessionRepository(ref.read(gameSessionDaoProvider));
});

final savedLocationRepositoryProvider =
    Provider<SavedLocationRepository>((ref) {
  return SavedLocationRepository(ref.read(savedLocationDaoProvider));
});

// ── Estado de la partida activa ──────────────────────────────────────
/// Notifier que mantiene la partida actualmente activa en memoria.
final activeGameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, AsyncValue<GameSession?>>((ref) {
  return GameSessionNotifier(ref.read(gameSessionRepositoryProvider));
});

/// Lista de todas las partidas guardadas, para la pantalla "Cargar partida".
final allGameSessionsProvider = FutureProvider<List<GameSession>>((ref) {
  return ref.read(gameSessionRepositoryProvider).listAll();
});
