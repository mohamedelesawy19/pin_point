// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/constants/error_codes.dart';
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Features imports:
import '/features/auth/data/datasources/auth_remote_data_source.dart';
import '/features/auth/domain/entities/user_entity.dart';
import '/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final model = await _remote.signInWithGoogle();
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, code: AuthErrorCodes.signInWithGoogle),
      );
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final model = await _remote.signInAnonymously();
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, code: AuthErrorCodes.signInAnonymously),
      );
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, code: AuthErrorCodes.signOut),
      );
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return _remote.watchAuthState().map((model) => model?.toEntity());
  }
}
