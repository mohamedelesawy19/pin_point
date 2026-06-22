// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import 'landmark_entity.dart';

enum RoundStatus { active, results }

class GameRoundEntity extends Equatable {
  const GameRoundEntity({
    required this.roundIndex,
    required this.landmark,
    required this.startedAt,
    required this.endsAt,
    required this.status,
  });

  final int roundIndex;
  final LandmarkEntity landmark;
  final DateTime startedAt;
  final DateTime endsAt;
  final RoundStatus status;

  int get totalDurationSeconds =>
      endsAt.difference(startedAt).inSeconds.clamp(1, 3600);

  int get remainingSeconds => endsAt
      .difference(DateTime.now())
      .inSeconds
      .clamp(0, totalDurationSeconds);

  bool get isExpired => DateTime.now().isAfter(endsAt);

  @override
  List<Object?> get props => [roundIndex, landmark, startedAt, endsAt, status];
}
