// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/game/domain/entities/game_session_entity.dart';
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/entities/player_answer_entity.dart';

abstract class GameRepository {
  // ── Host operations ────────────────────────────────────────────────────────

  /// Creates the game session document in Firestore.
  /// Called by the host immediately after navigating to the game screen.
  Future<Either<Failure, Unit>> initializeGameSession({
    required String partyCode,
    required String hostId,
    required int totalRounds,
    required Map<String, int> initialPlayerScores,
  });

  /// Pushes a new round to all players by updating the session document.
  Future<Either<Failure, Unit>> startRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required LandmarkEntity landmark,
    required int durationSeconds,
  });

  /// Reads all submitted answers, then updates the session with processed
  /// results (distances, scores) and updated cumulative player scores.
  Future<Either<Failure, Unit>> endRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required List<PlayerAnswerEntity> processedAnswers,
    required Map<String, int> updatedPlayerScores,
  });

  /// Sets the session status to finished.
  Future<Either<Failure, Unit>> endGame({
    required String partyCode,
    required String hostId,
  });

  // ── Player operations ──────────────────────────────────────────────────────

  /// Writes a player's raw answer (lat/lng) to the answers sub-collection.
  /// Distance and score are NOT calculated here;
  /// the host does that on [endRound].
  Future<Either<Failure, Unit>> submitAnswer({
    required String partyCode,
    required String playerId,
    required String playerName,
    String? photoUrl,
    required int roundIndex,
    required double latitude,
    required double longitude,
  });

  // ── Shared operations ──────────────────────────────────────────────────────

  /// Returns a live stream of the game session document.
  /// All state transitions (round start/end/finish) propagate through this stream.
  Stream<GameSessionEntity> watchGameSession(String partyCode);

  /// Fetches the raw (unscored) player answers for a specific round.
  /// Used by [endRound] to calculate scores.
  Future<Either<Failure, List<PlayerAnswerEntity>>> getRoundAnswers({
    required String partyCode,
    required int roundIndex,
  });

  /// Fetches [count] landmarks from Firestore for use in the game.
  Future<Either<Failure, List<LandmarkEntity>>> getLandmarks({int count = 5});
}
