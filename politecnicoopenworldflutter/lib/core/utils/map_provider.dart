import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

final playerLocationProvider = StateProvider<LatLng>((ref) {
  return const LatLng(19.5045, -99.1465); // ESCOM
});

final locationPermissionProvider = FutureProvider<bool>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return false;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return false;
  }
  return permission != LocationPermission.deniedForever;
});