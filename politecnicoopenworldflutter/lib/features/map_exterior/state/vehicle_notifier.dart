import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/models/npc.dart';
import '../../../domain/models/npc_enums.dart';
import '../../../domain/models/vehicle.dart';
import '../../../multiplayer/multiplayer_notifier.dart';
import 'npc_notifier.dart';
import 'player_movement_notifier.dart';

// ── Estado ───────────────────────────────────────────────────────────

class VehicleState {
  final bool isDriving;
  final Vehicle? currentVehicle;
  final double vehicleSpeed;
  final double vehicleRotation;
  final Set<String> consumedVehicleIds;

  const VehicleState({
    this.isDriving = false,
    this.currentVehicle,
    this.vehicleSpeed = 0,
    this.vehicleRotation = 0,
    this.consumedVehicleIds = const {},
  });

  VehicleState copyWith({
    bool? isDriving,
    Vehicle? currentVehicle,
    double? vehicleSpeed,
    double? vehicleRotation,
    Set<String>? consumedVehicleIds,
    bool clearVehicle = false,
  }) {
    return VehicleState(
      isDriving: isDriving ?? this.isDriving,
      currentVehicle:
          clearVehicle ? null : (currentVehicle ?? this.currentVehicle),
      vehicleSpeed: vehicleSpeed ?? this.vehicleSpeed,
      vehicleRotation: vehicleRotation ?? this.vehicleRotation,
      consumedVehicleIds: consumedVehicleIds ?? this.consumedVehicleIds,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────

class VehicleNotifier extends StateNotifier<VehicleState> {
  final Ref _ref;

  // ── Constantes de fisica (mismas que Kotlin) ──────────────────────
  static const double _maxSpeed = 0.000017;
  static const double _acceleration = 0.0000003;
  static const double _brakingFriction = 0.000001;
  static const double _steeringDeg = 2.0;
  static const Duration _tickInterval = Duration(milliseconds: 33);

  /// Radio de interaccion en metros para subirse al coche.
  static const double interactRadiusMeters = 5.0;

  static const Distance _dist = Distance();

  // ── Entradas del jugador (las escribe DrivingControls) ────────────
  bool steeringLeft = false;
  bool steeringRight = false;
  bool gasPressed = false;
  bool brakePressed = false;

  Timer? _physicsTicker;

  VehicleNotifier(this._ref) : super(const VehicleState());

  // ── Entrar al vehiculo mas cercano ────────────────────────────────

  /// Busca el coche NPC mas cercano al jugador (en [npcNotifierProvider])
  /// y, si esta dentro de [interactRadiusMeters], sube al jugador.
  ///
  /// Retorna `true` si el jugador entro al vehiculo.
  bool tryEnterNearestVehicle() {
    if (state.isDriving) return false;

    final playerPos = _ref.read(playerMovementProvider).position;
    final npcs = _ref.read(npcNotifierProvider);

    String? closestId;
    double closestDist = double.infinity;
    Npc? closestNpc;

    for (final npc in npcs) {
      if (npc.type != NpcType.car) continue;
      if (state.consumedVehicleIds.contains(npc.id)) continue;

      final npcPos = LatLng(npc.location.latitude, npc.location.longitude);
      final d = _dist.as(LengthUnit.Meter, playerPos, npcPos);
      if (d < closestDist) {
        closestDist = d;
        closestId = npc.id;
        closestNpc = npc;
      }
    }

    if (closestId == null || closestNpc == null) {
      return false;
    }

    if (closestDist > interactRadiusMeters) {
      AppLogger.log.d(
        'Vehicle: coche mas cercano a '
        '${closestDist.toStringAsFixed(1)} m (> $interactRadiusMeters m)',
      );
      return false;
    }

    final vehicle = Vehicle(
      id: closestId,
      position: LatLng(
        closestNpc.location.latitude,
        closestNpc.location.longitude,
      ),
      rotationAngle: closestNpc.rotationAngle,
      carModel: closestNpc.carModel,
      carColor: closestNpc.carColor,
    );

    // Retirar el NPC coche del mundo (coordinator + estado).
    _ref.read(npcNotifierProvider.notifier).removeNpc(closestId);

    state = state.copyWith(
      isDriving: true,
      currentVehicle: vehicle,
      vehicleSpeed: 0,
      vehicleRotation: closestNpc.rotationAngle,
      consumedVehicleIds: {...state.consumedVehicleIds, closestId},
    );

    _startPhysics();
    _broadcastDriving(true);

    AppLogger.log.i(
      'Vehicle: subio a ${vehicle.carModel.name} '
      '($closestId, ${closestDist.toStringAsFixed(1)} m)',
    );
    return true;
  }

  // ── Salir del vehiculo ────────────────────────────────────────────

  void exitVehicle() {
    if (!state.isDriving) return;

    _stopPhysics();
    steeringLeft = false;
    steeringRight = false;
    gasPressed = false;
    brakePressed = false;

    final vehicle = state.currentVehicle;
    final rotation = state.vehicleRotation;

    state = state.copyWith(
      isDriving: false,
      vehicleSpeed: 0,
      clearVehicle: true,
    );

    // Colocar el coche estacionado donde se bajo el jugador.
    if (vehicle != null) {
      final pos = _ref.read(playerMovementProvider).position;
      _ref.read(npcNotifierProvider.notifier).spawnParkedCar(
            position: pos,
            carModel: vehicle.carModel,
            carColor: vehicle.carColor,
            rotationAngle: rotation,
          );
      AppLogger.log.i('Vehicle: bajo del ${vehicle.carModel.name}');
    }

    _broadcastDriving(false);
  }

  // ── Toggle (X entra, Y sale) ──────────────────────────────────────

  /// Para el boton X: intenta subirse al coche mas cercano.
  /// Retorna true si entro, false si no habia coche cerca.
  bool tryEnter() => tryEnterNearestVehicle();

  // ── Fisicas de conduccion ─────────────────────────────────────────

  void _startPhysics() {
    _physicsTicker?.cancel();
    _physicsTicker = Timer.periodic(_tickInterval, (_) => _physicsTick());
  }

  void _stopPhysics() {
    _physicsTicker?.cancel();
    _physicsTicker = null;
  }

  void _physicsTick() {
    if (!mounted || !state.isDriving) {
      _stopPhysics();
      return;
    }

    var speed = state.vehicleSpeed;
    var rotation = state.vehicleRotation;

    // Giro: solo si hay velocidad (como Kotlin).
    if (steeringLeft && speed != 0) rotation -= _steeringDeg;
    if (steeringRight && speed != 0) rotation += _steeringDeg;

    // Aceleracion / frenado / friccion natural.
    if (gasPressed) {
      speed = (speed + _acceleration).clamp(-_maxSpeed / 2, _maxSpeed);
    } else if (brakePressed) {
      speed -= _brakingFriction;
      if (speed < -_maxSpeed / 2) speed = -_maxSpeed / 2;
    } else {
      if (speed > 0) {
        speed = (speed - _acceleration / 2).clamp(0.0, _maxSpeed);
      }
      if (speed < 0) {
        speed = (speed + _acceleration / 2).clamp(-_maxSpeed / 2, 0.0);
      }
    }

    // Desplazamiento en grados (igual que Kotlin).
    final angleRad = rotation * math.pi / 180;
    final dx = math.sin(angleRad) * speed;
    final dy = math.cos(angleRad) * speed;

    final pos = _ref.read(playerMovementProvider).position;
    final newPos = LatLng(pos.latitude + dy, pos.longitude + dx);

    // Mover al jugador via teleport (sin pasar por la logica peatonal).
    _ref.read(playerMovementProvider.notifier).teleport(newPos);

    state = state.copyWith(
      vehicleSpeed: speed,
      vehicleRotation: (rotation + 360) % 360,
    );

    // Broadcast al servidor cada tick (el servidor throttlea).
    _broadcastDriving(true);
  }

  // ── Multiplayer ───────────────────────────────────────────────────

  void _broadcastDriving(bool driving) {
    try {
      final mp = _ref.read(multiplayerProvider);
      if (!mp.isConnected) return;
      final pos = _ref.read(playerMovementProvider).position;
      _ref.read(multiplayerProvider.notifier).broadcastMovement(
            pos,
            isDriving: driving,
            action: driving ? 'idle' : 'idle',
            facingRight: true,
          );
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopPhysics();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────────

final vehicleProvider =
    StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier(ref);
});
