import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/game_session_repository.dart';
import '../../domain/entities/game_session.dart';

/// Mantiene el estado de la partida activa.
///
/// Toda la UI consulta y muta el estado de la partida a través de este
/// notifier, nunca tocando el repositorio directamente. Así cada pantalla
/// permanece desacoplada del backend de persistencia.
class GameSessionNotifier extends StateNotifier<AsyncValue<GameSession?>> {
  final GameSessionRepository _repository;

  GameSessionNotifier(this._repository)
      : super(const AsyncValue.data(null));

  /// Crea una nueva partida y la deja en estado activo.
  Future<GameSession> startNewSession({
    required String characterId,
    required String characterName,
    required double spawnLat,
    required double spawnLon,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await _repository.createSession(
        characterId: characterId,
        characterName: characterName,
        spawnLat: spawnLat,
        spawnLon: spawnLon,
      );
      state = AsyncValue.data(session);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reanuda una partida existente por id, marcándola como activa.
  Future<GameSession?> resume(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resume(sessionId);
      final session = await _repository.getById(sessionId);
      state = AsyncValue.data(session);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Persiste la posición actual del jugador en la partida activa.
  /// Lanza [StateError] si no hay partida cargada.
  Future<void> saveCurrentPosition(double lat, double lon) async {
    final current = state.value;
    if (current == null) {
      throw StateError('No hay partida activa para guardar.');
    }
    await _repository.updatePosition(
      sessionId: current.id,
      lat: lat,
      lon: lon,
    );
    state = AsyncValue.data(current.copyWith(
      lastLat: lat,
      lastLon: lon,
      updatedAt: DateTime.now(),
    ));
  }

  /// Limpia el estado (no borra la partida de la BD).
  void clear() {
    state = const AsyncValue.data(null);
  }

  /// Marca que no hay ninguna partida activa en la BD y en memoria.
  Future<void> deactivateActiveSession() async {
    await _repository.clearActive();
    clear();
  }
}
