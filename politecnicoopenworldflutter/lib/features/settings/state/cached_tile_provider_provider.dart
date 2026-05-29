import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/pow_database.dart';
import '../../map_exterior/state/map_providers.dart';
import 'map_tile_provider.dart';
import '../../../ui/cached_network_tile_provider.dart';

/// Instancia única del [CachedNetworkTileProvider] compartida entre
/// todos los widgets que necesiten un TileProvider con caché.
///
/// Se recrea automáticamente cuando el usuario cambia el proveedor
/// de tiles en ajustes (porque depende de [mapTileProviderProvider]).
///
/// El [PowDatabase] se obtiene del provider ya existente para no
/// abrir una segunda conexión a SQLite.
final cachedTileProviderProvider =
    Provider<CachedNetworkTileProvider>((ref) {
  final db = ref.read(localDbProvider);
  final mapProvider = ref.watch(mapTileProviderProvider);

  return CachedNetworkTileProvider(
    db: db,
    providerKey: mapProvider.name, // ej. 'cartoLight', 'osm', etc.
    ttlDays: 30,
  );
});
