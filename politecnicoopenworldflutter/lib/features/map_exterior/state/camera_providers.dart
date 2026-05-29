import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Providers relacionados con el estado de la cámara del mapa.
///
/// Aislados en su propio archivo para que el spawner de NPCs y la pantalla
/// del mapa puedan compartir el viewport actual sin que la capa de dominio
/// dependa de flutter_map ni del MapController.
///
/// WorldMapScreen publica aquí el radio visible cada vez que cambia la
/// cámara; NpcNotifier lo lee al hacer tick y se lo pasa al spawner.

/// Radio visible (en metros) desde el centro de la cámara hasta la esquina
/// del viewport. Calculado en WorldMapScreen a partir del zoom, la latitud
/// del centro y el tamaño del widget del mapa.
///
/// El default de 200 es deliberadamente conservador: solo se usa el primer
/// frame, antes de que la pantalla publique el valor real. Si por alguna
/// razón la pantalla no llega a publicarlo, un anillo de spawn cercano es
/// preferible a uno lejano que dejaría al jugador rodeado de zonas vacías.
final viewportRadiusProvider = StateProvider<double>((ref) => 200);

/// Indica si la cámara sigue al jugador o está en modo paneo libre.
///
/// Hoy es siempre true porque WorldMapScreen recentra en cada cambio de
/// playerMovementProvider. Queda preparado para alternar el minZoom del
/// mapa el día que se implemente el modo paneo libre real, sin tocar este
/// archivo ni el spawner.
final isFollowingPlayerProvider = StateProvider<bool>((ref) => true);