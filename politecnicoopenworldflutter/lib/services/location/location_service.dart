import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Servicio de obtención de la posición del dispositivo.
///
/// Se asume que el permiso ya fue concedido (lo gestiona
/// [LocationPermissionService]). Si no lo está, [getCurrent] devolverá `null`
/// en lugar de lanzar para no acoplar el manejo de errores con la UI.
class LocationService {
  final LocationAccuracy accuracy;
  final Duration timeout;

  LocationService({
    this.accuracy = LocationAccuracy.high,
    this.timeout = const Duration(seconds: 10),
  });

  /// Devuelve la posición actual del dispositivo o `null` si no se pudo
  /// obtener (timeout, permiso revocado en caliente, etc.).
  Future<LatLng?> getCurrent() async {
    try {
      final position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Versión rápida usando la última posición conocida en caché del
  /// sistema operativo. Puede devolver `null` si nunca se ha leído antes.
  Future<LatLng?> getLastKnown() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }
}
