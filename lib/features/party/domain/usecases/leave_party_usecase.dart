// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/party/domain/repositories/party_repository.dart';

class LeavePartyUseCase implements UseCase<Unit, LeavePartyParams> {
  const LeavePartyUseCase(this._repository);
  final PartyRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(LeavePartyParams params) =>
      _repository.leaveParty(partyCode: params.partyCode, uid: params.playerId);
}

class LeavePartyParams extends UseCaseParams {
  const LeavePartyParams({required this.partyCode, required this.playerId});

  final String partyCode;
  final String playerId;

  @override
  List<Object?> get props => [partyCode, playerId];
}
