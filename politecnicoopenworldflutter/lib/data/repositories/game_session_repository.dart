import 'package:uuid/uuid.dart';

import '../../domain/entities/game_session.dart';
import '../datasources/local/daos/game_session_dao.dart';

/// Capa de orquestación sobre [GameSessionDao]. La UI y el state notifier
/// hablan solo con esta clase y nunca tocan Drift directamente.
class GameSessionRepository {
  final GameSessionDao _dao;
  final Uuid _uuid;

  GameSessionRepository(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Crea una partida nueva, la marca como activa y la devuelve.
  Future<GameSession> createSession({
    required String characterId,
    required String characterName,
    required double spawnLat,
    required double spawnLon,
  }) async {
    final now = DateTime.now();
    final session = GameSession(
      id: _uuid.v4(),
      characterId: characterId,
      characterName: characterName,
      createdAt: now,
      updatedAt: now,
      lastLat: spawnLat,
      lastLon: spawnLon,
      isActive: true,
    );
    await _dao.upsert(session);
    await _dao.setActive(session.id);
    return session;
  }

  Future<GameSession?> getActive() => _dao.getActive();

  Future<List<GameSession>> listAll() => _dao.listAll();

  Future<GameSession?> getById(String id) => _dao.getById(id);

  Future<void> updatePosition({
    required String sessionId,
    required double lat,
    required double lon,
  }) {
    return _dao.updatePosition(
      sessionId: sessionId,
      lat: lat,
      lon: lon,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> resume(String sessionId) => _dao.setActive(sessionId);

  Future<void> delete(String sessionId) => _dao.deleteById(sessionId);
}
