import 'package:equatable/equatable.dart';

class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;

  const GeoLocation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}