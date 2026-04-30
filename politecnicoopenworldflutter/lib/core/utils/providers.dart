import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos tus fuentes de datos y repositorios
import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/overpass_client.dart';
import '../../data/repositories/map_repository_impl.dart';

// Importamos la lógica de estado
import '../../presentation/state/map_provider.dart';

// ==========================================
// 1. DATA SOURCES (Fuentes de datos)
// ==========================================
final localDbProvider = Provider((ref) => AppDatabase());
final remoteClientProvider = Provider((ref) => OverpassClient());

// ==========================================
// 2. REPOSITORIOS
// ==========================================
final mapRepositoryProvider = Provider((ref) {
  // Aquí Riverpod inyecta automáticamente la DB y el Cliente
  return MapRepositoryImpl(
    ref.read(localDbProvider),
    ref.read(remoteClientProvider),
  );
});

// ==========================================
// 3. ESTADOS GLOBALES DE LA UI
// ==========================================
// Usamos ChangeNotifierProvider para no tener que reescribir tu MapProvider actual
final mapStateProvider = ChangeNotifierProvider<MapProvider>((ref) {
  return MapProvider(
    mapRepository: ref.read(mapRepositoryProvider),
  );
});
