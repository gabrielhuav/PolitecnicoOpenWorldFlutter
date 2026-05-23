import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../ui/theme/app_theme.dart';
import '../../../ui/theme/app_themes.dart';
import '../../../ui/theme/theme_extensions.dart';
import '../../../ui/theme/theme_providers.dart';
import '../../../core/utils/providers.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  late String _themeId;

  @override
  void initState() {
    super.initState();
    _loadFromProviders();
  }

  void _loadFromProviders() {
    _themeId = ref.read(selectedThemeIdProvider);
  }

  Future<void> _save() async {
    final settingsRepository = ref.read(settingsRepositoryProvider);
    ref.read(selectedThemeIdProvider.notifier).state = _themeId;
    await settingsRepository.setThemeId(_themeId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajustes guardados'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  void _reset() => setState(() => _loadFromProviders());

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;
    final savedThemeId = ref.watch(selectedThemeIdProvider);
    final hasChanges = _themeId != savedThemeId;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(theme),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _buildSection(
                      theme: theme,
                      icon: Icons.palette_outlined,
                      title: 'Tema',
                      children: [_buildThemeSelector(theme)],
                    ),
                    _buildSection(
                      theme: theme,
                      icon: Icons.info_outline,
                      title: 'Información',
                      children: [
                        FutureBuilder<PackageInfo>(
                          future: _packageInfoFuture,
                          builder: (context, snapshot) {
                            final package = snapshot.data;
                            final version = package == null
                                ? 'Cargando...'
                                : '${package.version}+${package.buildNumber}';
                            return _buildInfoTile(
                              theme: theme,
                              icon: Icons.tag,
                              title: 'Versión',
                              value: version,
                            );
                          },
                        ),
                        _buildDivider(theme),
                        _buildInfoTile(
                          theme: theme,
                          icon: Icons.code,
                          title: 'Desarrolladores',
                          value: 'Próximamente...',
                        ),
                        _buildDivider(theme),
                        _buildInfoTile(
                          theme: theme,
                          icon: Icons.star_outline,
                          title: 'Créditos',
                          value: 'Próximamente...',
                        ),
                        _buildDivider(theme),
                        _buildInfoTile(
                          theme: theme,
                          icon: Icons.map_outlined,
                          title: 'Datos del mapa',
                          value: 'OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildActionBar(theme, hasChanges),
            ],
          ),
        ),
      ),
    );
  }

  // ── Estructura ───────────────────────────────────────────────────────

  Widget _buildTopBar(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.textPrimary, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Acerca de la app',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, color: theme.accentSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: theme.accentSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.surfaceOverlay,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.borderAccent,
                width: 1,
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppTheme theme) => Divider(
        height: 1,
        thickness: 1,
        color: theme.borderSubtle,
        indent: 16,
        endIndent: 16,
      );

  Widget _buildActionBar(AppTheme theme, bool hasChanges) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.surfacePrimary.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: theme.borderAccent, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: hasChanges ? _reset : null,
              icon: const Icon(Icons.restore, size: 20),
              label: const Text('Restablecer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.surfaceOverlay,
                foregroundColor: theme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: hasChanges ? theme.textTertiary : Colors.transparent,
                  ),
                ),
                disabledBackgroundColor: theme.surfaceOverlay,
                disabledForegroundColor: theme.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: hasChanges ? _save : null,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text(
                'Guardar cambios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.buttonPrimary,
                foregroundColor: theme.buttonPrimaryText,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor:
                    theme.buttonPrimary.withValues(alpha: 0.3),
                disabledForegroundColor: theme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Selector visual de temas ─────────────────────────────────────────

  Widget _buildThemeSelector(AppTheme currentTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: themeOptions
            .map((opt) => _buildThemeCard(currentTheme, opt))
            .toList(),
      ),
    );
  }

  Widget _buildThemeCard(AppTheme currentTheme, ThemeOption option) {
    final isSelected = _themeId == option.id;
    // Para el preview, buscamos el tema que corresponde a la opción (si es que
    // no es "seguir al sistema") y mostramos su gradiente e info de fuente.
    final preview = AppThemes.byId(option.id);

    return GestureDetector(
      onTap: () => setState(() => _themeId = option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: currentTheme.surfaceOverlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? currentTheme.accentSecondary
                : currentTheme.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Preview del gradiente ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Container(
                width: 72,
                height: 82,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: preview.backgroundGradient,
                  ),
                ),
                child: Center(
                  child: Icon(
                    option.icon,
                    color: preview.textPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nombre con la fuente del tema
                  Text(
                    option.label,
                    style: GoogleFonts.getFont(
                      preview.fontFamily,
                      textStyle: TextStyle(
                        color: currentTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Swatch(color: preview.accentPrimary),
                      const SizedBox(width: 6),
                      _Swatch(color: preview.accentSecondary),
                      const SizedBox(width: 6),
                      _Swatch(color: preview.buttonPrimary),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          preview.fontFamily,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: currentTheme.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Indicador de selección ──
            Padding(
              padding: const EdgeInsets.only(right: 14, left: 8),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? currentTheme.accentSecondary
                    : currentTheme.textTertiary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Información ──────────────────────────────────────────────────────

  Widget _buildInfoTile({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: theme.accentSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTertiary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
    );
  }
}
