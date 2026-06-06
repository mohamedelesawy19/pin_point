import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SignInWithGoogleUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInWithGoogleUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    const user = UserEntity(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Mohamed',
      isAnonymous: false,
    );

    when(
      () => repository.signInWithGoogle(),
    ).thenAnswer((_) async => const Right(user));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Right(user));
    verify(() => repository.signInWithGoogle()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
