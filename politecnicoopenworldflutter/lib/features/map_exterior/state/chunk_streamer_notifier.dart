import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import 'map_providers.dart';
import 'player_movement_notifier.dart';

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

  static const double _triggerDistanceMeters = 500;
  static const double _coverageRadiusMeters = 5000;
  static const Distance _dist = Distance();

  ProviderSubscription<PlayerState>? _sub;

  ChunkStreamerNotifier(this._ref) : super(ChunkStreamerState.idle);

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

  /// Detiene el streamer. No muta [state] porque puede ser llamado desde
  /// [dispose] del widget, que ocurre durante el desmontaje del árbol de
  /// Flutter. Mutar un provider en ese momento viola las restricciones de
  /// Riverpod y lanza una excepción en debug. La suscripción se cierra aquí;
  /// el estado quedará obsoleto y el notifier será destruido por Riverpod
  /// cuando el provider se libere.
  void stop() {
    _sub?.close();
    _sub = null;
    AppLogger.log.i('ChunkStreamer detenido');
    // No asignamos state aquí a propósito.
    // Si el widget ya fue desmontado, Riverpod limpiará el provider.
    // Si stop() se llama desde un lugar distinto a dispose (ej. botón),
    // el estado quedará con active=true pero sin suscripción, lo cual
    // es inofensivo porque _maybeExpand ya no recibirá eventos.
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
    // dispose() de StateNotifier NO debe asignar state: el notifier
    // ya está siendo destruido por Riverpod en este punto.
  }
}

final chunkStreamerProvider =
    StateNotifierProvider<ChunkStreamerNotifier, ChunkStreamerState>(
  (ref) => ChunkStreamerNotifier(ref),
);