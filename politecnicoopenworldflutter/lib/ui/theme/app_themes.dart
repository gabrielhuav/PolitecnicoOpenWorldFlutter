import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemes {
  AppThemes._();

  static const powFlutter = AppTheme(
    id: 'pow_flutter',
    label: 'POW Flutter',
    icon: Icons.map_outlined,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    backgroundGradient: [
      Color(0xFF0B1220),
      Color(0xFF152234),
      Color(0xFF1F3A5F),
    ],
    accentPrimary: Color(0xFF14B8A6),
    accentSecondary: Color(0xFF5EEAD4),
    accentSoft: Color(0x2614B8A6),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF),
    textTertiary: Color(0x8AFFFFFF),
    surfacePrimary: Color(0xFF1F2A3A),
    surfaceSecondary: Color(0xFF263243),
    surfaceOverlay: Color(0x0DFFFFFF),
    borderSubtle: Color(0x1FFFFFFF),
    borderAccent: Color(0x3314B8A6),
    buttonPrimary: Color(0xFF0F766E),
    buttonPrimaryText: Color(0xFFFFFFFF),
  );

  static const claro = AppTheme(
    id: 'claro',
    label: 'Claro',
    icon: Icons.light_mode_outlined,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    backgroundGradient: [
      Color(0xFFFFFFFF),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
    accentPrimary: Color(0xFF0F766E),
    accentSecondary: Color(0xFF14B8A6),
    accentSoft: Color(0x260F766E),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xB30F172A),
    textTertiary: Color(0x8A0F172A),
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF1F5F9),
    surfaceOverlay: Color(0x0D000000),
    borderSubtle: Color(0x1F000000),
    borderAccent: Color(0x330F766E),
    buttonPrimary: Color(0xFF0F766E),
    buttonPrimaryText: Color(0xFFFFFFFF),
  );

  static const escom = AppTheme(
    id: 'escom',
    label: 'ESCOM',
    icon: Icons.computer_outlined,
    brightness: Brightness.dark,
    fontFamily: 'Rubik',
    backgroundGradient: [
      Color(0xFF001233),
      Color(0xFF002A66),
      Color(0xFF0050C8),
    ],
    accentPrimary: Color(0xFFFFC107),
    accentSecondary: Color(0xFFFFE066),
    accentSoft: Color(0x26FFC107),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF),
    textTertiary: Color(0x8AFFFFFF),
    surfacePrimary: Color(0xFF002145),
    surfaceSecondary: Color(0xFF003580),
    surfaceOverlay: Color(0x14FFFFFF),
    borderSubtle: Color(0x1FFFFFFF),
    borderAccent: Color(0x33FFC107),
    buttonPrimary: Color(0xFFFFC107),
    buttonPrimaryText: Color(0xFF001233),
  );

  static const guindaIpn = AppTheme(
    id: 'guinda_ipn',
    label: 'Guinda IPN',
    icon: Icons.school_outlined,
    brightness: Brightness.dark,
    fontFamily: 'Roboto Slab',
    backgroundGradient: [
      Color(0xFF1F0510),
      Color(0xFF4D0A1E),
      Color(0xFF7B0F2D),
    ],
    accentPrimary: Color(0xFFD4AF37),
    accentSecondary: Color(0xFFFFD700),
    accentSoft: Color(0x26D4AF37),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF),
    textTertiary: Color(0x8AFFFFFF),
    surfacePrimary: Color(0xFF3A0814),
    surfaceSecondary: Color(0xFF4D0A1E),
    surfaceOverlay: Color(0x14FFFFFF),
    borderSubtle: Color(0x1FFFFFFF),
    borderAccent: Color(0x33D4AF37),
    buttonPrimary: Color(0xFFD4AF37),
    buttonPrimaryText: Color(0xFF1F0510),
  );

  static const cyberpunk = AppTheme(
    id: 'cyberpunk',
    label: 'Cyberpunk',
    icon: Icons.electric_bolt_outlined,
    brightness: Brightness.dark,
    fontFamily: 'Orbitron',
    backgroundGradient: [
      Color(0xFF05000A),
      Color(0xFF1A0030),
      Color(0xFF2D0050),
    ],
    accentPrimary: Color(0xFFFF00FF),
    accentSecondary: Color(0xFF00FFFF),
    accentSoft: Color(0x26FF00FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB300FFFF),
    textTertiary: Color(0x8AFFFFFF),
    surfacePrimary: Color(0xFF15001F),
    surfaceSecondary: Color(0xFF1F002E),
    surfaceOverlay: Color(0x1AFF00FF),
    borderSubtle: Color(0x3300FFFF),
    borderAccent: Color(0x4DFF00FF),
    buttonPrimary: Color(0xFFFF00FF),
    buttonPrimaryText: Color(0xFF000000),
  );

  /// Catálogo en orden de presentación (NO incluye "Sistema": esa es opción del selector).
  static const List<AppTheme> all = [
    powFlutter,
    claro,
    escom,
    guindaIpn,
    cyberpunk,
  ];

  /// Tema por defecto si no hay preferencia o el id es desconocido.
  static const AppTheme fallback = powFlutter;

  /// Resuelve un tema por su id.
  static AppTheme byId(String? id) {
    if (id == null) return fallback;
    for (final t in all) {
      if (t.id == id) return t;
    }
    return fallback;
  }
}
