import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../data/datasources/remote/overpass_client.dart';
import '../../domain/entities/map_way.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)));

final overpassClientProvider = Provider((ref) => OverpassClient());

final mapRepositoryProvider = Provider((ref) => MapRepositoryImpl(ref.watch(databaseProvider), ref.watch(overpassClientProvider)));

final roadsProvider = FutureProvider.family<List<MapWay>, ({double lat, double lon})>((ref, pos) {
  return ref.watch(mapRepositoryProvider).getRoadsForLocation(pos.lat, pos.lon);
});