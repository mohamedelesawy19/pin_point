// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/repositories/game_repository.dart';

class InitializeGameSessionUseCase
    implements UseCase<Unit, InitializeGameSessionParams> {
  const InitializeGameSessionUseCase(this._repository);

  final GameRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(InitializeGameSessionParams params) =>
      _repository.initializeGameSession(
        partyCode: params.partyCode,
        hostId: params.hostId,
        totalRounds: params.totalRounds,
        initialPlayerScores: params.initialPlayerScores,
      );
}

class InitializeGameSessionParams extends UseCaseParams {
  const InitializeGameSessionParams({
    required this.partyCode,
    required this.hostId,
    required this.totalRounds,
    required this.initialPlayerScores,
  });

  final String partyCode;
  final String hostId;
  final int totalRounds;

  /// Keyed by player UID. Typically all zeros at game start.
  final Map<String, int> initialPlayerScores;

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    totalRounds,
    initialPlayerScores,
  ];
}
