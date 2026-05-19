import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/location/location_permission_service.dart';
import '../../services/location/location_service.dart';

/// Providers para los servicios de ubicación.
///
/// Aislados en su propio archivo para que un desarrollador pueda iterar
/// sobre la inyección de los servicios de ubicación sin tocar
/// `providers.dart` (que mezcla DB, repos y estado del mapa) ni
/// `session_providers.dart`.
final locationPermissionServiceProvider =
    Provider<LocationPermissionService>((ref) => LocationPermissionService());

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());
