import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'theme_providers.dart';

/// Azúcar sintáctica para acceder al tema desde widgets Consumer.
/// Uso: `ref.appTheme.accentPrimary`, `ref.appTheme.backgroundGradient`, etc.
extension AppThemeWidgetRef on WidgetRef {
  AppTheme get appTheme => watch(currentThemeProvider);
  AppTheme get appThemeRead => read(currentThemeProvider);
}
