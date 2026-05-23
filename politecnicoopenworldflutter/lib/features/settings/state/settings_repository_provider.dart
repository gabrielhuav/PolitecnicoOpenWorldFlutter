import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repository/settings_repository.dart';

/// Override obligatorio en `main.dart` con la instancia real de
/// [SettingsRepository] (que necesita [SharedPreferences]). Mantenerlo en
/// la capa de settings deja claro de qué feature depende.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('SettingsRepository no inicializado'),
);