// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/party/domain/repositories/party_repository.dart';

class KickPlayerUseCase implements UseCase<Unit, KickPlayerParams> {
  const KickPlayerUseCase(this._repository);
  final PartyRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(KickPlayerParams params) =>
      _repository.kickPlayer(
        partyCode: params.partyCode,
        targetUid: params.targetUid,
        hostId: params.hostId,
      );
}

class KickPlayerParams extends UseCaseParams {
  const KickPlayerParams({
    required this.partyCode,
    required this.targetUid,
    required this.hostId,
  });

  final String partyCode;
  final String targetUid;
  final String hostId;

  @override
  List<Object?> get props => [partyCode, targetUid, hostId];
}
