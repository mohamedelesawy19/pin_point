// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/repositories/game_repository.dart';

class StartRoundUseCase implements UseCase<Unit, StartRoundParams> {
  const StartRoundUseCase(this._repository);

  final GameRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(StartRoundParams params) =>
      _repository.startRound(
        partyCode: params.partyCode,
        hostId: params.hostId,
        roundIndex: params.roundIndex,
        landmark: params.landmark,
        durationSeconds: params.durationSeconds,
      );
}

class StartRoundParams extends UseCaseParams {
  const StartRoundParams({
    required this.partyCode,
    required this.hostId,
    required this.roundIndex,
    required this.landmark,
    required this.durationSeconds,
  });

  final String partyCode;
  final String hostId;
  final int roundIndex;
  final LandmarkEntity landmark;
  final int durationSeconds;

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    roundIndex,
    landmark,
    durationSeconds,
  ];
}
