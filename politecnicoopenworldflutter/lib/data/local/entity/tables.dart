import 'package:drift/drift.dart';

// Equivalente a MapTileEntity
class MapTiles extends Table {
  TextColumn get provider => text()();
  IntColumn get zoom => integer()();
  IntColumn get x => integer()();
  IntColumn get y => integer()();
  BlobColumn get data => blob()();
  IntColumn get lastAccessed => integer()();

  @override
  Set<Column> get primaryKey => {provider, zoom, x, y};
}

// Equivalente a RoadZoneEntity
class RoadZones extends Table {
  TextColumn get cellKey => text()();
  IntColumn get timestamp => integer()();

  @override
  Set<Column> get primaryKey => {cellKey};
}

// Equivalente a RoadWayEntity
class RoadWays extends Table {
  IntColumn get wayId => integer()();
  TextColumn get cellKey =>
      text().references(RoadZones, #cellKey, onDelete: KeyAction.cascade)();
  BoolColumn get isForCars => boolean()();
  BoolColumn get isForPeople => boolean()();

  /// Direccionalidad de la way según OSM:
  ///   'both'     → sin restricción (default)
  ///   'forward'  → solo en el sentido de los nodos
  ///   'backward' → solo en el sentido inverso
  TextColumn get direction =>
      text().withDefault(const Constant('both'))();

  @override
  Set<Column> get primaryKey => {wayId, cellKey};
}

// Equivalente a RoadNodeEntity
class RoadNodes extends Table {
  IntColumn get nodeId => integer()();
  IntColumn get wayId => integer()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  IntColumn get sequenceIndex => integer()();
}