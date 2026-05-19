import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables_session.dart';
import '../../../../domain/entities/game_session.dart';

/// Acceso de bajo nivel a la tabla [GameSessions].
///
/// Es una clase Dart plana (no usa @DriftAccessor) para que su evolución no
/// requiera regenerar parts de Drift más allá del propio app_database.g.dart
/// y para que cada desarrollador pueda iterar sobre su DAO sin tocar el
/// archivo central de la base de datos.
class GameSessionDao {
  final AppDatabase _db;

  GameSessionDao(this._db);

  /// Inserta una nueva fila. Sustituye si el id ya existe.
  Future<void> upsert(GameSession session) {
    return _db.into(_db.gameSessions).insertOnConflictUpdate(
          GameSessionsCompanion(
            id: Value(session.id),
            characterId: Value(session.characterId),
            characterName: Value(session.characterName),
            createdAt: Value(session.createdAt.millisecondsSinceEpoch),
            updatedAt: Value(session.updatedAt.millisecondsSinceEpoch),
            lastLat: Value(session.lastLat),
            lastLon: Value(session.lastLon),
            isActive: Value(session.isActive),
          ),
        );
  }

  /// Actualiza solo la posición y la marca de tiempo (uso típico al guardar).
  Future<int> updatePosition({
    required String sessionId,
    required double lat,
    required double lon,
    required DateTime updatedAt,
  }) {
    return (_db.update(_db.gameSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(GameSessionsCompanion(
      lastLat: Value(lat),
      lastLon: Value(lon),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    ));
  }

  /// Marca una partida como activa y desactiva todas las demás en una
  /// sola transacción.
  Future<void> setActive(String sessionId) {
    return _db.transaction(() async {
      await _db
          .update(_db.gameSessions)
          .write(const GameSessionsCompanion(isActive: Value(false)));
      await (_db.update(_db.gameSessions)
            ..where((t) => t.id.equals(sessionId)))
          .write(const GameSessionsCompanion(isActive: Value(true)));
    });
  }

  /// Devuelve la partida activa si existe.
  Future<GameSession?> getActive() async {
    final row = await (_db.select(_db.gameSessions)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Lista todas las partidas, más reciente primero.
  Future<List<GameSession>> listAll() async {
    final rows = await (_db.select(_db.gameSessions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  /// Lee una partida por id.
  Future<GameSession?> getById(String id) async {
    final row = await (_db.select(_db.gameSessions)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Elimina una partida (las ubicaciones asociadas caen por CASCADE).
  Future<int> deleteById(String id) {
    return (_db.delete(_db.gameSessions)..where((t) => t.id.equals(id))).go();
  }

  // ── Mapeo interno fila Drift -> entidad de dominio ───────────────────
  GameSession _toDomain(GameSessionRow row) {
    return GameSession(
      id: row.id,
      characterId: row.characterId,
      characterName: row.characterName,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      lastLat: row.lastLat,
      lastLon: row.lastLon,
      isActive: row.isActive,
    );
  }
}
