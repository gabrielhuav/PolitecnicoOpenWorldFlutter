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

  /// Registra la configuración actual, pero todavía no la persiste.
  ///
  /// IMPORTANTE: este método no guarda la configuración de forma duradera;
  /// solo deja constancia en el log del estado actual. Los callers no deben
  /// comunicar al usuario que la configuración sobrevivirá al cierre de la app
  /// hasta que se implemente persistencia real.
  void saveControlsSettings() {
    // TODO: Persistir la configuración con SharedPreferences o una base de
    // datos (por ejemplo, SQLite/Drift) para que sobreviva al cierre de la app.
    final currentState = state;
    debugPrint(
      "Configuración registrada solo en memoria/log; persistencia pendiente. "
      "Tipo=${currentState.controlType.name}, "
      "Escala=${currentState.controlsScale}, "
      "Swap=${currentState.swapControls}",
    );
  }
}

// Exponemos el Provider para que toda la app lo pueda escuchar
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});