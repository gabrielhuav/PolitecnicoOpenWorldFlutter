import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OBSERVAMOS EL ESTADO GLOBAL
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF2C1E26),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'AJUSTES DEL JUEGO',
            style: TextStyle(color: Color(0xFFF1C40F), fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              color: Color(0xFF7A2048),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            tabs: [
              Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 18), SizedBox(width: 8), Text('Mapa')])),
              Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.gamepad, size: 18), SizedBox(width: 8), Text('Controles')])),
              Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.videogame_asset, size: 18), SizedBox(width: 8), Text('Jugabilidad')])),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1419),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1C40F).withOpacity(0.3)),
                  ),
                  child: TabBarView(
                    children: [
                      // Pestaña 1: Mapa
                      _buildMapTab(settingsState, settingsNotifier),
                      // Pestaña 2: Controles
                      _buildControlsTab(context, settingsState, settingsNotifier),
                      // Pestaña 3: Jugabilidad
                      const Center(child: Text('Sin ajustes disponibles actualmente.', style: TextStyle(color: Colors.white54))),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE74C3C),
                    side: const BorderSide(color: Color(0xFFE74C3C)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('SALIR AL MENÚ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab(SettingsState state, SettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MAPA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Proveedor de Mapa', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFF3B2530), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF7A2048))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.mapProvider,
                isExpanded: true,
                dropdownColor: const Color(0xFF3B2530),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF1C40F)),
                items: ['OSMDroid (Nativo)', 'Google Maps', 'Mapbox'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) notifier.changeMapProvider(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsTab(BuildContext context, SettingsState state, SettingsNotifier notifier) {

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final maxScale = isPortrait ? 1.0 : 1.4;
    final safeScale = state.controlsScale.clamp(0.6, maxScale);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CONTROLES', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Estilo de Movimiento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  text: ControlType.dpad.displayName,
                  isSelected: state.controlType == ControlType.dpad,
                  onTap: () => notifier.changeControlType(ControlType.dpad),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ToggleButton(
                  text: ControlType.joystick.displayName,
                  isSelected: state.controlType == ControlType.joystick,
                  onTap: () => notifier.changeControlType(ControlType.joystick),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Tamaño en Pantalla: ${(safeScale * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(isPortrait ? 'Límite ajustado a 100% por modo vertical.' : 'No superará los límites de la pantalla.', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF7A2048),
              inactiveTrackColor: const Color(0xFF3B2530),
              thumbColor: const Color(0xFFF1C40F),
              overlayColor: const Color(0xFFF1C40F).withOpacity(0.2),
            ),
            child: Slider(
              value: safeScale,
              min: 0.6,
              max: maxScale,
              onChanged: (value) => notifier.changeControlsScale(value),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Intercambiar Lados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Mueve la acción a la izquierda', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Switch(
                value: state.swapControls,
                activeColor: const Color(0xFFF1C40F),
                activeTrackColor: const Color(0xFF7A2048),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: const Color(0xFF3B2530),
                onChanged: (value) => notifier.toggleSwapControls(value),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AC0D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                notifier.saveControlsSettings();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración guardada (En memoria)')));
              },
              child: const Text('GUARDAR CONFIGURACIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A2048) : const Color(0xFF3B2530),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ),
    );
  }
}