import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens visuales de un tema. Inmutable y declarativo.
/// Todo lo que hoy está hardcodeado en las pantallas debe vivir aquí.
@immutable
class AppTheme {
  final String id;
  final String label;
  final IconData icon;
  final Brightness brightness;

  // Tipografía (nombre exacto como aparece en Google Fonts)
  final String fontFamily;

  // Gradiente de fondo (top-left → bottom-right)
  final List<Color> backgroundGradient;

  // Acentos
  final Color accentPrimary; // antes: tealAccent.shade700
  final Color accentSecondary; // antes: tealAccent.shade400
  final Color accentSoft; // antes: tealAccent.withValues(alpha: 0.15)

  // Texto sobre el fondo
  final Color textPrimary; // antes: Colors.white
  final Color textSecondary; // antes: Colors.white70
  final Color textTertiary; // antes: Colors.white54

  // Superficies (cards, paneles)
  final Color surfacePrimary; // antes: Color(0xFF1F2A3A)
  final Color surfaceSecondary; // antes: Color(0xFF263243)
  final Color surfaceOverlay; // antes: Colors.white.withValues(alpha: 0.05)

  // Bordes
  final Color borderSubtle; // antes: Colors.white12
  final Color borderAccent; // antes: tealAccent.withValues(alpha: 0.2)

  // Botones primarios
  final Color buttonPrimary;
  final Color buttonPrimaryText;

  const AppTheme({
    required this.id,
    required this.label,
    required this.icon,
    required this.brightness,
    required this.fontFamily,
    required this.backgroundGradient,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceOverlay,
    required this.borderSubtle,
    required this.borderAccent,
    required this.buttonPrimary,
    required this.buttonPrimaryText,
  });

  /// ThemeData de Flutter — para que SnackBars, diálogos, Switches, etc.
  /// respeten automáticamente el tema seleccionado.
  ThemeData toFlutterThemeData() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentPrimary,
        brightness: brightness,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.getTextTheme(fontFamily, base.textTheme),
    );
  }
}
