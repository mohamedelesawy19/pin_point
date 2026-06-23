// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/game/domain/entities/landmark_entity.dart';

class LandmarkModel extends Equatable {
  const LandmarkModel({
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

  // ── Firestore conversions ──────────────────────────────────────────────────

  factory LandmarkModel.fromFirestore(Map<String, dynamic> data) {
    return LandmarkModel(
      id: data['id'] as String,
      name: data['name'] as String,
      imageUrl: data['imageUrl'] as String,
      actualLatitude: (data['actualLatitude'] as num).toDouble(),
      actualLongitude: (data['actualLongitude'] as num).toDouble(),
      country: data['country'] as String?,
      city: data['city'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'actualLatitude': actualLatitude,
      'actualLongitude': actualLongitude,
      'country': country,
      'city': city,
    };
  }

  // ── JSON conversions ───────────────────────────────────────────────────────

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    return LandmarkModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      actualLatitude: (json['actualLatitude'] as num).toDouble(),
      actualLongitude: (json['actualLongitude'] as num).toDouble(),
      country: json['country'] as String?,
      city: json['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {...toFirestore()};
  }

  // ── Entity conversions ─────────────────────────────────────────────────────

  factory LandmarkModel.fromEntity(LandmarkEntity entity) {
    return LandmarkModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      actualLatitude: entity.actualLatitude,
      actualLongitude: entity.actualLongitude,
      country: entity.country,
      city: entity.city,
    );
  }

  LandmarkEntity toEntity() {
    return LandmarkEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      actualLatitude: actualLatitude,
      actualLongitude: actualLongitude,
      country: country,
      city: city,
    );
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
