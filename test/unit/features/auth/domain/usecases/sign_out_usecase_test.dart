import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/auth/domain/usecases/sign_out_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SignOutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignOutUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    when(() => repository.signOut()).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase();

    // Assert
    expect(result, const Right(null));

    verify(() => repository.signOut()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
