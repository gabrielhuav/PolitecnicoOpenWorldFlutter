// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MapTilesTable extends MapTiles with TableInfo<$MapTilesTable, MapTile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapTilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _zoomMeta = const VerificationMeta('zoom');
  @override
  late final GeneratedColumn<int> zoom = GeneratedColumn<int>(
      'zoom', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
      'x', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
      'y', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _lastAccessedMeta =
      const VerificationMeta('lastAccessed');
  @override
  late final GeneratedColumn<int> lastAccessed = GeneratedColumn<int>(
      'last_accessed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [provider, zoom, x, y, data, lastAccessed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_tiles';
  @override
  VerificationContext validateIntegrity(Insertable<MapTile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('zoom')) {
      context.handle(
          _zoomMeta, zoom.isAcceptableOrUnknown(data['zoom']!, _zoomMeta));
    } else if (isInserting) {
      context.missing(_zoomMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('last_accessed')) {
      context.handle(
          _lastAccessedMeta,
          lastAccessed.isAcceptableOrUnknown(
              data['last_accessed']!, _lastAccessedMeta));
    } else if (isInserting) {
      context.missing(_lastAccessedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provider, zoom, x, y};
  @override
  MapTile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapTile(
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      zoom: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}zoom'])!,
      x: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}x'])!,
      y: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}y'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data'])!,
      lastAccessed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_accessed'])!,
    );
  }

  @override
  $MapTilesTable createAlias(String alias) {
    return $MapTilesTable(attachedDatabase, alias);
  }
}

