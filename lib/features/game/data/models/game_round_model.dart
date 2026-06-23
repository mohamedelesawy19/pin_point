// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/game/data/models/landmark_model.dart';
import '/features/game/domain/entities/game_round_entity.dart';

class GameRoundModel extends Equatable {
  const GameRoundModel({
    required this.roundIndex,
    required this.landmark,
    required this.startedAt,
    required this.endsAt,
    required this.status,
  });

  final int roundIndex;
  final LandmarkModel landmark;
  final DateTime startedAt;
  final DateTime endsAt;
  final RoundStatus status;

  // ── Firestore conversions ──────────────────────────────────────────────────

  factory GameRoundModel.fromFirestore(Map<String, dynamic> data) {
    return GameRoundModel(
      roundIndex: data['roundIndex'] as int,
      landmark: LandmarkModel.fromFirestore(
        data['landmark'] as Map<String, dynamic>,
      ),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      endsAt: (data['endsAt'] as Timestamp).toDate(),
      status: RoundStatus.values.byName(data['status'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roundIndex': roundIndex,
      'landmark': landmark.toFirestore(),
      'startedAt': Timestamp.fromDate(startedAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': status.name,
    };
  }

  // ── JSON conversions ───────────────────────────────────────────────────────

  factory GameRoundModel.fromJson(Map<String, dynamic> json) {
    return GameRoundModel(
      roundIndex: json['roundIndex'] as int,
      landmark: LandmarkModel.fromJson(
        json['landmark'] as Map<String, dynamic>,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      status: RoundStatus.values.byName(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...toFirestore(),
      'landmark': landmark.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'endsAt': endsAt.toIso8601String(),
    };
  }

  // ── Entity conversions ─────────────────────────────────────────────────────

  factory GameRoundModel.fromEntity(GameRoundEntity entity) {
    return GameRoundModel(
      roundIndex: entity.roundIndex,
      landmark: LandmarkModel.fromEntity(entity.landmark),
      startedAt: entity.startedAt,
      endsAt: entity.endsAt,
      status: entity.status,
    );
  }

  GameRoundEntity toEntity() {
    return GameRoundEntity(
      roundIndex: roundIndex,
      landmark: landmark.toEntity(),
      startedAt: startedAt,
      endsAt: endsAt,
      status: status,
    );
  }

  @override
  List<Object?> get props => [roundIndex, landmark, startedAt, endsAt, status];
}
