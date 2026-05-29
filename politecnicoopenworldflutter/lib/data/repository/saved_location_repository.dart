import 'package:uuid/uuid.dart';

import '../../domain/models/saved_location.dart';
import '../local/dao/saved_location_dao.dart';

/// Capa de orquestación sobre [SavedLocationDao]. Permite a la UI gestionar
/// ubicaciones (spawn, waypoints, POIs) ligadas a una partida sin acoplarse
/// a Drift.
class SavedLocationRepository {
  final SavedLocationDao _dao;
  final Uuid _uuid;

  SavedLocationRepository(this._dao, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  Future<SavedLocation> add({
    required String sessionId,
    required String label,
    required double lat,
    required double lon,
    SavedLocationKind kind = SavedLocationKind.waypoint,
  }) async {
    final location = SavedLocation(
      id: _uuid.v4(),
      sessionId: sessionId,
      label: label,
      lat: lat,
      lon: lon,
      kind: kind,
      createdAt: DateTime.now(),
    );
    await _dao.insert(location);
    return location;
  }

  Future<List<SavedLocation>> listForSession(String sessionId) {
    return _dao.listForSession(sessionId);
  }

  Future<void> remove(String id) => _dao.deleteById(id);

  Future<void> clearForSession(String sessionId) {
    return _dao.deleteAllForSession(sessionId);
  }
}
