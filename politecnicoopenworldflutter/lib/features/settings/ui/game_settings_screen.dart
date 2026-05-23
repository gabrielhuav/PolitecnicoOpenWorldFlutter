import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/theme/app_theme.dart';
import '../../../ui/theme/theme_extensions.dart';
import '../state/game_settings_providers.dart';
import '../state/map_tile_provider.dart';
import '../../../core/utils/providers.dart';

class GameSettingsScreen extends ConsumerStatefulWidget {
  const GameSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends ConsumerState<GameSettingsScreen> {
  late MapTileProvider _mapProvider;
  late ControlType _controlType;
  late bool _invertControls;
  late double _controlSize;
  late bool _showFps;
  late bool _showDatabase;
  late bool _freeMovement;
  late bool _useRealLocation;

  @override
  void initState() {
    super.initState();
    _loadFromProviders();
  }

  void _loadFromProviders() {
    _mapProvider = ref.read(mapTileProviderProvider);
    _controlType = ref.read(controlTypeProvider);
    _invertControls = ref.read(invertControlsProvider);
    _controlSize = ref.read(controlSizeProvider);
    _showFps = ref.read(showFpsProvider);
    _showDatabase = ref.read(showDatabaseProvider);
    _freeMovement = ref.read(freeMovementProvider);
    _useRealLocation = ref.read(useRealLocationProvider);
}


  Future<void> _save() async {
    final settingsRepository = ref.read(settingsRepositoryProvider);

    ref.read(mapTileProviderProvider.notifier).state = _mapProvider;
    ref.read(controlTypeProvider.notifier).state = _controlType;
    ref.read(invertControlsProvider.notifier).state = _invertControls;
    ref.read(controlSizeProvider.notifier).state = _controlSize;
    ref.read(showFpsProvider.notifier).state = _showFps;
    ref.read(showDatabaseProvider.notifier).state = _showDatabase;
    ref.read(freeMovementProvider.notifier).state = _freeMovement;
    ref.read(useRealLocationProvider.notifier).state = _useRealLocation;

    await Future.wait<void>([
      settingsRepository.setMapProvider(_mapProvider),
      settingsRepository.setControlType(_controlType),
      settingsRepository.setInvertControls(_invertControls),
      settingsRepository.setControlSize(_controlSize),
      settingsRepository.setShowFps(_showFps),
      settingsRepository.setShowDatabase(_showDatabase),
      settingsRepository.setFreeMovement(_freeMovement),
      settingsRepository.setUseRealLocation(_useRealLocation),
    ]);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }
  void _reset() => setState(() => _loadFromProviders());

  @override
  Widget build(BuildContext context) {
    final theme = ref.appTheme;

    final savedMapProvider = ref.watch(mapTileProviderProvider);
    final savedControlType = ref.watch(controlTypeProvider);
    final savedInvertControls = ref.watch(invertControlsProvider);
    final savedControlSize = ref.watch(controlSizeProvider);
    final savedShowFps = ref.watch(showFpsProvider);
    final savedShowDatabase = ref.watch(showDatabaseProvider);
    final savedFreeMovement = ref.watch(freeMovementProvider);
    final savedUseRealLocation = ref.watch(useRealLocationProvider);

    final hasChanges = _mapProvider != savedMapProvider ||
        _controlType != savedControlType ||
        _invertControls != savedInvertControls ||
        _controlSize != savedControlSize ||
        _showFps != savedShowFps ||
        _showDatabase != savedShowDatabase ||
        _freeMovement != savedFreeMovement ||
        _useRealLocation != savedUseRealLocation;


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
                      icon: Icons.map_outlined,
                      title: 'Mapa',
                      children: [_buildMapProviderSelector(theme)],
                    ),
                    _buildSection(
                      theme: theme,
                      icon: Icons.gamepad_outlined,
                      title: 'Controles',
                      children: [
                        _buildControlTypeSelector(theme),
                        _buildDivider(theme),
                        _buildToggle(
                          theme: theme,
                          label: 'Invertir controles',
                          value: _invertControls,
                          onChanged: (v) => setState(() => _invertControls = v),
                        ),
                        _buildDivider(theme),
                        _buildSizeSlider(theme),
                      ],
                    ),
                    _buildSection(
                      theme: theme,
                      icon: Icons.tune_outlined,
                      title: 'Interfaz',
                      children: [
                        _buildToggle(
                          theme: theme,
                          label: 'Mostrar FPS',
                          value: _showFps,
                          onChanged: (v) => setState(() => _showFps = v),
                        ),
                        _buildDivider(theme),
                        _buildToggle(
                          theme: theme,
                          label: 'Mostrar Base de Datos',
                          subtitle: 'Muestra estadísticas de la DB local',
                          value: _showDatabase,
                          onChanged: (v) => setState(() => _showDatabase = v),
                        ),
                      ],
                    ),
                    _buildSection(
                      theme: theme,
                      icon: Icons.sports_esports_outlined,
                      title: 'Jugabilidad',
                      children: [
                        _buildToggle(
                          theme: theme,
                          label: 'Usar ubicación real (GPS)',
                          subtitle: 'Si está apagado, aparecerás en ESCOM.',
                          value: _useRealLocation,
                          onChanged: (v) => setState(() => _useRealLocation = v),
                        ),
                        _buildToggle(
                          theme: theme,
                          label: 'Movimiento libre',
                          subtitle:
                              'El jugador puede moverse fuera de las calles',
                          value: _freeMovement,
                          onChanged: (v) => setState(() => _freeMovement = v),
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
            'Ajustes del juego',
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
          top: BorderSide(
            color: theme.borderAccent,
            width: 1,
          ),
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
  
  Widget _buildToggle({
    required AppTheme theme,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title:
          Text(label, style: TextStyle(color: theme.textPrimary, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(color: theme.textTertiary, fontSize: 12))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: theme.buttonPrimary,
      inactiveTrackColor: theme.borderSubtle,
    );
  }

  Widget _buildMapProviderSelector(AppTheme theme) {
    final Map<MapTileCategory, List<MapTileProvider>> grouped = {};
    for (final provider in MapTileProvider.values) {
      grouped.putIfAbsent(provider.category, () => []).add(provider);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6, left: 2),
              child: Text(
                entry.key.label.toUpperCase(),
                style: TextStyle(
                  color: theme.textTertiary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map((p) => _buildProviderTile(theme, p)),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderTile(AppTheme theme, MapTileProvider provider) {
    final isSelected = _mapProvider == provider;
    return GestureDetector(
      onTap: () => setState(() => _mapProvider = provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentSoft : theme.surfaceOverlay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.accentSecondary : theme.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? theme.accentSecondary : theme.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.label,
                style: TextStyle(
                  color: isSelected ? theme.textPrimary : theme.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlTypeSelector(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text('Tipo de control',
                style: TextStyle(color: theme.textPrimary, fontSize: 15)),
          ),
          ToggleButtons(
            isSelected:
                ControlType.values.map((t) => t == _controlType).toList(),
            onPressed: (i) =>
                setState(() => _controlType = ControlType.values[i]),
            borderRadius: BorderRadius.circular(8),
            selectedColor: theme.buttonPrimaryText,
            fillColor: theme.buttonPrimary,
            color: theme.textSecondary,
            borderColor: theme.borderSubtle,
            selectedBorderColor: theme.buttonPrimary,
            constraints: const BoxConstraints(minHeight: 36, minWidth: 90),
            children: ControlType.values
                .map((t) => Text(t.label, style: const TextStyle(fontSize: 13)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSlider(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tamaño de controles',
                  style: TextStyle(color: theme.textPrimary, fontSize: 15)),
              Text(
                '${(_controlSize * 100).round()}%',
                style: TextStyle(
                  color: theme.accentSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.buttonPrimary,
              inactiveTrackColor: theme.borderSubtle,
              thumbColor: theme.accentSecondary,
              overlayColor: theme.accentSoft,
            ),
            child: Slider(
              value: _controlSize,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              onChanged: (v) => setState(() => _controlSize = v),
            ),
          ),
        ],
      ),
    );
  }
}
