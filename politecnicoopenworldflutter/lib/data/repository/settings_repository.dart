import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/state/game_settings_providers.dart';
import '../../features/settings/state/map_tile_provider.dart';
import '../../ui/theme/app_themes.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // Tema
  String get themeId => _prefs.getString('theme_id') ?? AppThemes.fallback.id;
  Future<void> setThemeId(String id) => _prefs.setString('theme_id', id);

  // Tráfico
  bool get isTrafficEnabled => _prefs.getBool('traffic_enabled') ?? true;
  Future<void> setTrafficEnabled(bool value) =>
      _prefs.setBool('traffic_enabled', value);

  double get trafficDensity => _prefs.getDouble('traffic_density') ?? 1.0;
  Future<void> setTrafficDensity(double value) =>
      _prefs.setDouble('traffic_density', value);

  // Proveedor de Mapa
  MapTileProvider get mapProvider {
    final saved = _prefs.getString('map_provider');
    return MapTileProvider.values.firstWhere(
      (provider) => provider.name == saved,
      orElse: () => defaultMapTileProvider,
    );
  }

  Future<void> setMapProvider(MapTileProvider provider) =>
      _prefs.setString('map_provider', provider.name);

  ControlType get controlType {
    final saved = _prefs.getString('control_type');
    return ControlType.values.firstWhere(
      (type) => type.name == saved,
      orElse: () => ControlType.buttons,
    );
  }

  Future<void> setControlType(ControlType type) =>
      _prefs.setString('control_type', type.name);

  bool get invertControls => _prefs.getBool('invert_controls') ?? false;
  Future<void> setInvertControls(bool value) =>
      _prefs.setBool('invert_controls', value);

  double get controlSize => _prefs.getDouble('control_size') ?? 1.0;
  Future<void> setControlSize(double value) =>
      _prefs.setDouble('control_size', value);

  bool get showFps => _prefs.getBool('show_fps') ?? false;
  Future<void> setShowFps(bool value) => _prefs.setBool('show_fps', value);

  bool get showDatabase => _prefs.getBool('show_database') ?? false;
  Future<void> setShowDatabase(bool value) =>
      _prefs.setBool('show_database', value);

  bool get useRealLocation => _prefs.getBool('use_real_location') ?? false;
  Future<void> setUseRealLocation(bool value) =>
      _prefs.setBool('use_real_location', value);

  bool get freeMovement => _prefs.getBool('free_movement') ?? false;
  Future<void> setFreeMovement(bool value) =>
      _prefs.setBool('free_movement', value);

  // Multijugador
  String get multiplayerServerUrl =>
      _prefs.getString('multiplayer_server_url') ?? 'wss://politecnicoopenworld.onrender.com';
  Future<void> setMultiplayerServerUrl(String value) =>
      _prefs.setString('multiplayer_server_url', value);
}