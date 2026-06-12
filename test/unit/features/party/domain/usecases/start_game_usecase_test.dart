import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/start_game_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late StartGameUseCase useCase;
  late MockPartyRepository repository;
  late MockAuthRepository authRepository;

  const tUser = UserEntity(
    uid: 'hostId',
    displayName: 'hostName',
    isAnonymous: false,
  );

  setUp(() {
    repository = MockPartyRepository();
    authRepository = MockAuthRepository();
    useCase = StartGameUseCase(
      partyRepository: repository,
      authRepository: authRepository,
    );
  });

  test(
    'should delegate call to repository after getting current user',
    () async {
      // Arrange
      const partyCode = 'ABC123';
      const params = SingleParam<String>(partyCode);

      when(
        () => authRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      when(
        () => repository.startGame(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right<Failure, Unit>(unit));

      verify(() => authRepository.getCurrentUser()).called(1);
      verify(
        () => repository.startGame(partyCode: partyCode, hostId: tUser.uid),
      ).called(1);

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(authRepository);
    },
  );
}
