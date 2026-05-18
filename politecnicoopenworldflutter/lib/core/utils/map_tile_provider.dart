import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Categorías para agrupar el selector ─────────────────────────────
enum MapTileCategory {
  standard('Estándar'),
  themed('Estilizado'),
  satellite('Satélite'),
  terrain('Topográfico');

  final String label;
  const MapTileCategory(this.label);
}

// ── Proveedores de tiles disponibles ────────────────────────────────
enum MapTileProvider {
  // Carto (CDN rápido, sin API key)
  cartoLight(
    label: 'Carto Claro',
    url:
        'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
    attribution: '© OpenStreetMap · © CARTO',
    category: MapTileCategory.themed,
  ),
  cartoDark(
    label: 'Carto Oscuro',
    url:
        'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
    attribution: '© OpenStreetMap · © CARTO',
    category: MapTileCategory.themed,
  ),
  cartoVoyager(
    label: 'Carto Voyager',
    url:
        'https://cartodb-basemaps-{s}.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
    attribution: '© OpenStreetMap · © CARTO',
    category: MapTileCategory.themed,
  ),

  // OpenStreetMap directo (cuidado con rate limiting)
  osm(
    label: 'OpenStreetMap',
    url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
    attribution: '© OpenStreetMap contributors',
    category: MapTileCategory.standard,
  ),
  humanitarian(
    label: 'Humanitarian OSM',
    url: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    subdomains: ['a', 'b'],
    attribution: '© OpenStreetMap · Humanitarian OSM Team',
    category: MapTileCategory.standard,
  ),
  cyclOsm(
    label: 'CyclOSM',
    url: 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
    attribution: '© OpenStreetMap · CyclOSM',
    category: MapTileCategory.themed,
  ),

  // Topográfico
  openTopo(
    label: 'OpenTopoMap',
    url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
    attribution: '© OpenStreetMap · SRTM · OpenTopoMap (CC-BY-SA)',
    maxZoom: 17,
    category: MapTileCategory.terrain,
  ),

  // Esri (orden de placeholders {z}/{y}/{x} — flutter_map lo respeta)
  esriSatellite(
    label: 'Esri Satélite',
    url:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles © Esri · Maxar · Earthstar Geographics',
    category: MapTileCategory.satellite,
  ),
  esriStreet(
    label: 'Esri Calles',
    url:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles © Esri',
    category: MapTileCategory.standard,
  ),
  esriTopo(
    label: 'Esri Topográfico',
    url:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles © Esri',
    category: MapTileCategory.terrain,
  ),

  // Stadia (requiere API key en producción, ok para dev)
  stadiaLight(
    label: 'Stadia Claro',
    url: 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png',
    attribution: '© Stadia Maps · © OpenStreetMap',
    category: MapTileCategory.themed,
  ),
  stadiaDark(
    label: 'Stadia Oscuro',
    url:
        'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png',
    attribution: '© Stadia Maps · © OpenStreetMap',
    category: MapTileCategory.themed,
  );

  final String label;
  final String url;
  final List<String> subdomains;
  final String attribution;
  final int maxZoom;
  final MapTileCategory category;

  const MapTileProvider({
    required this.label,
    required this.url,
    required this.attribution,
    required this.category,
    this.subdomains = const [],
    this.maxZoom = 19,
  });
}

const defaultMapTileProvider = MapTileProvider.cartoLight;

// ── Provider global ─────────────────────────────────────────────────
final mapTileProviderProvider = StateProvider<MapTileProvider>(
  (ref) => defaultMapTileProvider,
);
