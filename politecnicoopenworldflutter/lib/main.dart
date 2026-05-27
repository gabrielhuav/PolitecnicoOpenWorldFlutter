import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/main_menu/ui/start_menu_screen.dart';
import 'core/utils/app_logger.dart';
import 'features/settings/state/game_settings_providers.dart';
import 'features/settings/state/map_tile_provider.dart';
import 'core/utils/providers.dart';
import 'ui/theme/theme_providers.dart';
import 'data/repository/settings_repository.dart';
import '../multiplayer/multiplayer_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init();
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);

  FlutterError.onError = (details) {
    AppLogger.log.e(
      'Flutter Error: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.log.e(
      'Platform Error: ${error.toString()}',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        mapTileProviderProvider.overrideWith(
          (ref) => settingsRepository.mapProvider,
        ),
        controlTypeProvider.overrideWith(
          (ref) => settingsRepository.controlType,
        ),
        invertControlsProvider.overrideWith(
          (ref) => settingsRepository.invertControls,
        ),
        controlSizeProvider.overrideWith(
          (ref) => settingsRepository.controlSize,
        ),
        showFpsProvider.overrideWith(
          (ref) => settingsRepository.showFps,
        ),
        showDatabaseProvider.overrideWith(
          (ref) => settingsRepository.showDatabase,
        ),
        freeMovementProvider.overrideWith(
          (ref) => settingsRepository.freeMovement,
        ),
        useRealLocationProvider.overrideWith(
          (ref) => settingsRepository.useRealLocation,
        ),
        selectedThemeIdProvider.overrideWith(
          (ref) => settingsRepository.themeId,
        ),
        multiplayerServerUrlProvider.overrideWith(
          (ref) => settingsRepository.multiplayerServerUrl,
        ),
      ],
      child: const PolitecnicoOpenWorldApp(),
    ),
  );
}

class PolitecnicoOpenWorldApp extends ConsumerWidget {
  const PolitecnicoOpenWorldApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    return MaterialApp(
      title: 'Politécnico Open World',
      theme: theme.toFlutterThemeData(),
      home: const StartMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
