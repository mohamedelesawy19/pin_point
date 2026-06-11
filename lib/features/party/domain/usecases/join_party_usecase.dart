// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/party/domain/entities/player_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class JoinPartyUseCase implements UseCase<String, JoinPartyParams> {
  const JoinPartyUseCase(this._repository);
  final PartyRepository _repository;

  @override
  Future<Either<Failure, String>> call(JoinPartyParams params) => _repository
      .joinParty(partyCode: params.partyCode, player: params.playerEntity);
}

class JoinPartyParams extends UseCaseParams {
  const JoinPartyParams({required this.partyCode, required this.playerEntity});

  final String partyCode;
  final PlayerEntity playerEntity;

  @override
  List<Object?> get props => [partyCode, playerEntity];
}
