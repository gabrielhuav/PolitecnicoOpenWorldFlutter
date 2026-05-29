import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/utils/app_logger.dart';
import '../../data/local/pow_database.dart';

/// TileProvider con caché SQLite. Sirve tiles desde [MapTiles] y solo
/// descarga de la red cuando el tile no existe o superó el TTL.
class CachedNetworkTileProvider extends TileProvider {
  final PowDatabase _db;
  final Dio _dio;
  final String providerKey;
  final int ttlDays;

  static const int _maxCacheBytes = 100 * 1024 * 1024; // 100 MB
  static const int _evictCount = 200;

  CachedNetworkTileProvider({
    required PowDatabase db,
    required this.providerKey,
    this.ttlDays = 30,
    Dio? dio,
  })  : _db = db,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'User-Agent': 'politecnicoopenworldflutter/1.0',
              },
            ));

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _CachedTileImageProvider(
      db: _db,
      dio: _dio,
      providerKey: providerKey,
      coordinates: coordinates,
      options: options,
      ttlMs: ttlDays * 24 * 60 * 60 * 1000,
    );
  }

  /// Borra los tiles más antiguos cuando la tabla supera [_maxCacheBytes].
  static Future<void> evictIfNeeded(PowDatabase db) async {
    try {
      final rows = await db.select(db.mapTiles).get();
      final totalBytes = rows.fold<int>(0, (s, r) => s + r.data.length);
      if (totalBytes <= _maxCacheBytes) return;

      AppLogger.log.i(
        'TileCache: ${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB, '
        'limpiando $_evictCount tiles más antiguos',
      );

      final sorted = List.of(rows)
        ..sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

      for (final tile in sorted.take(_evictCount)) {
        await db.customStatement(
          'DELETE FROM map_tiles '
          'WHERE provider = ? AND zoom = ? AND x = ? AND y = ?',
          [tile.provider, tile.zoom, tile.x, tile.y],
        );
      }
      AppLogger.log.i('TileCache: evict completado');
    } catch (e) {
      AppLogger.log.w('TileCache: evict falló: $e');
    }
  }
}

// ── ImageProvider interno ────────────────────────────────────────────

class _CachedTileImageProvider
    extends ImageProvider<_CachedTileImageProvider> {
  final PowDatabase db;
  final Dio dio;
  final String providerKey;
  final TileCoordinates coordinates;
  final TileLayer options;
  final int ttlMs;

  const _CachedTileImageProvider({
    required this.db,
    required this.dio,
    required this.providerKey,
    required this.coordinates,
    required this.options,
    required this.ttlMs,
  });

  String get _url {
    var url = options.urlTemplate ?? '';
    url = url
        .replaceAll('{z}', '${coordinates.z}')
        .replaceAll('{x}', '${coordinates.x}')
        .replaceAll('{y}', '${coordinates.y}');
    final subs = options.subdomains;
    if (subs.isNotEmpty && url.contains('{s}')) {
      final idx = (coordinates.x + coordinates.y) % subs.length;
      url = url.replaceAll('{s}', subs[idx]);
    }
    return url;
  }

  @override
  Future<_CachedTileImageProvider> obtainKey(ImageConfiguration cfg) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _CachedTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadBytes()
          .then(ui.ImmutableBuffer.fromUint8List)
          .then(decode),
      scale: 1.0,
      debugLabel:
          'CachedTile($providerKey/${coordinates.z}/${coordinates.x}/${coordinates.y})',
    );
  }

  Future<Uint8List> _loadBytes() async {
    final z = coordinates.z;
    final x = coordinates.x;
    final y = coordinates.y;
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      final result = await db.customSelect(
        'SELECT data, last_accessed FROM map_tiles '
        'WHERE provider = ? AND zoom = ? AND x = ? AND y = ? '
        'LIMIT 1',
        variables: [
          Variable.withString(providerKey),
          Variable.withInt(z),
          Variable.withInt(x),
          Variable.withInt(y),
        ],
      ).getSingleOrNull();

      if (result != null) {
        final lastAccessed = result.read<int>('last_accessed');
        if ((now - lastAccessed) <= ttlMs) {
          db.customStatement(
            'UPDATE map_tiles SET last_accessed = ? '
            'WHERE provider = ? AND zoom = ? AND x = ? AND y = ?',
            [now, providerKey, z, x, y],
          ).catchError((_) {});
          return result.read<Uint8List>('data');
        }
      }
    } catch (e) {
      AppLogger.log.w('TileCache: error leyendo BD para $z/$x/$y: $e');
    }

    final bytes = await _fetchFromNetwork();
    _saveTile(z, x, y, bytes, now);
    return bytes;
  }

  Future<Uint8List> _fetchFromNetwork() async {
    final response = await dio.get<List<int>>(
      _url,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'TileCache: HTTP ${response.statusCode} para '
        '${coordinates.z}/${coordinates.x}/${coordinates.y}',
      );
    }
    return Uint8List.fromList(response.data!);
  }

  void _saveTile(int z, int x, int y, Uint8List bytes, int now) {
    // MapTilesCompanion viene de pow_database.dart (generado por Drift),
    // no de package:drift/drift.dart. Ya está en scope por el import de
    // pow_database.dart arriba.
    db
        .into(db.mapTiles)
        .insertOnConflictUpdate(MapTilesCompanion.insert(
          provider: providerKey,
          zoom: z,
          x: x,
          y: y,
          data: bytes,
          lastAccessed: now,
        ))
        .catchError((e) {
      AppLogger.log.w('TileCache: error guardando tile $z/$x/$y: $e');
    });
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedTileImageProvider &&
      other.providerKey == providerKey &&
      other.coordinates == coordinates;

  @override
  int get hashCode => Object.hash(providerKey, coordinates);
}