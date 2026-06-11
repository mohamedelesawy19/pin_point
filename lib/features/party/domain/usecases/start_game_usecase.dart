// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/party/domain/repositories/party_repository.dart';

class StartGameUseCase implements UseCase<Unit, StartGameParams> {
  const StartGameUseCase(this._repository);
  final PartyRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(StartGameParams params) =>
      _repository.startGame(partyCode: params.partyCode, hostId: params.hostId);
}

class StartGameParams extends UseCaseParams {
  const StartGameParams({required this.partyCode, required this.hostId});

  final String partyCode;
  final String hostId;

  @override
  List<Object?> get props => [partyCode, hostId];
}
