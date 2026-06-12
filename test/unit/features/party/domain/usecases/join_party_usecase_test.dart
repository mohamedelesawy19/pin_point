import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/join_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late JoinPartyUseCase useCase;
  late MockPartyRepository repository;
  late MockAuthRepository authRepository;

  const tUser = UserEntity(
    uid: 'playerId',
    displayName: 'playerName',
    isAnonymous: false,
  );

  setUpAll(() {
    registerFallbackValue(PlayerEntity.fromUser(tUser));
  });

  setUp(() {
    repository = MockPartyRepository();
    authRepository = MockAuthRepository();
    useCase = JoinPartyUseCase(
      partyRepository: repository,
      authRepository: authRepository,
    );
  });

  test(
    'should delegate call to repository after getting current user',
    () async {
      // Arrange
      const partyCode = '123456';
      const params = SingleParam<String>(partyCode);

      when(
        () => authRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      when(
        () => repository.joinParty(
          partyCode: any(named: 'partyCode'),
          player: any(named: 'player'),
        ),
      ).thenAnswer((_) async => const Right(partyCode));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right<Failure, String>(partyCode));

      verify(() => authRepository.getCurrentUser()).called(1);
      verify(
        () => repository.joinParty(
          partyCode: partyCode,
          player: PlayerEntity.fromUser(tUser),
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(authRepository);
    },
  );
}
