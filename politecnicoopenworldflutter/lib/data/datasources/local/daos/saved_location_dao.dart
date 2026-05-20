import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables_location.dart';
import '../../../../domain/entities/saved_location.dart';

/// Acceso de bajo nivel a la tabla [SavedLocations].
class SavedLocationDao {
  final AppDatabase _db;

  SavedLocationDao(this._db);

  Future<void> insert(SavedLocation location) {
    return _db.into(_db.savedLocations).insertOnConflictUpdate(
          SavedLocationsCompanion(
            id: Value(location.id),
            sessionId: Value(location.sessionId),
            label: Value(location.label),
            lat: Value(location.lat),
            lon: Value(location.lon),
            kind: Value(location.kind.storageValue),
            createdAt: Value(location.createdAt.millisecondsSinceEpoch),
          ),
        );
  }

  Future<List<SavedLocation>> listForSession(String sessionId) async {
    final rows = await (_db.select(_db.savedLocations)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  Future<int> deleteById(String id) {
    return (_db.delete(_db.savedLocations)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllForSession(String sessionId) {
    return (_db.delete(_db.savedLocations)
          ..where((t) => t.sessionId.equals(sessionId)))
        .go();
  }

  SavedLocation _toDomain(SavedLocationRow row) {
    return SavedLocation(
      id: row.id,
      sessionId: row.sessionId,
      label: row.label,
      lat: row.lat,
      lon: row.lon,
      kind: SavedLocationKind.fromStorage(row.kind),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}
