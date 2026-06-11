// Core imports:
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class WatchPartyUseCase
    implements StreamUseCase<PartyEntity, SingleParam<String>> {
  const WatchPartyUseCase(this._repository);
  final PartyRepository _repository;

  @override
  Stream<PartyEntity> call(SingleParam<String> params) =>
      _repository.watchParty(params.value);
}
