import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../settings/state/game_settings_providers.dart';
import 'location_providers.dart';

enum PlayerDirection { up, down, left, right }

class PlayerState {
  final LatLng position;
  final bool isMoving;
  final PlayerDirection facing;

  const PlayerState({
    required this.position,
    this.isMoving = false,
    this.facing = PlayerDirection.down, // Por defecto mira hacia abajo
  });

  PlayerState copyWith({
    LatLng? position,
    bool? isMoving,
    PlayerDirection? facing,
  }) {
    return PlayerState(
      position: position ?? this.position,
      isMoving: isMoving ?? this.isMoving,
      facing: facing ?? this.facing,
    );
  }
}

class PlayerMovementNotifier extends StateNotifier<PlayerState> {
  final Ref ref;
  static const LatLng escomLocation = LatLng(19.5045, -99.1465);
  static const double walkSpeedMetersPerSecond = 5.0;
  static const double _tickSeconds = 0.033;
  static const double _metersPerLatDegree = 111000.0;

  PlayerMovementNotifier(this.ref)
      : super(const PlayerState(position: escomLocation));

  void teleport(LatLng newPos) {
    state = state.copyWith(position: newPos);
  }

  Future<void> updatePositionByGps() async {
    final useGps = ref.read(useRealLocationProvider);
    if (!useGps) {
      state = state.copyWith(position: escomLocation);
      return;
    }
    final service = ref.read(locationServiceProvider);
    final position = await service.getCurrent();
    if (position != null) {
      state = state.copyWith(
          position: LatLng(position.latitude, position.longitude));
    } else {
      state = state.copyWith(position: escomLocation);
    }
  }

  Future<LatLng> resolveInitialPosition() async {
    await updatePositionByGps();
    return state.position;
  }

  void moveBy(double dx, double dy) {
    final distanceMeters = walkSpeedMetersPerSecond * _tickSeconds;
    final dLatDeg = (distanceMeters / _metersPerLatDegree) * (-dy);
    final lonMetersPerDeg =
        _metersPerLatDegree * math.cos(state.position.latitude * math.pi / 180);
    final dLonDeg = (distanceMeters / lonMetersPerDeg) * dx;

    // Determinar hacia dónde mira basado en el delta dominante
    PlayerDirection newFacing = state.facing;
    if (dx.abs() > dy.abs()) {
      newFacing = dx > 0 ? PlayerDirection.right : PlayerDirection.left;
    } else if (dy.abs() > dx.abs() || dy != 0) {
      newFacing = dy > 0 ? PlayerDirection.down : PlayerDirection.up;
    }

    state = state.copyWith(
      position: LatLng(
        state.position.latitude + dLatDeg,
        state.position.longitude + dLonDeg,
      ),
      isMoving: true,
      facing: newFacing,
    );
  }

  // Nuevo método para detener la animación
  void stopMovement() {
    if (state.isMoving) {
      state = state.copyWith(isMoving: false);
    }
  }
}

final playerMovementProvider =
    StateNotifierProvider<PlayerMovementNotifier, PlayerState>((ref) {
  return PlayerMovementNotifier(ref);
});
