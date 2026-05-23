import 'package:drift/drift.dart';

import 'tables_session.dart';

/// Tabla persistente de ubicaciones guardadas por partida.
///
/// Aislada en su propio archivo (ver tables_session.dart para el mismo
/// patrón) para permitir trabajo en paralelo sobre distintas tablas.
@DataClassName('SavedLocationRow')
class SavedLocations extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(GameSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  TextColumn get kind => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
