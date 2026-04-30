import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // Tráfico
  bool get isTrafficEnabled => _prefs.getBool('traffic_enabled') ?? true;
  Future<void> setTrafficEnabled(bool value) => _prefs.setBool('traffic_enabled', value);

  double get trafficDensity => _prefs.getDouble('traffic_density') ?? 1.0;
  Future<void> setTrafficDensity(double value) => _prefs.setDouble('traffic_density', value);

  // Proveedor de Mapa
  String get mapProvider => _prefs.getString('map_provider') ?? 'OSM';
  Future<void> setMapProvider(String provider) => _prefs.setString('map_provider', provider);
}