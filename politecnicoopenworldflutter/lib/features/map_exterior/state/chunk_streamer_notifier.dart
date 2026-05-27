import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import 'map_providers.dart';
import 'player_movement_notifier.dart';

/// Estado expuesto del streamer.
///   - active:         enganchado al movimiento del jugador.
///   - loading:        hay una expansión en curso ahora mismo.
///   - lastLoadCenter: última posición desde la que se cargó.
class ChunkStreamerState {
  final bool active;
  final bool loading;
  final LatLng? lastLoadCenter;

  const ChunkStreamerState({
    required this.active,
    required this.loading,
    required this.lastLoadCenter,
  });

  ChunkStreamerState copyWith({
    bool? active,
    bool? loading,
    LatLng? lastLoadCenter,
  }) {
    return ChunkStreamerState(
      active: active ?? this.active,
      loading: loading ?? this.loading,
      lastLoadCenter: lastLoadCenter ?? this.lastLoadCenter,
    );
  }

  static const idle = ChunkStreamerState(
    active: false,
    loading: false,
    lastLoadCenter: null,
  );
}

class ChunkStreamerNotifier extends StateNotifier<ChunkStreamerState> {
  final Ref _ref;

  /// Cuánto debe haberse movido el jugador desde la última carga
  /// para disparar una nueva. 500 m ≈ 1 cellKey de margen sobre
  /// las celdas de 0.005°, así siempre hay buffer alrededor.
  static const double _triggerDistanceMeters = 500;

  /// Radio total a mantener cubierto alrededor del jugador.
  /// Coincide con el bootstrap del PR1.
  static const double _coverageRadiusMeters = 5000;

  static const Distance _dist = Distance();

  ProviderSubscription<PlayerState>? _sub;

  ChunkStreamerNotifier(this._ref) : super(ChunkStreamerState.idle);

  /// Engancha el streamer al movimiento del jugador. Llámalo cuando
  /// el WorldMapScreen aparece. [initialCenter] suele ser la
  /// posición del jugador justo después del bootstrap.
  void start(LatLng initialCenter) {
    if (state.active) return;
    state = state.copyWith(active: true, lastLoadCenter: initialCenter);
    _sub = _ref.listen<PlayerState>(playerMovementProvider, (prev, next) {
      _maybeExpand(next.position);
    });
    AppLogger.log.i(
      'ChunkStreamer iniciado en '
      '(${initialCenter.latitude}, ${initialCenter.longitude})',
    );
  }

  /// Desengancha el streamer. Llámalo cuando WorldMapScreen se
  /// destruye (salir al menú principal). Es seguro llamarlo sin
  /// haber hecho start.
  void stop() {
    _sub?.close();
    _sub = null;
    if (mounted) state = ChunkStreamerState.idle;
    AppLogger.log.i('ChunkStreamer detenido');
  }

  Future<void> _maybeExpand(LatLng next) async {
    if (!state.active || state.loading) return;
    final last = state.lastLoadCenter;
    if (last == null) return;
    final moved = _dist(last, next);
    if (moved < _triggerDistanceMeters) return;

    AppLogger.log.i(
      'ChunkStreamer dispara expansión: '
      '${moved.toStringAsFixed(0)} m desde el último centro',
    );
    state = state.copyWith(loading: true, lastLoadCenter: next);
    try {
      await _ref.read(mapStateProvider).expandCoverage(
            centerLat: next.latitude,
            centerLon: next.longitude,
            radiusMeters: _coverageRadiusMeters,
          );
    } finally {
      if (mounted) state = state.copyWith(loading: false);
    }
  }

  @override
  void dispose() {
    _sub?.close();
    super.dispose();
  }
}

final chunkStreamerProvider =
    StateNotifierProvider<ChunkStreamerNotifier, ChunkStreamerState>(
  (ref) => ChunkStreamerNotifier(ref),
);
