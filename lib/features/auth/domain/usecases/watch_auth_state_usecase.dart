// Core imports:
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/entities/user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase implements NoParamsStreamUseCase<UserEntity?> {
  const WatchAuthStateUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Stream<UserEntity?> call() => _repository.watchAuthState();
}
