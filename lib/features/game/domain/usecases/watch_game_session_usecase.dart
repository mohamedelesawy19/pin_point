// Core imports:
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/game/domain/entities/game_session_entity.dart';
import '/features/game/domain/repositories/game_repository.dart';

class WatchGameSessionUseCase
    implements StreamUseCase<GameSessionEntity, SingleParam<String>> {
  const WatchGameSessionUseCase(this._repository);

  final GameRepository _repository;

  @override
  Stream<GameSessionEntity> call(SingleParam<String> params) =>
      _repository.watchGameSession(params.value);
}
