// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Feature imports:
import '/features/game/data/datasources/game_remote_datasource.dart';
import '/features/game/data/models/landmark_model.dart';
import '/features/game/data/models/player_answer_model.dart';
import '/features/game/domain/entities/game_session_entity.dart';
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/entities/player_answer_entity.dart';
import '/features/game/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl({required this._remoteDataSource});

  final GameRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Unit>> initializeGameSession({
    required String partyCode,
    required String hostId,
    required int totalRounds,
    required Map<String, int> initialPlayerScores,
  }) => _execute(
    () => _remoteDataSource.initializeGameSession(
      partyCode: partyCode,
      hostId: hostId,
      totalRounds: totalRounds,
      initialPlayerScores: initialPlayerScores,
    ),
  );

  @override
  Future<Either<Failure, Unit>> startRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required LandmarkEntity landmark,
    required int durationSeconds,
  }) => _execute(
    () => _remoteDataSource.startRound(
      partyCode: partyCode,
      hostId: hostId,
      roundIndex: roundIndex,
      landmark: LandmarkModel.fromEntity(landmark),
      durationSeconds: durationSeconds,
    ),
  );

  @override
  Future<Either<Failure, Unit>> endRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required List<PlayerAnswerEntity> processedAnswers,
    required Map<String, int> updatedPlayerScores,
  }) => _execute(
    () => _remoteDataSource.endRound(
      partyCode: partyCode,
      hostId: hostId,
      roundIndex: roundIndex,
      processedAnswers: processedAnswers
          .map(PlayerAnswerModel.fromEntity)
          .toList(),
      updatedPlayerScores: updatedPlayerScores,
    ),
  );

  @override
  Future<Either<Failure, Unit>> endGame({
    required String partyCode,
    required String hostId,
  }) => _execute(
    () => _remoteDataSource.endGame(partyCode: partyCode, hostId: hostId),
  );

  @override
  Future<Either<Failure, Unit>> submitAnswer({
    required String partyCode,
    required String playerId,
    required String playerName,
    String? photoUrl,
    required int roundIndex,
    required double latitude,
    required double longitude,
  }) => _execute(
    () => _remoteDataSource.submitAnswer(
      partyCode: partyCode,
      playerId: playerId,
      playerName: playerName,
      photoUrl: photoUrl,
      roundIndex: roundIndex,
      latitude: latitude,
      longitude: longitude,
    ),
  );

  @override
  Stream<GameSessionEntity> watchGameSession(String partyCode) {
    return _remoteDataSource
        .watchGameSession(partyCode)
        .map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, List<PlayerAnswerEntity>>> getRoundAnswers({
    required String partyCode,
    required int roundIndex,
  }) async {
    try {
      final models = await _remoteDataSource.getRoundAnswers(
        partyCode: partyCode,
        roundIndex: roundIndex,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LandmarkEntity>>> getLandmarks({
    int count = 5,
  }) async {
    try {
      final models = await _remoteDataSource.getLandmarks(count: count);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _execute(Future<void> Function() call) async {
    try {
      await call();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
