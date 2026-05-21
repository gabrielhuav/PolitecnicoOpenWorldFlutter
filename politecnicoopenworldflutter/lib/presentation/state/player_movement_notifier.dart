import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/location_service.dart'; 
import '../../core/utils/game_settings_providers.dart';
import '../../core/utils/providers.dart';

class PlayerMovementNotifier extends StateNotifier<LatLng> {
  final Ref ref;
  static const LatLng escomLocation = LatLng(19.5045, -99.1465);

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

  void move(double deltaLat, double deltaLon) {
    // Si estamos en modo GPS, quizás quieras bloquear el movimiento manual
    // o dejar que el jugador se desplace desde su ubicación real.
    state = LatLng(
      state.latitude + (deltaLat * 0.00005),    // Ajusta la sensibilidad del movimiento
      state.longitude + (deltaLon * 0.00005),   // Ajusta la sensibilidad del movimiento
    );
  }
}

final playerMovementProvider = StateNotifierProvider<PlayerMovementNotifier, LatLng>((ref) {
  return PlayerMovementNotifier(ref);
});