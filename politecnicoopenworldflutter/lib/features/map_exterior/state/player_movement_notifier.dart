import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../settings/state/game_settings_providers.dart';
import 'location_providers.dart';

class PlayerMovementNotifier extends StateNotifier<LatLng> {
  final Ref ref;
  static const LatLng escomLocation = LatLng(19.5045, -99.1465);

  /// Velocidad de caminata del jugador, en metros por segundo.
  /// Así que el jugador a 5.0 los adelanta apenas.
  static const double walkSpeedMetersPerSecond = 5.0;

  /// Intervalo de tick de los controles. Coincide con
  /// DPadControl._tickInterval y JoystickControl._tickInterval
  /// (33 ms = ~30 Hz). Mantenlo sincronizado con esos archivos.
  static const double _tickSeconds = 0.033;

  /// Aproximación: metros por grado de latitud. Constante en la
  /// Tierra (~111 km), independiente de la latitud.
  static const double _metersPerLatDegree = 111000.0;

  PlayerMovementNotifier(this.ref) : super(escomLocation);

  void teleport(LatLng newPos) {
    state = newPos;
  }

  Future<void> updatePositionByGps() async {
    final useGps = ref.read(useRealLocationProvider);

    if (!useGps) {
      state = escomLocation;
      return;
    }

    final service = ref.read(locationServiceProvider);
    final position = await service.getCurrent();

    if (position != null) {
      state = LatLng(position.latitude, position.longitude);
    } else {
      state = escomLocation;
    }
  }

  Future<LatLng> resolveInitialPosition() async {
    await updatePositionByGps();
    return state;
  }

  /// Movimiento en términos geográficos. Conservado por
  /// compatibilidad; calcula el paso desde la misma velocidad real.
  void move(double deltaLat, double deltaLon) {
    final stepDeg = _legacyStepDegrees();
    state = LatLng(
      state.latitude + (deltaLat * stepDeg),
      state.longitude + (deltaLon * stepDeg),
    );
  }

  /// Movimiento alineado a joystick. [dx], [dy] esperan magnitudes
  /// en [-1, 1]. Convierte velocidad humana en m/s a desplazamiento
  /// en grados según la latitud actual.
  void moveBy(double dx, double dy) {
    final distanceMeters = walkSpeedMetersPerSecond * _tickSeconds;
    final dLatDeg = (distanceMeters / _metersPerLatDegree) * (-dy);
    final lonMetersPerDeg =
        _metersPerLatDegree * math.cos(state.latitude * math.pi / 180);
    final dLonDeg = (distanceMeters / lonMetersPerDeg) * dx;
    state = LatLng(
      state.latitude + dLatDeg,
      state.longitude + dLonDeg,
    );
  }

  double _legacyStepDegrees() =>
      walkSpeedMetersPerSecond * _tickSeconds / _metersPerLatDegree;
}

final playerMovementProvider =
    StateNotifierProvider<PlayerMovementNotifier, LatLng>((ref) {
  return PlayerMovementNotifier(ref);
});