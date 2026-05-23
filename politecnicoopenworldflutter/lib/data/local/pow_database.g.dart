// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pow_database.dart';

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

class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
      'character_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _characterNameMeta =
      const VerificationMeta('characterName');
  @override
  late final GeneratedColumn<String> characterName = GeneratedColumn<String>(
      'character_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastLatMeta =
      const VerificationMeta('lastLat');
  @override
  late final GeneratedColumn<double> lastLat = GeneratedColumn<double>(
      'last_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lastLonMeta =
      const VerificationMeta('lastLon');
  @override
  late final GeneratedColumn<double> lastLon = GeneratedColumn<double>(
      'last_lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        characterId,
        characterName,
        createdAt,
        updatedAt,
        lastLat,
        lastLon,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<GameSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('character_name')) {
      context.handle(
          _characterNameMeta,
          characterName.isAcceptableOrUnknown(
              data['character_name']!, _characterNameMeta));
    } else if (isInserting) {
      context.missing(_characterNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_lat')) {
      context.handle(_lastLatMeta,
          lastLat.isAcceptableOrUnknown(data['last_lat']!, _lastLatMeta));
    } else if (isInserting) {
      context.missing(_lastLatMeta);
    }
    if (data.containsKey('last_lon')) {
      context.handle(_lastLonMeta,
          lastLon.isAcceptableOrUnknown(data['last_lon']!, _lastLonMeta));
    } else if (isInserting) {
      context.missing(_lastLonMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}character_id'])!,
      characterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}character_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      lastLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}last_lat'])!,
      lastLon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}last_lon'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSessionRow extends DataClass implements Insertable<GameSessionRow> {
  final String id;
  final String characterId;
  final String characterName;
  final int createdAt;
  final int updatedAt;
  final double lastLat;
  final double lastLon;
  final bool isActive;
  const GameSessionRow(
      {required this.id,
      required this.characterId,
      required this.characterName,
      required this.createdAt,
      required this.updatedAt,
      required this.lastLat,
      required this.lastLon,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character_id'] = Variable<String>(characterId);
    map['character_name'] = Variable<String>(characterName);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['last_lat'] = Variable<double>(lastLat);
    map['last_lon'] = Variable<double>(lastLon);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      characterName: Value(characterName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastLat: Value(lastLat),
      lastLon: Value(lastLon),
      isActive: Value(isActive),
    );
  }

  factory GameSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSessionRow(
      id: serializer.fromJson<String>(json['id']),
      characterId: serializer.fromJson<String>(json['characterId']),
      characterName: serializer.fromJson<String>(json['characterName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastLat: serializer.fromJson<double>(json['lastLat']),
      lastLon: serializer.fromJson<double>(json['lastLon']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'characterId': serializer.toJson<String>(characterId),
      'characterName': serializer.toJson<String>(characterName),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastLat': serializer.toJson<double>(lastLat),
      'lastLon': serializer.toJson<double>(lastLon),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  GameSessionRow copyWith(
          {String? id,
          String? characterId,
          String? characterName,
          int? createdAt,
          int? updatedAt,
          double? lastLat,
          double? lastLon,
          bool? isActive}) =>
      GameSessionRow(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        characterName: characterName ?? this.characterName,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastLat: lastLat ?? this.lastLat,
        lastLon: lastLon ?? this.lastLon,
        isActive: isActive ?? this.isActive,
      );
  GameSessionRow copyWithCompanion(GameSessionsCompanion data) {
    return GameSessionRow(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      characterName: data.characterName.present
          ? data.characterName.value
          : this.characterName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastLat: data.lastLat.present ? data.lastLat.value : this.lastLat,
      lastLon: data.lastLon.present ? data.lastLon.value : this.lastLon,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionRow(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('characterName: $characterName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLat: $lastLat, ')
          ..write('lastLon: $lastLon, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, characterName, createdAt,
      updatedAt, lastLat, lastLon, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSessionRow &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.characterName == this.characterName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastLat == this.lastLat &&
          other.lastLon == this.lastLon &&
          other.isActive == this.isActive);
}

class GameSessionsCompanion extends UpdateCompanion<GameSessionRow> {
  final Value<String> id;
  final Value<String> characterId;
  final Value<String> characterName;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<double> lastLat;
  final Value<double> lastLon;
  final Value<bool> isActive;
  final Value<int> rowid;
  const GameSessionsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.characterName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastLat = const Value.absent(),
    this.lastLon = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    required String id,
    required String characterId,
    required String characterName,
    required int createdAt,
    required int updatedAt,
    required double lastLat,
    required double lastLon,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        characterId = Value(characterId),
        characterName = Value(characterName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        lastLat = Value(lastLat),
        lastLon = Value(lastLon);
  static Insertable<GameSessionRow> custom({
    Expression<String>? id,
    Expression<String>? characterId,
    Expression<String>? characterName,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<double>? lastLat,
    Expression<double>? lastLon,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (characterName != null) 'character_name': characterName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastLat != null) 'last_lat': lastLat,
      if (lastLon != null) 'last_lon': lastLon,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? characterId,
      Value<String>? characterName,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<double>? lastLat,
      Value<double>? lastLon,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return GameSessionsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLat: lastLat ?? this.lastLat,
      lastLon: lastLon ?? this.lastLon,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (characterName.present) {
      map['character_name'] = Variable<String>(characterName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastLat.present) {
      map['last_lat'] = Variable<double>(lastLat.value);
    }
    if (lastLon.present) {
      map['last_lon'] = Variable<double>(lastLon.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('characterName: $characterName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLat: $lastLat, ')
          ..write('lastLon: $lastLon, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedLocationsTable extends SavedLocations
    with TableInfo<$SavedLocationsTable, SavedLocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES game_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, label, lat, lon, kind, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_locations';
  @override
  VerificationContext validateIntegrity(Insertable<SavedLocationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
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
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedLocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedLocationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SavedLocationsTable createAlias(String alias) {
    return $SavedLocationsTable(attachedDatabase, alias);
  }
}

class SavedLocationRow extends DataClass
    implements Insertable<SavedLocationRow> {
  final String id;
  final String sessionId;
  final String label;
  final double lat;
  final double lon;
  final String kind;
  final int createdAt;
  const SavedLocationRow(
      {required this.id,
      required this.sessionId,
      required this.label,
      required this.lat,
      required this.lon,
      required this.kind,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['label'] = Variable<String>(label);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SavedLocationsCompanion toCompanion(bool nullToAbsent) {
    return SavedLocationsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      label: Value(label),
      lat: Value(lat),
      lon: Value(lon),
      kind: Value(kind),
      createdAt: Value(createdAt),
    );
  }

  factory SavedLocationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedLocationRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      label: serializer.fromJson<String>(json['label']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'label': serializer.toJson<String>(label),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SavedLocationRow copyWith(
          {String? id,
          String? sessionId,
          String? label,
          double? lat,
          double? lon,
          String? kind,
          int? createdAt}) =>
      SavedLocationRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        label: label ?? this.label,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        kind: kind ?? this.kind,
        createdAt: createdAt ?? this.createdAt,
      );
  SavedLocationRow copyWithCompanion(SavedLocationsCompanion data) {
    return SavedLocationRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      label: data.label.present ? data.label.value : this.label,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('label: $label, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, label, lat, lon, kind, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedLocationRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.label == this.label &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt);
}

class SavedLocationsCompanion extends UpdateCompanion<SavedLocationRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> label;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String> kind;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SavedLocationsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.label = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedLocationsCompanion.insert({
    required String id,
    required String sessionId,
    required String label,
    required double lat,
    required double lon,
    required String kind,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        label = Value(label),
        lat = Value(lat),
        lon = Value(lon),
        kind = Value(kind),
        createdAt = Value(createdAt);
  static Insertable<SavedLocationRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? label,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? kind,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (label != null) 'label': label,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedLocationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? label,
      Value<double>? lat,
      Value<double>? lon,
      Value<String>? kind,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return SavedLocationsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      label: label ?? this.label,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedLocationsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('label: $label, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
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
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $SavedLocationsTable savedLocations = $SavedLocationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [mapTiles, roadZones, roadWays, roadNodes, gameSessions, savedLocations];
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
          WritePropagation(
            on: TableUpdateQuery.onTableName('game_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('saved_locations', kind: UpdateKind.delete),
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
typedef $$GameSessionsTableCreateCompanionBuilder = GameSessionsCompanion
    Function({
  required String id,
  required String characterId,
  required String characterName,
  required int createdAt,
  required int updatedAt,
  required double lastLat,
  required double lastLon,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$GameSessionsTableUpdateCompanionBuilder = GameSessionsCompanion
    Function({
  Value<String> id,
  Value<String> characterId,
  Value<String> characterName,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<double> lastLat,
  Value<double> lastLon,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$GameSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $GameSessionsTable, GameSessionRow> {
  $$GameSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SavedLocationsTable, List<SavedLocationRow>>
      _savedLocationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.savedLocations,
              aliasName: $_aliasNameGenerator(
                  db.gameSessions.id, db.savedLocations.sessionId));

  $$SavedLocationsTableProcessedTableManager get savedLocationsRefs {
    final manager = $$SavedLocationsTableTableManager($_db, $_db.savedLocations)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedLocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get characterName => $composableBuilder(
      column: $table.characterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lastLat => $composableBuilder(
      column: $table.lastLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lastLon => $composableBuilder(
      column: $table.lastLon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> savedLocationsRefs(
      Expression<bool> Function($$SavedLocationsTableFilterComposer f) f) {
    final $$SavedLocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.savedLocations,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedLocationsTableFilterComposer(
              $db: $db,
              $table: $db.savedLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get characterName => $composableBuilder(
      column: $table.characterName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lastLat => $composableBuilder(
      column: $table.lastLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lastLon => $composableBuilder(
      column: $table.lastLon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<String> get characterName => $composableBuilder(
      column: $table.characterName, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get lastLat =>
      $composableBuilder(column: $table.lastLat, builder: (column) => column);

  GeneratedColumn<double> get lastLon =>
      $composableBuilder(column: $table.lastLon, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> savedLocationsRefs<T extends Object>(
      Expression<T> Function($$SavedLocationsTableAnnotationComposer a) f) {
    final $$SavedLocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.savedLocations,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedLocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.savedLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GameSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GameSessionsTable,
    GameSessionRow,
    $$GameSessionsTableFilterComposer,
    $$GameSessionsTableOrderingComposer,
    $$GameSessionsTableAnnotationComposer,
    $$GameSessionsTableCreateCompanionBuilder,
    $$GameSessionsTableUpdateCompanionBuilder,
    (GameSessionRow, $$GameSessionsTableReferences),
    GameSessionRow,
    PrefetchHooks Function({bool savedLocationsRefs})> {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> characterId = const Value.absent(),
            Value<String> characterName = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<double> lastLat = const Value.absent(),
            Value<double> lastLon = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameSessionsCompanion(
            id: id,
            characterId: characterId,
            characterName: characterName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLat: lastLat,
            lastLon: lastLon,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String characterId,
            required String characterName,
            required int createdAt,
            required int updatedAt,
            required double lastLat,
            required double lastLon,
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameSessionsCompanion.insert(
            id: id,
            characterId: characterId,
            characterName: characterName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastLat: lastLat,
            lastLon: lastLon,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GameSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({savedLocationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (savedLocationsRefs) db.savedLocations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savedLocationsRefs)
                    await $_getPrefetchedData<GameSessionRow,
                            $GameSessionsTable, SavedLocationRow>(
                        currentTable: table,
                        referencedTable: $$GameSessionsTableReferences
                            ._savedLocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GameSessionsTableReferences(db, table, p0)
                                .savedLocationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GameSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GameSessionsTable,
    GameSessionRow,
    $$GameSessionsTableFilterComposer,
    $$GameSessionsTableOrderingComposer,
    $$GameSessionsTableAnnotationComposer,
    $$GameSessionsTableCreateCompanionBuilder,
    $$GameSessionsTableUpdateCompanionBuilder,
    (GameSessionRow, $$GameSessionsTableReferences),
    GameSessionRow,
    PrefetchHooks Function({bool savedLocationsRefs})>;
typedef $$SavedLocationsTableCreateCompanionBuilder = SavedLocationsCompanion
    Function({
  required String id,
  required String sessionId,
  required String label,
  required double lat,
  required double lon,
  required String kind,
  required int createdAt,
  Value<int> rowid,
});
typedef $$SavedLocationsTableUpdateCompanionBuilder = SavedLocationsCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> label,
  Value<double> lat,
  Value<double> lon,
  Value<String> kind,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$SavedLocationsTableReferences extends BaseReferences<
    _$AppDatabase, $SavedLocationsTable, SavedLocationRow> {
  $$SavedLocationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GameSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.gameSessions.createAlias($_aliasNameGenerator(
          db.savedLocations.sessionId, db.gameSessions.id));

  $$GameSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$GameSessionsTableTableManager($_db, $_db.gameSessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SavedLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$GameSessionsTableFilterComposer get sessionId {
    final $$GameSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.gameSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSessionsTableFilterComposer(
              $db: $db,
              $table: $db.gameSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavedLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$GameSessionsTableOrderingComposer get sessionId {
    final $$GameSessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.gameSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSessionsTableOrderingComposer(
              $db: $db,
              $table: $db.gameSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavedLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedLocationsTable> {
  $$SavedLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GameSessionsTableAnnotationComposer get sessionId {
    final $$GameSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.gameSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.gameSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavedLocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedLocationsTable,
    SavedLocationRow,
    $$SavedLocationsTableFilterComposer,
    $$SavedLocationsTableOrderingComposer,
    $$SavedLocationsTableAnnotationComposer,
    $$SavedLocationsTableCreateCompanionBuilder,
    $$SavedLocationsTableUpdateCompanionBuilder,
    (SavedLocationRow, $$SavedLocationsTableReferences),
    SavedLocationRow,
    PrefetchHooks Function({bool sessionId})> {
  $$SavedLocationsTableTableManager(
      _$AppDatabase db, $SavedLocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lon = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedLocationsCompanion(
            id: id,
            sessionId: sessionId,
            label: label,
            lat: lat,
            lon: lon,
            kind: kind,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String label,
            required double lat,
            required double lon,
            required String kind,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SavedLocationsCompanion.insert(
            id: id,
            sessionId: sessionId,
            label: label,
            lat: lat,
            lon: lon,
            kind: kind,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SavedLocationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$SavedLocationsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$SavedLocationsTableReferences._sessionIdTable(db).id,
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

typedef $$SavedLocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedLocationsTable,
    SavedLocationRow,
    $$SavedLocationsTableFilterComposer,
    $$SavedLocationsTableOrderingComposer,
    $$SavedLocationsTableAnnotationComposer,
    $$SavedLocationsTableCreateCompanionBuilder,
    $$SavedLocationsTableUpdateCompanionBuilder,
    (SavedLocationRow, $$SavedLocationsTableReferences),
    SavedLocationRow,
    PrefetchHooks Function({bool sessionId})>;

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
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$SavedLocationsTableTableManager get savedLocations =>
      $$SavedLocationsTableTableManager(_db, _db.savedLocations);
}
