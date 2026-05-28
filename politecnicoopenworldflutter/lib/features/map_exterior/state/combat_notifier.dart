import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import '../../../multiplayer/multiplayer_notifier.dart';
import 'player_movement_notifier.dart';

/// Distancia máxima (en metros) a la que se puede golpear a otro
/// jugador. Generosa para que el combate sea sentible aunque la
/// latencia desfase un poco las posiciones reportadas.
const double kPunchRangeMeters = 20;

/// Daño base de un golpe. Se puede sintonizar después o exponer en
/// settings sin tocar el resto del sistema.
const double kPunchDamage = 15;

/// Cooldown entre golpes para que no se pueda spammear el botón.
const Duration kPunchCooldown = Duration(milliseconds: 800);

class CombatNotifier extends Notifier<DateTime> {
  static const Distance _dist = Distance();

  @override
  DateTime build() => DateTime.fromMillisecondsSinceEpoch(0);

  /// Llamado al pulsar el botón X (o el que decidas). Busca al jugador
  /// remoto más cercano dentro de [kPunchRangeMeters] y le envía
  /// PLAYER_DAMAGE. Devuelve true si conectó el golpe.
  bool tryPunch() {
    final mp = ref.read(multiplayerProvider);
    if (!mp.isConnected) return false;

    final now = DateTime.now();
    if (now.difference(state) < kPunchCooldown) return false;

    final myPos = ref.read(playerMovementProvider).position;
    String? targetId;
    double bestDist = double.infinity;

    for (final remote in mp.players.values) {
      final d = _dist(myPos, remote.position);
      if (d < bestDist && d <= kPunchRangeMeters) {
        bestDist = d;
        targetId = remote.id;
      }
    }

    if (targetId == null) {
      AppLogger.log.d('Combat: no hay objetivo en rango');
      return false;
    }

    state = now;
    ref.read(multiplayerProvider.notifier).sendPlayerDamage(
          targetId,
          kPunchDamage,
        );
    AppLogger.log.i(
      'Combat: golpe a $targetId ($kPunchDamage daño, '
      '${bestDist.toStringAsFixed(1)} m)',
    );
    return true;
  }
}

final combatProvider =
    NotifierProvider<CombatNotifier, DateTime>(CombatNotifier.new);
