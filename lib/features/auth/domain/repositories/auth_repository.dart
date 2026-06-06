// Packages imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInAnonymously();
  Future<Either<Failure, void>> signOut();
  Stream<Either<Failure, UserEntity?>> watchAuthState();
}
