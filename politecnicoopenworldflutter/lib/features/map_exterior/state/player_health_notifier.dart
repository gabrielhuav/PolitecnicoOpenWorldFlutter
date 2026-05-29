import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';

/// Estado de salud del jugador local.
///
/// Mantiene la barra visible solo unos segundos tras recibir daño,
/// como en GTA / RDR. [damagePulse] cambia en cada golpe para que la
/// UI pueda animar un shake/flash sin acoplarse al valor de [health].
class PlayerHealthState {
  final double health;
  final double maxHealth;
  final bool showBar;
  final int damagePulse;
  final bool isDead;

  const PlayerHealthState({
    required this.health,
    required this.maxHealth,
    required this.showBar,
    required this.damagePulse,
    required this.isDead,
  });

  factory PlayerHealthState.initial() => const PlayerHealthState(
        health: 100,
        maxHealth: 100,
        showBar: false,
        damagePulse: 0,
        isDead: false,
      );

  PlayerHealthState copyWith({
    double? health,
    bool? showBar,
    int? damagePulse,
    bool? isDead,
  }) =>
      PlayerHealthState(
        health: health ?? this.health,
        maxHealth: maxHealth,
        showBar: showBar ?? this.showBar,
        damagePulse: damagePulse ?? this.damagePulse,
        isDead: isDead ?? this.isDead,
      );
}

class PlayerHealthNotifier extends StateNotifier<PlayerHealthState> {
  PlayerHealthNotifier() : super(PlayerHealthState.initial());

  Timer? _hideBarTimer;

  void takeDamage(double amount) {
    if (state.isDead || amount <= 0) return;
    final newHealth = (state.health - amount).clamp(0.0, state.maxHealth);
    final isDead = newHealth <= 0;
    state = state.copyWith(
      health: newHealth,
      showBar: true,
      damagePulse: state.damagePulse + 1,
      isDead: isDead,
    );
    AppLogger.log.i('Health: -$amount → ${newHealth.toInt()}/${state.maxHealth.toInt()}');
    _scheduleHideBar();
  }

  void heal(double amount) {
    if (state.isDead || amount <= 0) return;
    final newHealth = (state.health + amount).clamp(0.0, state.maxHealth);
    state = state.copyWith(health: newHealth, showBar: true);
    _scheduleHideBar();
  }

  /// Revive al jugador con vida completa. Útil para "reaparecer" tras
  /// la pantalla de WASTED (que aún no migras, pero queda listo).
  void respawn() {
    _hideBarTimer?.cancel();
    state = PlayerHealthState.initial();
  }

  void _scheduleHideBar() {
    _hideBarTimer?.cancel();
    _hideBarTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      // Si la salud bajó de 30 dejamos la barra visible permanentemente
      // como warning. En el resto de casos se oculta.
      if (state.health > 30) {
        state = state.copyWith(showBar: false);
      }
    });
  }

  @override
  void dispose() {
    _hideBarTimer?.cancel();
    super.dispose();
  }
}

final playerHealthProvider =
    StateNotifierProvider<PlayerHealthNotifier, PlayerHealthState>(
  (ref) => PlayerHealthNotifier(),
);
