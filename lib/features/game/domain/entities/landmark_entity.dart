import 'package:equatable/equatable.dart';

class LandmarkEntity extends Equatable {
  const LandmarkEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.actualLatitude,
    required this.actualLongitude,
    this.country,
    this.city,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double actualLatitude;
  final double actualLongitude;
  final String? country;
  final String? city;

  String get locationLabel {
    if (city != null && country != null) return '$city, $country';
    if (country != null) return country!;
    return '';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    actualLatitude,
    actualLongitude,
    country,
    city,
  ];
}
