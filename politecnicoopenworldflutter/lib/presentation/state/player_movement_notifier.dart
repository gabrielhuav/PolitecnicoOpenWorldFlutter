import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class PlayerMovementNotifier extends StateNotifier<LatLng> {
  PlayerMovementNotifier() : super(const LatLng(19.5045, -99.1465));

  // Velocidad de movimiento (ajusta según necesites)
  final double stepSize = 0.00005; 

  void move(double deltaLat, double deltaLon) {
    state = LatLng(
      state.latitude + (deltaLat * stepSize),
      state.longitude + (deltaLon * stepSize),
    );
  }

  void teleport(LatLng newPos) {
    state = newPos;
  }
}

final playerMovementProvider = StateNotifierProvider<PlayerMovementNotifier, LatLng>((ref) {
  return PlayerMovementNotifier();
});