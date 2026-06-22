// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/repositories/game_repository.dart';

class EndGameUseCase implements UseCase<Unit, EndGameParams> {
  const EndGameUseCase(this._repository);

  final GameRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(EndGameParams params) =>
      _repository.endGame(partyCode: params.partyCode, hostId: params.hostId);
}

class EndGameParams extends UseCaseParams {
  const EndGameParams({required this.partyCode, required this.hostId});

  final String partyCode;
  final String hostId;

  @override
  List<Object?> get props => [partyCode, hostId];
}
