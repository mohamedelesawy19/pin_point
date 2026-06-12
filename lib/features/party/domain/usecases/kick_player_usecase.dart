// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/domain/repositories/party_repository.dart';

class KickPlayerUseCase implements UseCase<Unit, KickPlayerParams> {
  const KickPlayerUseCase({
    required this._partyRepository,
    required this._authRepository,
  });

  final PartyRepository _partyRepository;
  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Unit>> call(KickPlayerParams params) async {
    final userResult = await _authRepository.getCurrentUser();

    return userResult.fold(
      (failure) => Left(failure),
      (user) => _partyRepository.kickPlayer(
        partyCode: params.partyCode,
        targetUid: params.targetUid,
        hostId: user.uid,
      ),
    );
  }
}

class KickPlayerParams extends UseCaseParams {
  const KickPlayerParams({required this.partyCode, required this.targetUid});

  final String partyCode;
  final String targetUid;

  @override
  List<Object?> get props => [partyCode, targetUid];
}
