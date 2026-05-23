import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../settings/state/game_settings_providers.dart';
import 'location_providers.dart';

class PlayerMovementNotifier extends StateNotifier<LatLng> {
  final Ref ref;
  static const LatLng escomLocation = LatLng(19.5045, -99.1465);

  /// Magnitud, en grados, que aplica un input de magnitud 1.0 a cada eje.
  static const double stepSize = 0.00005;

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
      // Si el GPS falla, volvemos a ESCOM para no dejar al jugador en el limbo
      state = escomLocation;
    }
  }

  Future<LatLng> resolveInitialPosition() async {
    await updatePositionByGps();
    return state;
  }

  /// Movimiento en términos geográficos. `deltaLat = 1` empuja al norte;
  /// `deltaLon = 1` empuja al este. Conservado para no romper el D-pad
  /// actual; se eliminará cuando todos los controles usen [moveBy].
  void move(double deltaLat, double deltaLon) {
    // Si estamos en modo GPS, quizás quieras bloquear el movimiento manual
    // o dejar que el jugador se desplace desde su ubicación real.
    state = LatLng(
      state.latitude + (deltaLat * stepSize),
      state.longitude + (deltaLon * stepSize),
    );
  }

  /// Movimiento en términos de pantalla, alineado a un joystick estándar:
  /// `dx > 0` empuja al este, `dy > 0` empuja al sur (mismo eje Y que la
  /// UI). Recibe valores típicamente en `[-1.0, 1.0]`. Es la API que usarán
  /// el nuevo D-pad y el joystick analógico.
  void moveBy(double dx, double dy) {
    state = LatLng(
      state.latitude - (dy * stepSize),
      state.longitude + (dx * stepSize),
    );
  }
}

final playerMovementProvider =
    StateNotifierProvider<PlayerMovementNotifier, LatLng>((ref) {
  return PlayerMovementNotifier(ref);
});
