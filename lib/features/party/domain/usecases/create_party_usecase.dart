// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/domain/entities/player_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class CreatePartyUseCase implements UseCase<String, CreatePartyParams> {
  const CreatePartyUseCase({
    required this._partyRepository,
    required this._authRepository,
  });

  final PartyRepository _partyRepository;
  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, String>> call(CreatePartyParams params) async {
    final userResult = await _authRepository.getCurrentUser();

    return userResult.fold(
      (failure) => Left(failure),
      (user) => _partyRepository.createParty(
        hostPlayer: PlayerEntity.fromUser(user),
        partyName: params.partyName,
        settings: params.settings,
      ),
    );
  }
}

class CreatePartyParams extends UseCaseParams {
  const CreatePartyParams({required this.partyName, required this.settings});

  final String partyName;
  final PartySettings settings;

  @override
  List<Object?> get props => [partyName, settings];
}
