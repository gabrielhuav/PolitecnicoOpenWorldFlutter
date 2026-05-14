import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ControlType {
  dpad('Cruz de Botones'),
  joystick('Joystick Virtual');

  final String displayName;
  const ControlType(this.displayName);
}

class SettingsState {
  final String mapProvider;
  final ControlType controlType;
  final double controlsScale;
  final bool swapControls;

  SettingsState({
    this.mapProvider = 'OSMDroid (Nativo)',
    this.controlType = ControlType.dpad,
    this.controlsScale = 1.0,
    this.swapControls = false,
  });

  SettingsState copyWith({
    String? mapProvider,
    ControlType? controlType,
    double? controlsScale,
    bool? swapControls,
  }) {
    return SettingsState(
      mapProvider: mapProvider ?? this.mapProvider,
      controlType: controlType ?? this.controlType,
      controlsScale: controlsScale ?? this.controlsScale,
      swapControls: swapControls ?? this.swapControls,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()); // Estado inicial

  void changeMapProvider(String provider) {
    state = state.copyWith(mapProvider: provider);
  }

  void changeControlType(ControlType type) {
    state = state.copyWith(controlType: type);
  }

  void changeControlsScale(double scale) {
    state = state.copyWith(controlsScale: scale);
  }

  void toggleSwapControls(bool swap) {
    state = state.copyWith(swapControls: swap);
  }

  void saveControlsSettings() {
    // Más adelante se conectará SharedPreferences (o SQLite/Drift)
    // para que la configuración sobreviva cuando se cierre la app
    final currentState = state;
    debugPrint("Guardando en BD: Tipo=${currentState.controlType.name}, Escala=${currentState.controlsScale}, Swap=${currentState.swapControls}");
  }
}

// Exponemos el Provider para que toda la app lo pueda escuchar
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});