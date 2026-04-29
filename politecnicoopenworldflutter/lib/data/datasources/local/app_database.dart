import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

// Este archivo será generado automáticamente en el Paso 4
part 'app_database.g.dart';

@DriftDatabase(tables: [MapTiles, RoadZones, RoadWays, RoadNodes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pow_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}