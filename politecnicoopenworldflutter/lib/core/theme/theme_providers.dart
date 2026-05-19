import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'app_themes.dart';

/// ID del tema seleccionado por el usuario.
final selectedThemeIdProvider =
    StateProvider<String>((ref) => AppThemes.fallback.id);

/// Tema concreto que la UI debe pintar.
final currentThemeProvider = Provider<AppTheme>((ref) {
  final id = ref.watch(selectedThemeIdProvider);
  return AppThemes.byId(id);
});

class ThemeOption {
  final String id;
  final String label;
  final IconData icon;
  const ThemeOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

List<ThemeOption> get themeOptions => AppThemes.all
    .map((t) => ThemeOption(id: t.id, label: t.label, icon: t.icon))
    .toList();
