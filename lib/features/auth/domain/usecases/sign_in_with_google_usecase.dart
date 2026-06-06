// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Features imports:
import '/features/auth/domain/entities/user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase implements NoParamsUseCase<UserEntity> {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call() => _repository.signInWithGoogle();
}
