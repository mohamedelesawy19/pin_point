// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/domain/repositories/party_repository.dart';

class CreatePartyUseCase implements UseCase<String, CreatePartyParams> {
  const CreatePartyUseCase(this._repository);
  final PartyRepository _repository;

  @override
  Future<Either<Failure, String>> call(CreatePartyParams params) =>
      _repository.createParty(
        hostId: params.hostId,
        hostName: params.hostName,
        partyName: params.partyName,
        settings: params.settings,
      );
}

class CreatePartyParams extends UseCaseParams {
  const CreatePartyParams({
    required this.hostId,
    required this.hostName,
    required this.partyName,
    required this.settings,
  });

  final String hostId;
  final String hostName;
  final String partyName;
  final PartySettings settings;

  @override
  List<Object?> get props => [hostId, hostName, partyName, settings];
}
