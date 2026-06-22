// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/entities/player_answer_entity.dart';
import '/features/game/domain/repositories/game_repository.dart';
import '/features/game/domain/usecases/calculate_distance_usecase.dart';
import '/features/game/domain/usecases/calculate_score_usecase.dart';

/// Ends a round by:
/// 1. Fetching all raw player answers from Firestore.
/// 2. Calculating each answer's distance from the actual landmark.
/// 3. Converting distances to scores.
/// 4. Updating cumulative player scores.
/// 5. Persisting results back to Firestore for all players to see.
class EndRoundUseCase implements UseCase<Unit, EndRoundParams> {
  const EndRoundUseCase({
    required this._repository,
    required this._calculateDistance,
    required this._calculateScore,
  });

  final GameRepository _repository;
  final CalculateDistanceUseCase _calculateDistance;
  final CalculateScoreUseCase _calculateScore;

  @override
  Future<Either<Failure, Unit>> call(EndRoundParams params) async {
    // 1. Fetch raw answers (lat/lng only, no scores yet).
    final answersResult = await _repository.getRoundAnswers(
      partyCode: params.partyCode,
      roundIndex: params.roundIndex,
    );

    if (answersResult.isLeft()) {
      return answersResult.map((_) => unit);
    }

    final rawAnswers = answersResult.getOrElse(() => []);

    // 2 & 3. Calculate distance and score per answer.
    final processedAnswers = rawAnswers.map((answer) {
      final distanceKm = _calculateDistance(
        lat1: answer.latitude,
        lon1: answer.longitude,
        lat2: params.landmark.actualLatitude,
        lon2: params.landmark.actualLongitude,
      );
      final score = _calculateScore(distanceKm);

      return PlayerAnswerEntity(
        playerId: answer.playerId,
        playerName: answer.playerName,
        photoUrl: answer.photoUrl,
        roundIndex: answer.roundIndex,
        latitude: answer.latitude,
        longitude: answer.longitude,
        distanceKm: distanceKm,
        score: score,
        submittedAt: answer.submittedAt,
      );
    }).toList();

    // 4. Accumulate scores.
    final updatedScores = Map<String, int>.from(params.currentPlayerScores);
    for (final answer in processedAnswers) {
      updatedScores[answer.playerId] =
          (updatedScores[answer.playerId] ?? 0) + answer.score;
    }

    // 5. Persist to Firestore.
    return _repository.endRound(
      partyCode: params.partyCode,
      hostId: params.hostId,
      roundIndex: params.roundIndex,
      processedAnswers: processedAnswers,
      updatedPlayerScores: updatedScores,
    );
  }
}

class EndRoundParams extends UseCaseParams {
  const EndRoundParams({
    required this.partyCode,
    required this.hostId,
    required this.roundIndex,
    required this.landmark,
    required this.currentPlayerScores,
  });

  final String partyCode;
  final String hostId;
  final int roundIndex;

  /// Needed to calculate each player's distance from the actual location.
  final LandmarkEntity landmark;

  /// Cumulative scores before this round. Used to compute updated totals.
  final Map<String, int> currentPlayerScores;

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    roundIndex,
    landmark,
    currentPlayerScores,
  ];
}
