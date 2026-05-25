import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/dao/road_zone_dao.dart';
import '../../../data/local/pow_database.dart';
import '../../../data/network/overpass_repository.dart';
import '../../../data/repository/map_repository_impl.dart';
import 'world_map_provider.dart';

export '../../../data/repository/map_repository_impl.dart';
export '../../../../Multiplayer/multiplayer_notifier.dart';

enum MapSyncStatus { online, downloading, offline }

// ==========================================
// 1. DATA SOURCES
// ==========================================
final localDbProvider = Provider((ref) => PowDatabase());
final remoteClientProvider = Provider((ref) => OverpassRepository());

// ==========================================
// 2. DAO DE CACHÉ DE CALLES
// ==========================================
final roadZoneDaoProvider = Provider<RoadZoneDao>((ref) {
  return RoadZoneDao(ref.read(localDbProvider));
});

// ==========================================
// 3. REPOSITORIO
// ==========================================
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository(
    ref.read(roadZoneDaoProvider),
    ref.read(remoteClientProvider),
  );
});

// ==========================================
// 4. ESTADO DE LA UI
// ==========================================
final mapStateProvider = ChangeNotifierProvider<WorldMapProvider>((ref) {
  return WorldMapProvider(
    mapRepository: ref.read(mapRepositoryProvider),
  );
});

final mapSyncStatusProvider = StateProvider<MapSyncStatus>((ref) {
  // Initialize with your default state
  return MapSyncStatus.online;
});

