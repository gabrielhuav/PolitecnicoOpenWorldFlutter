import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Proveedores de tiles disponibles ────────────────────────────────
enum MapTileProvider {
  cartoLight(
    label: 'Carto Claro',
    url:
        'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
  ),
  cartoDark(
    label: 'Carto Oscuro',
    url:
        'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
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
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
  );

  final String label;
  final String url;
  final List<String> subdomains;
  const MapTileProvider({
    required this.label,
    required this.url,
    this.subdomains = const [],
  });
}

// ── Provider global — cambia el valor aquí para probar ──────────────
final mapTileProviderProvider = StateProvider<MapTileProvider>(
  (ref) => MapTileProvider.cartoLight,
);
