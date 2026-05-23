import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:politecnicoopenworldflutter/data/local/pow_database.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // IMPORTANTE: Usamos .memory() para que el test no busque carpetas en Windows
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('La base de datos debe insertar y recuperar un tile correctamente', () async {
    final tile = MapTilesCompanion.insert(
      provider: 'OSM',
      zoom: 15,
      x: 10,
      y: 20,
      data: Uint8List(0),
      lastAccessed: DateTime.now().millisecondsSinceEpoch,
    );

    await database.into(database.mapTiles).insert(tile);
    
    final allTiles = await database.select(database.mapTiles).get();
    
    expect(allTiles.length, 1);
    expect(allTiles.first.provider, 'OSM');
  });
}