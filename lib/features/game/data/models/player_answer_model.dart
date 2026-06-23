// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/game/domain/entities/player_answer_entity.dart';

class PlayerAnswerModel extends Equatable {
  const PlayerAnswerModel({
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
  final double distanceKm;
  final int score;
  final DateTime submittedAt;

  // ── Firestore conversions ──────────────────────────────────────────────────

  factory PlayerAnswerModel.fromFirestore(Map<String, dynamic> data) {
    return PlayerAnswerModel(
      playerId: data['playerId'] as String,
      playerName: data['playerName'] as String,
      photoUrl: data['photoUrl'] as String?,
      roundIndex: data['roundIndex'] as int,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      distanceKm: (data['distanceKm'] as num).toDouble(),
      score: data['score'] as int,
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'photoUrl': photoUrl,
      'roundIndex': roundIndex,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
      'score': score,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  // ── JSON conversions ───────────────────────────────────────────────────────

  factory PlayerAnswerModel.fromJson(Map<String, dynamic> json) {
    return PlayerAnswerModel(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      photoUrl: json['photoUrl'] as String?,
      roundIndex: json['roundIndex'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      score: json['score'] as int,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {...toFirestore(), 'submittedAt': submittedAt.toIso8601String()};
  }

  // ── Entity conversions ─────────────────────────────────────────────────────

  factory PlayerAnswerModel.fromEntity(PlayerAnswerEntity entity) {
    return PlayerAnswerModel(
      playerId: entity.playerId,
      playerName: entity.playerName,
      photoUrl: entity.photoUrl,
      roundIndex: entity.roundIndex,
      latitude: entity.latitude,
      longitude: entity.longitude,
      distanceKm: entity.distanceKm,
      score: entity.score,
      submittedAt: entity.submittedAt,
    );
  }

  PlayerAnswerEntity toEntity() {
    return PlayerAnswerEntity(
      playerId: playerId,
      playerName: playerName,
      photoUrl: photoUrl,
      roundIndex: roundIndex,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      score: score,
      submittedAt: submittedAt,
    );
  }

  @override
  List<Object?> get props => [
    playerId,
    playerName,
    photoUrl,
    roundIndex,
    latitude,
    longitude,
    distanceKm,
    score,
    submittedAt,
  ];
}
