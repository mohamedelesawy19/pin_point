import 'package:equatable/equatable.dart';

class PlayerAnswerEntity extends Equatable {
  const PlayerAnswerEntity({
    required this.playerId,
    required this.playerName,
    this.photoUrl,
    required this.roundIndex,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.score,
    required this.submittedAt,
  });

  final String playerId;
  final String playerName;
  final String? photoUrl;
  final int roundIndex;
  final double latitude;
  final double longitude;

  /// Distance in km from the actual landmark location.
  final double distanceKm;

  /// Points earned for this round based on distance.
  final int score;

  final DateTime submittedAt;

  /// Human-readable distance label, e.g. "42 km" or "1,234 km".
  String get distanceLabel {
    if (distanceKm < 10) return '${distanceKm.toStringAsFixed(1)} km';
    if (distanceKm < 1000) return '${distanceKm.round()} km';
    return '${(distanceKm / 1000).toStringAsFixed(1)}k km';
  }

  @override
  List<Object?> get props => [
    playerId,
    roundIndex,
    latitude,
    longitude,
    distanceKm,
    score,
    submittedAt,
  ];
}