class MapTile extends DataClass implements Insertable<MapTile> {
  final String provider;
  final int zoom;
  final int x;
  final int y;
  final Uint8List data;
  final int lastAccessed;
  const MapTile(
      {required this.provider,
      required this.zoom,
      required this.x,
      required this.y,
      required this.data,
      required this.lastAccessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider'] = Variable<String>(provider);
    map['zoom'] = Variable<int>(zoom);
    map['x'] = Variable<int>(x);
    map['y'] = Variable<int>(y);
    map['data'] = Variable<Uint8List>(data);
    map['last_accessed'] = Variable<int>(lastAccessed);
    return map;
  }

  MapTilesCompanion toCompanion(bool nullToAbsent) {
    return MapTilesCompanion(
      provider: Value(provider),
      zoom: Value(zoom),
      x: Value(x),
      y: Value(y),
      data: Value(data),
      lastAccessed: Value(lastAccessed),
    );
  }

  factory MapTile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapTile(
      provider: serializer.fromJson<String>(json['provider']),
      zoom: serializer.fromJson<int>(json['zoom']),
      x: serializer.fromJson<int>(json['x']),
      y: serializer.fromJson<int>(json['y']),
      data: serializer.fromJson<Uint8List>(json['data']),
      lastAccessed: serializer.fromJson<int>(json['lastAccessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provider': serializer.toJson<String>(provider),
      'zoom': serializer.toJson<int>(zoom),
      'x': serializer.toJson<int>(x),
      'y': serializer.toJson<int>(y),
      'data': serializer.toJson<Uint8List>(data),
      'lastAccessed': serializer.toJson<int>(lastAccessed),
    };
  }

  MapTile copyWith(
          {String? provider,
          int? zoom,
          int? x,
          int? y,
          Uint8List? data,
          int? lastAccessed}) =>
      MapTile(
        provider: provider ?? this.provider,
        zoom: zoom ?? this.zoom,
        x: x ?? this.x,
        y: y ?? this.y,
        data: data ?? this.data,
        lastAccessed: lastAccessed ?? this.lastAccessed,
      );
  MapTile copyWithCompanion(MapTilesCompanion data) {
    return MapTile(
      provider: data.provider.present ? data.provider.value : this.provider,
      zoom: data.zoom.present ? data.zoom.value : this.zoom,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      data: data.data.present ? data.data.value : this.data,
      lastAccessed: data.lastAccessed.present
          ? data.lastAccessed.value
          : this.lastAccessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapTile(')
          ..write('provider: $provider, ')
          ..write('zoom: $zoom, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('data: $data, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      provider, zoom, x, y, $driftBlobEquality.hash(data), lastAccessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapTile &&
          other.provider == this.provider &&
          other.zoom == this.zoom &&
          other.x == this.x &&
          other.y == this.y &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.lastAccessed == this.lastAccessed);
}

class MapTilesCompanion extends UpdateCompanion<MapTile> {
  final Value<String> provider;
  final Value<int> zoom;
  final Value<int> x;
  final Value<int> y;
  final Value<Uint8List> data;
  final Value<int> lastAccessed;
  final Value<int> rowid;
  const MapTilesCompanion({
    this.provider = const Value.absent(),
    this.zoom = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.data = const Value.absent(),
    this.lastAccessed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MapTilesCompanion.insert({
    required String provider,
    required int zoom,
    required int x,
    required int y,
    required Uint8List data,
    required int lastAccessed,
    this.rowid = const Value.absent(),
  })  : provider = Value(provider),
        zoom = Value(zoom),
        x = Value(x),
        y = Value(y),
        data = Value(data),
        lastAccessed = Value(lastAccessed);
  static Insertable<MapTile> custom({
    Expression<String>? provider,
    Expression<int>? zoom,
    Expression<int>? x,
    Expression<int>? y,
    Expression<Uint8List>? data,
    Expression<int>? lastAccessed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provider != null) 'provider': provider,
      if (zoom != null) 'zoom': zoom,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (data != null) 'data': data,
      if (lastAccessed != null) 'last_accessed': lastAccessed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MapTilesCompanion copyWith(
      {Value<String>? provider,
      Value<int>? zoom,
      Value<int>? x,
      Value<int>? y,
      Value<Uint8List>? data,
      Value<int>? lastAccessed,
      Value<int>? rowid}) {
    return MapTilesCompanion(
      provider: provider ?? this.provider,
      zoom: zoom ?? this.zoom,
      x: x ?? this.x,
      y: y ?? this.y,
      data: data ?? this.data,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (zoom.present) {
      map['zoom'] = Variable<int>(zoom.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (lastAccessed.present) {
      map['last_accessed'] = Variable<int>(lastAccessed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapTilesCompanion(')
          ..write('provider: $provider, ')
          ..write('zoom: $zoom, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('data: $data, ')
          ..write('lastAccessed: $lastAccessed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoadZonesTable extends RoadZones
    with TableInfo<$RoadZonesTable, RoadZone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoadZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cellKeyMeta =
      const VerificationMeta('cellKey');
  @override
  late final GeneratedColumn<String> cellKey = GeneratedColumn<String>(
      'cell_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cellKey, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'road_zones';
  @override
  VerificationContext validateIntegrity(Insertable<RoadZone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cell_key')) {
      context.handle(_cellKeyMeta,
          cellKey.isAcceptableOrUnknown(data['cell_key']!, _cellKeyMeta));
    } else if (isInserting) {
      context.missing(_cellKeyMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cellKey};
  @override
  RoadZone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoadZone(
      cellKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cell_key'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $RoadZonesTable createAlias(String alias) {
    return $RoadZonesTable(attachedDatabase, alias);
  }
}

class RoadZone extends DataClass implements Insertable<RoadZone> {
  final String cellKey;
  final int timestamp;
  const RoadZone({required this.cellKey, required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cell_key'] = Variable<String>(cellKey);
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  RoadZonesCompanion toCompanion(bool nullToAbsent) {
    return RoadZonesCompanion(
      cellKey: Value(cellKey),
      timestamp: Value(timestamp),
    );
  }

  factory RoadZone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoadZone(
      cellKey: serializer.fromJson<String>(json['cellKey']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cellKey': serializer.toJson<String>(cellKey),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  RoadZone copyWith({String? cellKey, int? timestamp}) => RoadZone(
        cellKey: cellKey ?? this.cellKey,
        timestamp: timestamp ?? this.timestamp,
      );
  RoadZone copyWithCompanion(RoadZonesCompanion data) {
    return RoadZone(
      cellKey: data.cellKey.present ? data.cellKey.value : this.cellKey,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoadZone(')
          ..write('cellKey: $cellKey, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cellKey, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoadZone &&
          other.cellKey == this.cellKey &&
          other.timestamp == this.timestamp);
}

class RoadZonesCompanion extends UpdateCompanion<RoadZone> {
  final Value<String> cellKey;
  final Value<int> timestamp;
  final Value<int> rowid;
  const RoadZonesCompanion({
    this.cellKey = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoadZonesCompanion.insert({
    required String cellKey,
    required int timestamp,
    this.rowid = const Value.absent(),
  })  : cellKey = Value(cellKey),
        timestamp = Value(timestamp);
  static Insertable<RoadZone> custom({
    Expression<String>? cellKey,
    Expression<int>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cellKey != null) 'cell_key': cellKey,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoadZonesCompanion copyWith(
      {Value<String>? cellKey, Value<int>? timestamp, Value<int>? rowid}) {
    return RoadZonesCompanion(
      cellKey: cellKey ?? this.cellKey,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cellKey.present) {
      map['cell_key'] = Variable<String>(cellKey.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoadZonesCompanion(')
          ..write('cellKey: $cellKey, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoadWaysTable extends RoadWays with TableInfo<$RoadWaysTable, RoadWay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoadWaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wayIdMeta = const VerificationMeta('wayId');
  @override
  late final GeneratedColumn<int> wayId = GeneratedColumn<int>(
      'way_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cellKeyMeta =
      const VerificationMeta('cellKey');
  @override
  late final GeneratedColumn<String> cellKey = GeneratedColumn<String>(
      'cell_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES road_zones (cell_key) ON DELETE CASCADE'));
  static const VerificationMeta _isForCarsMeta =
      const VerificationMeta('isForCars');
  @override
  late final GeneratedColumn<bool> isForCars = GeneratedColumn<bool>(
      'is_for_cars', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_for_cars" IN (0, 1))'));
  static const VerificationMeta _isForPeopleMeta =
      const VerificationMeta('isForPeople');
  @override
  late final GeneratedColumn<bool> isForPeople = GeneratedColumn<bool>(
      'is_for_people', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_for_people" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [wayId, cellKey, isForCars, isForPeople];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'road_ways';
  @override
  VerificationContext validateIntegrity(Insertable<RoadWay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('way_id')) {
      context.handle(
          _wayIdMeta, wayId.isAcceptableOrUnknown(data['way_id']!, _wayIdMeta));
    } else if (isInserting) {
      context.missing(_wayIdMeta);
    }
    if (data.containsKey('cell_key')) {
      context.handle(_cellKeyMeta,
          cellKey.isAcceptableOrUnknown(data['cell_key']!, _cellKeyMeta));
    } else if (isInserting) {
      context.missing(_cellKeyMeta);
    }
    if (data.containsKey('is_for_cars')) {
      context.handle(
          _isForCarsMeta,
          isForCars.isAcceptableOrUnknown(
              data['is_for_cars']!, _isForCarsMeta));
    } else if (isInserting) {
      context.missing(_isForCarsMeta);
    }
    if (data.containsKey('is_for_people')) {
      context.handle(
          _isForPeopleMeta,
          isForPeople.isAcceptableOrUnknown(
              data['is_for_people']!, _isForPeopleMeta));
    } else if (isInserting) {
      context.missing(_isForPeopleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wayId, cellKey};
  @override
  RoadWay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoadWay(
      wayId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}way_id'])!,
      cellKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cell_key'])!,
      isForCars: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_for_cars'])!,
      isForPeople: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_for_people'])!,
    );
  }

  @override
  $RoadWaysTable createAlias(String alias) {
    return $RoadWaysTable(attachedDatabase, alias);
  }
}

class RoadWay extends DataClass implements Insertable<RoadWay> {
  final int wayId;
  final String cellKey;
  final bool isForCars;
  final bool isForPeople;
  const RoadWay(
      {required this.wayId,
      required this.cellKey,
      required this.isForCars,
      required this.isForPeople});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['way_id'] = Variable<int>(wayId);
    map['cell_key'] = Variable<String>(cellKey);
    map['is_for_cars'] = Variable<bool>(isForCars);
    map['is_for_people'] = Variable<bool>(isForPeople);
    return map;
  }

  RoadWaysCompanion toCompanion(bool nullToAbsent) {
    return RoadWaysCompanion(
      wayId: Value(wayId),
      cellKey: Value(cellKey),
      isForCars: Value(isForCars),
      isForPeople: Value(isForPeople),
    );
  }

  factory RoadWay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoadWay(
      wayId: serializer.fromJson<int>(json['wayId']),
      cellKey: serializer.fromJson<String>(json['cellKey']),
      isForCars: serializer.fromJson<bool>(json['isForCars']),
      isForPeople: serializer.fromJson<bool>(json['isForPeople']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wayId': serializer.toJson<int>(wayId),
      'cellKey': serializer.toJson<String>(cellKey),
      'isForCars': serializer.toJson<bool>(isForCars),
      'isForPeople': serializer.toJson<bool>(isForPeople),
    };
  }

  RoadWay copyWith(
          {int? wayId, String? cellKey, bool? isForCars, bool? isForPeople}) =>
      RoadWay(
        wayId: wayId ?? this.wayId,
        cellKey: cellKey ?? this.cellKey,
        isForCars: isForCars ?? this.isForCars,
        isForPeople: isForPeople ?? this.isForPeople,
      );
  RoadWay copyWithCompanion(RoadWaysCompanion data) {
    return RoadWay(
      wayId: data.wayId.present ? data.wayId.value : this.wayId,
      cellKey: data.cellKey.present ? data.cellKey.value : this.cellKey,
      isForCars: data.isForCars.present ? data.isForCars.value : this.isForCars,
      isForPeople:
          data.isForPeople.present ? data.isForPeople.value : this.isForPeople,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoadWay(')
          ..write('wayId: $wayId, ')
          ..write('cellKey: $cellKey, ')
          ..write('isForCars: $isForCars, ')
          ..write('isForPeople: $isForPeople')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wayId, cellKey, isForCars, isForPeople);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoadWay &&
          other.wayId == this.wayId &&
          other.cellKey == this.cellKey &&
          other.isForCars == this.isForCars &&
          other.isForPeople == this.isForPeople);
}

class RoadWaysCompanion extends UpdateCompanion<RoadWay> {
  final Value<int> wayId;
  final Value<String> cellKey;
  final Value<bool> isForCars;
  final Value<bool> isForPeople;
  final Value<int> rowid;
  const RoadWaysCompanion({
    this.wayId = const Value.absent(),
    this.cellKey = const Value.absent(),
    this.isForCars = const Value.absent(),
    this.isForPeople = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoadWaysCompanion.insert({
    required int wayId,
    required String cellKey,
    required bool isForCars,
    required bool isForPeople,
    this.rowid = const Value.absent(),
  })  : wayId = Value(wayId),
        cellKey = Value(cellKey),
        isForCars = Value(isForCars),
        isForPeople = Value(isForPeople);
  static Insertable<RoadWay> custom({
    Expression<int>? wayId,
    Expression<String>? cellKey,
    Expression<bool>? isForCars,
    Expression<bool>? isForPeople,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wayId != null) 'way_id': wayId,
      if (cellKey != null) 'cell_key': cellKey,
      if (isForCars != null) 'is_for_cars': isForCars,
      if (isForPeople != null) 'is_for_people': isForPeople,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoadWaysCompanion copyWith(
      {Value<int>? wayId,
      Value<String>? cellKey,
      Value<bool>? isForCars,
      Value<bool>? isForPeople,
      Value<int>? rowid}) {
    return RoadWaysCompanion(
      wayId: wayId ?? this.wayId,
      cellKey: cellKey ?? this.cellKey,
      isForCars: isForCars ?? this.isForCars,
      isForPeople: isForPeople ?? this.isForPeople,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wayId.present) {
      map['way_id'] = Variable<int>(wayId.value);
    }
    if (cellKey.present) {
      map['cell_key'] = Variable<String>(cellKey.value);
    }
    if (isForCars.present) {
      map['is_for_cars'] = Variable<bool>(isForCars.value);
    }
    if (isForPeople.present) {
      map['is_for_people'] = Variable<bool>(isForPeople.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoadWaysCompanion(')
          ..write('wayId: $wayId, ')
          ..write('cellKey: $cellKey, ')
          ..write('isForCars: $isForCars, ')
          ..write('isForPeople: $isForPeople, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoadNodesTable extends RoadNodes
    with TableInfo<$RoadNodesTable, RoadNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoadNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<int> nodeId = GeneratedColumn<int>(
      'node_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wayIdMeta = const VerificationMeta('wayId');
  @override
  late final GeneratedColumn<int> wayId = GeneratedColumn<int>(
      'way_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sequenceIndexMeta =
      const VerificationMeta('sequenceIndex');
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
      'sequence_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [nodeId, wayId, lat, lon, sequenceIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'road_nodes';
  @override
  VerificationContext validateIntegrity(Insertable<RoadNode> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('node_id')) {
      context.handle(_nodeIdMeta,
          nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta));
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('way_id')) {
      context.handle(
          _wayIdMeta, wayId.isAcceptableOrUnknown(data['way_id']!, _wayIdMeta));
    } else if (isInserting) {
      context.missing(_wayIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
          _sequenceIndexMeta,
          sequenceIndex.isAcceptableOrUnknown(
              data['sequence_index']!, _sequenceIndexMeta));
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  RoadNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoadNode(
      nodeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}node_id'])!,
      wayId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}way_id'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      sequenceIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_index'])!,
    );
  }

  @override
  $RoadNodesTable createAlias(String alias) {
    return $RoadNodesTable(attachedDatabase, alias);
  }
}

class RoadNode extends DataClass implements Insertable<RoadNode> {
  final int nodeId;
  final int wayId;
  final double lat;
  final double lon;
  final int sequenceIndex;
  const RoadNode(
      {required this.nodeId,
      required this.wayId,
      required this.lat,
      required this.lon,
      required this.sequenceIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['node_id'] = Variable<int>(nodeId);
    map['way_id'] = Variable<int>(wayId);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    return map;
  }

  RoadNodesCompanion toCompanion(bool nullToAbsent) {
    return RoadNodesCompanion(
      nodeId: Value(nodeId),
      wayId: Value(wayId),
      lat: Value(lat),
      lon: Value(lon),
      sequenceIndex: Value(sequenceIndex),
    );
  }

  factory RoadNode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoadNode(
      nodeId: serializer.fromJson<int>(json['nodeId']),
      wayId: serializer.fromJson<int>(json['wayId']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nodeId': serializer.toJson<int>(nodeId),
      'wayId': serializer.toJson<int>(wayId),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
    };
  }

  RoadNode copyWith(
          {int? nodeId,
          int? wayId,
          double? lat,
          double? lon,
          int? sequenceIndex}) =>
      RoadNode(
        nodeId: nodeId ?? this.nodeId,
        wayId: wayId ?? this.wayId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      );
  RoadNode copyWithCompanion(RoadNodesCompanion data) {
    return RoadNode(
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      wayId: data.wayId.present ? data.wayId.value : this.wayId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoadNode(')
          ..write('nodeId: $nodeId, ')
          ..write('wayId: $wayId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('sequenceIndex: $sequenceIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(nodeId, wayId, lat, lon, sequenceIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoadNode &&
          other.nodeId == this.nodeId &&
          other.wayId == this.wayId &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.sequenceIndex == this.sequenceIndex);
}

class RoadNodesCompanion extends UpdateCompanion<RoadNode> {
  final Value<int> nodeId;
  final Value<int> wayId;
  final Value<double> lat;
  final Value<double> lon;
  final Value<int> sequenceIndex;
  final Value<int> rowid;
  const RoadNodesCompanion({
    this.nodeId = const Value.absent(),
    this.wayId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoadNodesCompanion.insert({
    required int nodeId,
    required int wayId,
    required double lat,
    required double lon,
    required int sequenceIndex,
    this.rowid = const Value.absent(),
  })  : nodeId = Value(nodeId),
        wayId = Value(wayId),
        lat = Value(lat),
        lon = Value(lon),
        sequenceIndex = Value(sequenceIndex);
  static Insertable<RoadNode> custom({
    Expression<int>? nodeId,
    Expression<int>? wayId,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? sequenceIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nodeId != null) 'node_id': nodeId,
      if (wayId != null) 'way_id': wayId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoadNodesCompanion copyWith(
      {Value<int>? nodeId,
      Value<int>? wayId,
      Value<double>? lat,
      Value<double>? lon,
      Value<int>? sequenceIndex,
      Value<int>? rowid}) {
    return RoadNodesCompanion(
      nodeId: nodeId ?? this.nodeId,
      wayId: wayId ?? this.wayId,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nodeId.present) {
      map['node_id'] = Variable<int>(nodeId.value);
    }
    if (wayId.present) {
      map['way_id'] = Variable<int>(wayId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoadNodesCompanion(')
          ..write('nodeId: $nodeId, ')
          ..write('wayId: $wayId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MapTilesTable mapTiles = $MapTilesTable(this);
  late final $RoadZonesTable roadZones = $RoadZonesTable(this);
  late final $RoadWaysTable roadWays = $RoadWaysTable(this);
  late final $RoadNodesTable roadNodes = $RoadNodesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [mapTiles, roadZones, roadWays, roadNodes];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('road_zones',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('road_ways', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$MapTilesTableCreateCompanionBuilder = MapTilesCompanion Function({
  required String provider,
  required int zoom,
  required int x,
  required int y,
  required Uint8List data,
  required int lastAccessed,
  Value<int> rowid,
});
typedef $$MapTilesTableUpdateCompanionBuilder = MapTilesCompanion Function({
  Value<String> provider,
  Value<int> zoom,
  Value<int> x,
  Value<int> y,
  Value<Uint8List> data,
  Value<int> lastAccessed,
  Value<int> rowid,
});

class $$MapTilesTableFilterComposer
    extends Composer<_$AppDatabase, $MapTilesTable> {
  $$MapTilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get zoom => $composableBuilder(
      column: $table.zoom, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed, builder: (column) => ColumnFilters(column));
}

class $$MapTilesTableOrderingComposer
    extends Composer<_$AppDatabase, $MapTilesTable> {
  $$MapTilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get zoom => $composableBuilder(
      column: $table.zoom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get x => $composableBuilder(
      column: $table.x, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get y => $composableBuilder(
      column: $table.y, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed,
      builder: (column) => ColumnOrderings(column));
}

class $$MapTilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapTilesTable> {
  $$MapTilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<int> get zoom =>
      $composableBuilder(column: $table.zoom, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed, builder: (column) => column);
}

class $$MapTilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MapTilesTable,
    MapTile,
    $$MapTilesTableFilterComposer,
    $$MapTilesTableOrderingComposer,
    $$MapTilesTableAnnotationComposer,
    $$MapTilesTableCreateCompanionBuilder,
    $$MapTilesTableUpdateCompanionBuilder,
    (MapTile, BaseReferences<_$AppDatabase, $MapTilesTable, MapTile>),
    MapTile,
    PrefetchHooks Function()> {
  $$MapTilesTableTableManager(_$AppDatabase db, $MapTilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapTilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapTilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapTilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> provider = const Value.absent(),
            Value<int> zoom = const Value.absent(),
            Value<int> x = const Value.absent(),
            Value<int> y = const Value.absent(),
            Value<Uint8List> data = const Value.absent(),
            Value<int> lastAccessed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MapTilesCompanion(
            provider: provider,
            zoom: zoom,
            x: x,
            y: y,
            data: data,
            lastAccessed: lastAccessed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String provider,
            required int zoom,
            required int x,
            required int y,
            required Uint8List data,
            required int lastAccessed,
            Value<int> rowid = const Value.absent(),
          }) =>
              MapTilesCompanion.insert(
            provider: provider,
            zoom: zoom,
            x: x,
            y: y,
            data: data,
            lastAccessed: lastAccessed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MapTilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MapTilesTable,
    MapTile,
    $$MapTilesTableFilterComposer,
    $$MapTilesTableOrderingComposer,
    $$MapTilesTableAnnotationComposer,
    $$MapTilesTableCreateCompanionBuilder,
    $$MapTilesTableUpdateCompanionBuilder,
    (MapTile, BaseReferences<_$AppDatabase, $MapTilesTable, MapTile>),
    MapTile,
    PrefetchHooks Function()>;
typedef $$RoadZonesTableCreateCompanionBuilder = RoadZonesCompanion Function({
  required String cellKey,
  required int timestamp,
  Value<int> rowid,
});
typedef $$RoadZonesTableUpdateCompanionBuilder = RoadZonesCompanion Function({
  Value<String> cellKey,
  Value<int> timestamp,
  Value<int> rowid,
});

final class $$RoadZonesTableReferences
    extends BaseReferences<_$AppDatabase, $RoadZonesTable, RoadZone> {
  $$RoadZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoadWaysTable, List<RoadWay>> _roadWaysRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roadWays,
          aliasName:
              $_aliasNameGenerator(db.roadZones.cellKey, db.roadWays.cellKey));

  $$RoadWaysTableProcessedTableManager get roadWaysRefs {
    final manager = $$RoadWaysTableTableManager($_db, $_db.roadWays).filter(
        (f) => f.cellKey.cellKey.sqlEquals($_itemColumn<String>('cell_key')!));

    final cache = $_typedResult.readTableOrNull(_roadWaysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoadZonesTableFilterComposer
    extends Composer<_$AppDatabase, $RoadZonesTable> {
  $$RoadZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cellKey => $composableBuilder(
      column: $table.cellKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  Expression<bool> roadWaysRefs(
      Expression<bool> Function($$RoadWaysTableFilterComposer f) f) {
    final $$RoadWaysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cellKey,
        referencedTable: $db.roadWays,
        getReferencedColumn: (t) => t.cellKey,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoadWaysTableFilterComposer(
              $db: $db,
              $table: $db.roadWays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoadZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoadZonesTable> {
  $$RoadZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cellKey => $composableBuilder(
      column: $table.cellKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$RoadZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoadZonesTable> {
  $$RoadZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cellKey =>
      $composableBuilder(column: $table.cellKey, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  Expression<T> roadWaysRefs<T extends Object>(
      Expression<T> Function($$RoadWaysTableAnnotationComposer a) f) {
    final $$RoadWaysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cellKey,
        referencedTable: $db.roadWays,
        getReferencedColumn: (t) => t.cellKey,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoadWaysTableAnnotationComposer(
              $db: $db,
              $table: $db.roadWays,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoadZonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoadZonesTable,
    RoadZone,
    $$RoadZonesTableFilterComposer,
    $$RoadZonesTableOrderingComposer,
    $$RoadZonesTableAnnotationComposer,
    $$RoadZonesTableCreateCompanionBuilder,
    $$RoadZonesTableUpdateCompanionBuilder,
    (RoadZone, $$RoadZonesTableReferences),
    RoadZone,
    PrefetchHooks Function({bool roadWaysRefs})> {
  $$RoadZonesTableTableManager(_$AppDatabase db, $RoadZonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoadZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoadZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoadZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cellKey = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoadZonesCompanion(
            cellKey: cellKey,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cellKey,
            required int timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoadZonesCompanion.insert(
            cellKey: cellKey,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoadZonesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({roadWaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roadWaysRefs) db.roadWays],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roadWaysRefs)
                    await $_getPrefetchedData<RoadZone, $RoadZonesTable,
                            RoadWay>(
                        currentTable: table,
                        referencedTable:
                            $$RoadZonesTableReferences._roadWaysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoadZonesTableReferences(db, table, p0)
                                .roadWaysRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.cellKey == item.cellKey),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoadZonesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoadZonesTable,
    RoadZone,
    $$RoadZonesTableFilterComposer,
    $$RoadZonesTableOrderingComposer,
    $$RoadZonesTableAnnotationComposer,
    $$RoadZonesTableCreateCompanionBuilder,
    $$RoadZonesTableUpdateCompanionBuilder,
    (RoadZone, $$RoadZonesTableReferences),
    RoadZone,
    PrefetchHooks Function({bool roadWaysRefs})>;
typedef $$RoadWaysTableCreateCompanionBuilder = RoadWaysCompanion Function({
  required int wayId,
  required String cellKey,
  required bool isForCars,
  required bool isForPeople,
  Value<int> rowid,
});
typedef $$RoadWaysTableUpdateCompanionBuilder = RoadWaysCompanion Function({
  Value<int> wayId,
  Value<String> cellKey,
  Value<bool> isForCars,
  Value<bool> isForPeople,
  Value<int> rowid,
});

final class $$RoadWaysTableReferences
    extends BaseReferences<_$AppDatabase, $RoadWaysTable, RoadWay> {
  $$RoadWaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoadZonesTable _cellKeyTable(_$AppDatabase db) =>
      db.roadZones.createAlias(
          $_aliasNameGenerator(db.roadWays.cellKey, db.roadZones.cellKey));

  $$RoadZonesTableProcessedTableManager get cellKey {
    final $_column = $_itemColumn<String>('cell_key')!;

    final manager = $$RoadZonesTableTableManager($_db, $_db.roadZones)
        .filter((f) => f.cellKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cellKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoadWaysTableFilterComposer
    extends Composer<_$AppDatabase, $RoadWaysTable> {
  $$RoadWaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wayId => $composableBuilder(
      column: $table.wayId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isForCars => $composableBuilder(
      column: $table.isForCars, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isForPeople => $composableBuilder(
      column: $table.isForPeople, builder: (column) => ColumnFilters(column));

  $$RoadZonesTableFilterComposer get cellKey {
    final $$RoadZonesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cellKey,
        referencedTable: $db.roadZones,
        getReferencedColumn: (t) => t.cellKey,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoadZonesTableFilterComposer(
              $db: $db,
              $table: $db.roadZones,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoadWaysTableOrderingComposer
    extends Composer<_$AppDatabase, $RoadWaysTable> {
  $$RoadWaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wayId => $composableBuilder(
      column: $table.wayId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isForCars => $composableBuilder(
      column: $table.isForCars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isForPeople => $composableBuilder(
      column: $table.isForPeople, builder: (column) => ColumnOrderings(column));

  $$RoadZonesTableOrderingComposer get cellKey {
    final $$RoadZonesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cellKey,
        referencedTable: $db.roadZones,
        getReferencedColumn: (t) => t.cellKey,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoadZonesTableOrderingComposer(
              $db: $db,
              $table: $db.roadZones,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoadWaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoadWaysTable> {
  $$RoadWaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wayId =>
      $composableBuilder(column: $table.wayId, builder: (column) => column);

  GeneratedColumn<bool> get isForCars =>
      $composableBuilder(column: $table.isForCars, builder: (column) => column);

  GeneratedColumn<bool> get isForPeople => $composableBuilder(
      column: $table.isForPeople, builder: (column) => column);

  $$RoadZonesTableAnnotationComposer get cellKey {
    final $$RoadZonesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cellKey,
        referencedTable: $db.roadZones,
        getReferencedColumn: (t) => t.cellKey,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoadZonesTableAnnotationComposer(
              $db: $db,
              $table: $db.roadZones,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoadWaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoadWaysTable,
    RoadWay,
    $$RoadWaysTableFilterComposer,
    $$RoadWaysTableOrderingComposer,
    $$RoadWaysTableAnnotationComposer,
    $$RoadWaysTableCreateCompanionBuilder,
    $$RoadWaysTableUpdateCompanionBuilder,
    (RoadWay, $$RoadWaysTableReferences),
    RoadWay,
    PrefetchHooks Function({bool cellKey})> {
  $$RoadWaysTableTableManager(_$AppDatabase db, $RoadWaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoadWaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoadWaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoadWaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wayId = const Value.absent(),
            Value<String> cellKey = const Value.absent(),
            Value<bool> isForCars = const Value.absent(),
            Value<bool> isForPeople = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoadWaysCompanion(
            wayId: wayId,
            cellKey: cellKey,
            isForCars: isForCars,
            isForPeople: isForPeople,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int wayId,
            required String cellKey,
            required bool isForCars,
            required bool isForPeople,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoadWaysCompanion.insert(
            wayId: wayId,
            cellKey: cellKey,
            isForCars: isForCars,
            isForPeople: isForPeople,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoadWaysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({cellKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cellKey) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cellKey,
                    referencedTable:
                        $$RoadWaysTableReferences._cellKeyTable(db),
                    referencedColumn:
                        $$RoadWaysTableReferences._cellKeyTable(db).cellKey,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoadWaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoadWaysTable,
    RoadWay,
    $$RoadWaysTableFilterComposer,
    $$RoadWaysTableOrderingComposer,
    $$RoadWaysTableAnnotationComposer,
    $$RoadWaysTableCreateCompanionBuilder,
    $$RoadWaysTableUpdateCompanionBuilder,
    (RoadWay, $$RoadWaysTableReferences),
    RoadWay,
    PrefetchHooks Function({bool cellKey})>;
typedef $$RoadNodesTableCreateCompanionBuilder = RoadNodesCompanion Function({
  required int nodeId,
  required int wayId,
  required double lat,
  required double lon,
  required int sequenceIndex,
  Value<int> rowid,
});
typedef $$RoadNodesTableUpdateCompanionBuilder = RoadNodesCompanion Function({
  Value<int> nodeId,
  Value<int> wayId,
  Value<double> lat,
  Value<double> lon,
  Value<int> sequenceIndex,
  Value<int> rowid,
});

class $$RoadNodesTableFilterComposer
    extends Composer<_$AppDatabase, $RoadNodesTable> {
  $$RoadNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get nodeId => $composableBuilder(
      column: $table.nodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wayId => $composableBuilder(
      column: $table.wayId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => ColumnFilters(column));
}

class $$RoadNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoadNodesTable> {
  $$RoadNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get nodeId => $composableBuilder(
      column: $table.nodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wayId => $composableBuilder(
      column: $table.wayId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex,
      builder: (column) => ColumnOrderings(column));
}

class $$RoadNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoadNodesTable> {
  $$RoadNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<int> get wayId =>
      $composableBuilder(column: $table.wayId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => column);
}

class $$RoadNodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoadNodesTable,
    RoadNode,
    $$RoadNodesTableFilterComposer,
    $$RoadNodesTableOrderingComposer,
    $$RoadNodesTableAnnotationComposer,
    $$RoadNodesTableCreateCompanionBuilder,
    $$RoadNodesTableUpdateCompanionBuilder,
    (RoadNode, BaseReferences<_$AppDatabase, $RoadNodesTable, RoadNode>),
    RoadNode,
    PrefetchHooks Function()> {
  $$RoadNodesTableTableManager(_$AppDatabase db, $RoadNodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoadNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoadNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoadNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> nodeId = const Value.absent(),
            Value<int> wayId = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lon = const Value.absent(),
            Value<int> sequenceIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoadNodesCompanion(
            nodeId: nodeId,
            wayId: wayId,
            lat: lat,
            lon: lon,
            sequenceIndex: sequenceIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int nodeId,
            required int wayId,
            required double lat,
            required double lon,
            required int sequenceIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoadNodesCompanion.insert(
            nodeId: nodeId,
            wayId: wayId,
            lat: lat,
            lon: lon,
            sequenceIndex: sequenceIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RoadNodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoadNodesTable,
    RoadNode,
    $$RoadNodesTableFilterComposer,
    $$RoadNodesTableOrderingComposer,
    $$RoadNodesTableAnnotationComposer,
    $$RoadNodesTableCreateCompanionBuilder,
    $$RoadNodesTableUpdateCompanionBuilder,
    (RoadNode, BaseReferences<_$AppDatabase, $RoadNodesTable, RoadNode>),
    RoadNode,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MapTilesTableTableManager get mapTiles =>
      $$MapTilesTableTableManager(_db, _db.mapTiles);
  $$RoadZonesTableTableManager get roadZones =>
      $$RoadZonesTableTableManager(_db, _db.roadZones);
  $$RoadWaysTableTableManager get roadWays =>
      $$RoadWaysTableTableManager(_db, _db.roadWays);
  $$RoadNodesTableTableManager get roadNodes =>
      $$RoadNodesTableTableManager(_db, _db.roadNodes);
}
