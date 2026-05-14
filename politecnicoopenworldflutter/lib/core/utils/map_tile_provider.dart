import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Proveedores de tiles disponibles ────────────────────────────────
enum MapTileProvider {
  cartoLight(
    label: 'Carto Claro',
    url:
        'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
  ),
  cartoDark(
    label: 'Carto Oscuro',
    url:
        'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
  ),
  stadiaLight(
    label: 'Stadia Claro',
    url: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
  ),
  stadiaDark(
    label: 'Stadia Oscuro',
    url:
        'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png',
  ),
  osm(
    label: 'OpenStreetMap',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  final String label;
  final String url;
  const MapTileProvider({required this.label, required this.url});
}

// ── Provider global — cambia el valor aquí para probar ──────────────
final mapTileProviderProvider = StateProvider<MapTileProvider>(
  (ref) => MapTileProvider.osm, // ← valor inicial
);
