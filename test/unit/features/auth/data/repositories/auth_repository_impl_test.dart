import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/constants/error_codes.dart';
import 'package:pin_point/core/errors/exceptions.dart';
import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pin_point/features/auth/data/models/user_model.dart';
import 'package:pin_point/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pin_point/features/auth/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remote;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote);
  });

  const user = UserModel(
    uid: '123',
    email: 'test@test.com',
    displayName: 'Mohamed',
    isAnonymous: false,
  );

  const entity = UserEntity(
    uid: '123',
    email: 'test@test.com',
    displayName: 'Mohamed',
    isAnonymous: false,
  );

  group('signInWithGoogle', () {
    test('returns Right(UserEntity) on success', () async {
      when(() => remote.signInWithGoogle()).thenAnswer((_) async => user);

      final result = await repository.signInWithGoogle();

      expect(result, const Right(entity));

      verify(() => remote.signInWithGoogle()).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(
        () => remote.signInWithGoogle(),
      ).thenThrow(const AuthException(message: 'google failed'));

      final result = await repository.signInWithGoogle();

      expect(
        result,
        const Left(
          AuthFailure(
            message: 'google failed',
            code: AuthErrorCodes.signInWithGoogle,
          ),
        ),
      );
    });

    test('returns UnknownFailure on unknown exception', () async {
      when(() => remote.signInWithGoogle()).thenThrow(Exception('boom'));

      final result = await repository.signInWithGoogle();

      expect(result.isLeft(), true);
    });
  });

  group('signInAnonymously', () {
    test('returns Right(UserEntity) on success', () async {
      when(() => remote.signInAnonymously()).thenAnswer((_) async => user);

      final result = await repository.signInAnonymously();

      expect(result, const Right(entity));

      verify(() => remote.signInAnonymously()).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(
        () => remote.signInAnonymously(),
      ).thenThrow(const AuthException(message: 'anonymous failed'));

      final result = await repository.signInAnonymously();

      expect(
        result,
        const Left(
          AuthFailure(
            message: 'anonymous failed',
            code: AuthErrorCodes.signInAnonymously,
          ),
        ),
      );
    });

    test('returns UnknownFailure on unknown exception', () async {
      when(() => remote.signInAnonymously()).thenThrow(Exception('boom'));

      final result = await repository.signInAnonymously();

      expect(result.isLeft(), true);
    });
  });

  group('signOut', () {
    test('returns Right(null) on success', () async {
      when(() => remote.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, const Right(null));

      verify(() => remote.signOut()).called(1);
    });

    test('returns AuthFailure on AuthException', () async {
      when(
        () => remote.signOut(),
      ).thenThrow(const AuthException(message: 'sign out failed'));

      final result = await repository.signOut();

      expect(
        result,
        const Left(
          AuthFailure(message: 'sign out failed', code: AuthErrorCodes.signOut),
        ),
      );
    });

    test('returns UnknownFailure on unknown exception', () async {
      when(() => remote.signOut()).thenThrow(Exception('boom'));

      final result = await repository.signOut();

      expect(result.isLeft(), true);
    });
  });

  group('watchAuthState', () {
    test('emits Right(user)', () {
      when(() => remote.watchAuthState()).thenAnswer((_) => Stream.value(user));

      expect(repository.watchAuthState(), emits(entity));
    });

    test('emits Right(null)', () {
      when(() => remote.watchAuthState()).thenAnswer((_) => Stream.value(null));

      expect(repository.watchAuthState(), emits(null));
    });
  });
}
