import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/game_settings_providers.dart';
import '../../core/utils/map_tile_provider.dart';
import '../../core/utils/providers.dart';

class GameSettingsScreen extends ConsumerStatefulWidget {
  const GameSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends ConsumerState<GameSettingsScreen> {
  // ── Draft local — se compara con los providers para detectar cambios ─
  late MapTileProvider _mapProvider;
  late ControlType _controlType;
  late bool _invertControls;
  late double _controlSize;
  late bool _showFps;
  late bool _showDatabase;
  late bool _freeMovement;

  @override
  void initState() {
    super.initState();
    _loadFromProviders();
  }

  // ── Lee el estado actual de los providers ────────────────────────────
  void _loadFromProviders() {
    _mapProvider = ref.read(mapTileProviderProvider);
    _controlType = ref.read(controlTypeProvider);
    _invertControls = ref.read(invertControlsProvider);
    _controlSize = ref.read(controlSizeProvider);
    _showFps = ref.read(showFpsProvider);
    _showDatabase = ref.read(showDatabaseProvider);
    _freeMovement = ref.read(freeMovementProvider);
  }

  // ── Aplica draft a los providers y notifica ──────────────────────────
  Future<void> _save() async {
    final settingsRepository = ref.read(settingsRepositoryProvider);

    ref.read(mapTileProviderProvider.notifier).state = _mapProvider;
    ref.read(controlTypeProvider.notifier).state = _controlType;
    ref.read(invertControlsProvider.notifier).state = _invertControls;
    ref.read(controlSizeProvider.notifier).state = _controlSize;
    ref.read(showFpsProvider.notifier).state = _showFps;
    ref.read(showDatabaseProvider.notifier).state = _showDatabase;
    ref.read(freeMovementProvider.notifier).state = _freeMovement;

    await Future.wait([
      settingsRepository.setMapProvider(_mapProvider),
      settingsRepository.setControlType(_controlType),
      settingsRepository.setInvertControls(_invertControls),
      settingsRepository.setControlSize(_controlSize),
      settingsRepository.setShowFps(_showFps),
      settingsRepository.setShowDatabase(_showDatabase),
      settingsRepository.setFreeMovement(_freeMovement),
    ]);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  // ── Restaura el draft desde los providers ────────────────────────────
  void _reset() {
    setState(() => _loadFromProviders());
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final savedMapProvider = ref.watch(mapTileProviderProvider);
    final savedControlType = ref.watch(controlTypeProvider);
    final savedInvertControls = ref.watch(invertControlsProvider);
    final savedControlSize = ref.watch(controlSizeProvider);
    final savedShowFps = ref.watch(showFpsProvider);
    final savedShowDatabase = ref.watch(showDatabaseProvider);
    final savedFreeMovement = ref.watch(freeMovementProvider);

    final hasChanges = _mapProvider != savedMapProvider ||
        _controlType != savedControlType ||
        _invertControls != savedInvertControls ||
        _controlSize != savedControlSize ||
        _showFps != savedShowFps ||
        _showDatabase != savedShowDatabase ||
        _freeMovement != savedFreeMovement;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1220),
              Color(0xFF152234),
              Color(0xFF1F3A5F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _buildSection(
                      icon: Icons.map_outlined,
                      title: 'Mapa',
                      children: [_buildMapProviderSelector()],
                    ),
                    _buildSection(
                      icon: Icons.gamepad_outlined,
                      title: 'Controles',
                      children: [
                        _buildControlTypeSelector(),
                        _buildDivider(),
                        _buildToggle(
                          label: 'Invertir controles',
                          value: _invertControls,
                          onChanged: (v) => setState(() => _invertControls = v),
                        ),
                        _buildDivider(),
                        _buildSizeSlider(),
                      ],
                    ),
                    _buildSection(
                      icon: Icons.tune_outlined,
                      title: 'Interfaz',
                      children: [
                        _buildToggle(
                          label: 'Mostrar FPS',
                          value: _showFps,
                          onChanged: (v) => setState(() => _showFps = v),
                        ),
                        _buildDivider(),
                        _buildToggle(
                          label: 'Mostrar Base de Datos',
                          subtitle: 'Muestra estadísticas de la DB local',
                          value: _showDatabase,
                          onChanged: (v) => setState(() => _showDatabase = v),
                        ),
                      ],
                    ),
                    _buildSection(
                      icon: Icons.sports_esports_outlined,
                      title: 'Jugabilidad',
                      children: [
                        _buildToggle(
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
               _buildActionBar(hasChanges),
            ],
          ),
        ),
      ),
    );
  }

  // ── Estructura ────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Text(
            'Ajustes del juego',
            style: TextStyle(
              color: Colors.white,
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
                Icon(icon, color: Colors.tealAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.tealAccent,
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.tealAccent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.07),
        indent: 16,
        endIndent: 16,
      );

  Widget _buildActionBar(bool hasChanges) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220).withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Colors.tealAccent.withOpacity(0.2),
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
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: hasChanges ? Colors.white30 : Colors.transparent,
                  ),
                ),
                disabledBackgroundColor: Colors.white.withOpacity(0.03),
                disabledForegroundColor: Colors.white24,
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
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade800,
                disabledForegroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets de ajustes ────────────────────────────────────────────────

  Widget _buildToggle({
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: Colors.tealAccent.shade700,
      inactiveTrackColor: Colors.white12,
    );
  }

  Widget _buildMapProviderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: MapTileProvider.values.map((provider) {
          final isSelected = _mapProvider == provider;
          return GestureDetector(
            onTap: () => setState(() => _mapProvider = provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.tealAccent.withOpacity(0.15)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected ? Colors.tealAccent.shade400 : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Colors.tealAccent.shade400
                        : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    provider.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const Expanded(
            child: Text('Tipo de control',
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ),
          ToggleButtons(
            isSelected:
                ControlType.values.map((t) => t == _controlType).toList(),
            onPressed: (i) =>
                setState(() => _controlType = ControlType.values[i]),
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.black87,
            fillColor: Colors.tealAccent.shade700,
            color: Colors.white60,
            borderColor: Colors.white12,
            selectedBorderColor: Colors.tealAccent.shade700,
            constraints: const BoxConstraints(minHeight: 36, minWidth: 90),
            children: ControlType.values
                .map((t) => Text(t.label, style: const TextStyle(fontSize: 13)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tamaño de controles',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              Text(
                '${(_controlSize * 100).round()}%',
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.tealAccent.shade700,
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.tealAccent.shade400,
              overlayColor: Colors.tealAccent.withOpacity(0.15),
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
