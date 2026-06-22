// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/domain/entities/player_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class JoinPartyUseCase implements UseCase<String, SingleParam<String>> {
  const JoinPartyUseCase({
    required this._partyRepository,
    required this._authRepository,
  });

  final PartyRepository _partyRepository;
  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, String>> call(SingleParam<String> params) async {
    final userResult = await _authRepository.getCurrentUser();

    return await userResult.fold(
      (failure) async => Left(failure),
      (user) => _partyRepository.joinParty(
        partyCode: params.value,
        player: PlayerEntity.fromUser(user),
      ),
    );
  }
}
