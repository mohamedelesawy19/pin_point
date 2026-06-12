// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/domain/repositories/party_repository.dart';

class StartGameUseCase implements UseCase<Unit, SingleParam<String>> {
  const StartGameUseCase({
    required this._partyRepository,
    required this._authRepository,
  });

  final PartyRepository _partyRepository;
  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Unit>> call(SingleParam<String> params) async {
    final userResult = await _authRepository.getCurrentUser();

    return userResult.fold(
      (failure) => Left(failure),
      (user) =>
          _partyRepository.startGame(partyCode: params.value, hostId: user.uid),
    );
  }
}
