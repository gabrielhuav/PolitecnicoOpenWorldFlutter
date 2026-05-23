import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/pow_database.dart';
import '../../../data/repository/map_repository.dart';
import '../../../data/repository/overpass_repository.dart';
import 'world_map_provider.dart';

// ==========================================
// 1. DATA SOURCES (Fuentes de datos)
// ==========================================
final localDbProvider = Provider((ref) => PowDatabase());
final remoteClientProvider = Provider((ref) => OverpassRepository());

// ==========================================
// 2. REPOSITORIOS
// ==========================================
final mapRepositoryProvider = Provider((ref) {
  // Aquí Riverpod inyecta automáticamente la DB y el Cliente
  return MapRepository(
    ref.read(localDbProvider),
    ref.read(remoteClientProvider),
  );
});

// ==========================================
// 3. ESTADOS GLOBALES DE LA UI
// ==========================================
// Usamos ChangeNotifierProvider para no tener que reescribir el WorldMapProvider actual
final mapStateProvider = ChangeNotifierProvider<WorldMapProvider>((ref) {
  return WorldMapProvider(
    mapRepository: ref.read(mapRepositoryProvider),
  );
});