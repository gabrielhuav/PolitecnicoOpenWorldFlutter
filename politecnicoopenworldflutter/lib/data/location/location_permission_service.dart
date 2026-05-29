import 'package:geolocator/geolocator.dart';

import 'location_permission_status.dart';

/// Encapsula toda la lógica de permisos de ubicación.
///
/// La UI nunca llama a [Geolocator] directamente; siempre pasa por este
/// servicio. Esto permite testear con un mock y mantener el flujo de
/// permisos en un único lugar.
class LocationPermissionService {
  /// Comprueba el estado actual sin solicitar permiso al usuario.
  Future<LocationPermissionStatus> check() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  /// Solicita permiso al usuario si está en estado [LocationPermission.denied]
  /// o sin determinar. Devuelve el resultado normalizado.
  Future<LocationPermissionStatus> request() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _mapPermission(permission);
  }

  /// Abre los ajustes del sistema operativo donde el usuario puede
  /// re-habilitar el permiso después de un [deniedForever].
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Abre los ajustes de ubicación del sistema operativo (útil cuando el
  /// servicio está apagado).
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  LocationPermissionStatus _mapPermission(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      default:
        return LocationPermissionStatus.denied;
    }
  }
}
