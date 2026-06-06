import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/auth/domain/usecases/watch_auth_state_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late WatchAuthStateUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = WatchAuthStateUseCase(repository);
  });

  test('should delegate stream from repository', () {
    // Arrange
    const user = UserEntity(uid: '123', isAnonymous: true);

    final stream = Stream<Either<Failure, UserEntity?>>.value(
      const Right(user),
    );

    when(() => repository.watchAuthState()).thenAnswer((_) => stream);

    // Act
    final result = useCase();

    // Assert
    expect(result, emits(const Right(user)));

    verify(() => repository.watchAuthState()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
