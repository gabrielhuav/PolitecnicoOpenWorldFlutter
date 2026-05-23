import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'entity/tables.dart';
import 'entity/tables_session.dart';
import 'entity/tables_location.dart';

// Archivo generado por build_runner.
part 'pow_database.g.dart';

@DriftDatabase(
  tables: [
    // Tablas existentes (v1)
    MapTiles,
    RoadZones,
    RoadWays,
    RoadNodes,
    // Tablas nuevas (v2)
    GameSessions,
    SavedLocations,
  ],
)
class PowDatabase extends _$PowDatabase {
  PowDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(gameSessions);
            await m.createTable(savedLocations);
          }
        },
        beforeOpen: (details) async {
          // Habilita FKs (necesario para que el ON DELETE CASCADE de
          // saved_locations -> game_sessions funcione).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pow_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}