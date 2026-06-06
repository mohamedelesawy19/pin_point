// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/entities/user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase implements NoParamsStreamUseCase<UserEntity?> {
  const WatchAuthStateUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Stream<Either<Failure, UserEntity?>> call() => _repository.watchAuthState();
}
