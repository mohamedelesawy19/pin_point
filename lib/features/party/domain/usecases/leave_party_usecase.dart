// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/domain/repositories/party_repository.dart';

class LeavePartyUseCase implements UseCase<Unit, LeavePartyParams> {
  const LeavePartyUseCase({
    required this._partyRepository,
    required this._authRepository,
  });

  final PartyRepository _partyRepository;
  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Unit>> call(LeavePartyParams params) async {
    final userResult = await _authRepository.getCurrentUser();

    return userResult.fold(
      (failure) => Left(failure),
      (user) => _partyRepository.leaveParty(
        partyCode: params.partyCode,
        uid: user.uid,
      ),
    );
  }
}

class LeavePartyParams extends UseCaseParams {
  const LeavePartyParams({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}
