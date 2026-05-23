import 'package:drift/drift.dart';

/// Tabla persistente de partidas guardadas.
///
/// Se mantiene en su propio archivo para que un solo desarrollador pueda
/// modificar el esquema de partidas sin tocar tables.dart ni
/// tables_location.dart y minimizar conflictos de merge.
@DataClassName('GameSessionRow')
class GameSessions extends Table {
  TextColumn get id => text()();
  TextColumn get characterId => text()();
  TextColumn get characterName => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  RealColumn get lastLat => real()();
  RealColumn get lastLon => real()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
