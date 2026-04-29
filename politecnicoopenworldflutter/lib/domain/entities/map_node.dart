import 'package:equatable/equatable.dart';

class MapNode extends Equatable {
  final int id;
  final double lat;
  final double lon;

  const MapNode({
    required this.id,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [id, lat, lon];
}