import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SignInAnonymouslyUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInAnonymouslyUseCase(repository);
  });

  test('should delegate call to repository', () async {
    const user = UserEntity(uid: '123', isAnonymous: true);

    when(
      () => repository.signInAnonymously(),
    ).thenAnswer((_) async => const Right(user));

    final result = await useCase();

    expect(result, const Right(user));
    verify(() => repository.signInAnonymously()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
