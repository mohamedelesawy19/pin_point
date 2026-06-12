import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/kick_player_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late KickPlayerUseCase useCase;
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
    useCase = KickPlayerUseCase(
      partyRepository: repository,
      authRepository: authRepository,
    );
  });

  test(
    'should delegate call to repository after getting current user',
    () async {
      // Arrange
      const params = KickPlayerParams(
        partyCode: 'ABC123',
        targetUid: 'targetUid',
      );

      when(
        () => authRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      when(
        () => repository.kickPlayer(
          partyCode: any(named: 'partyCode'),
          targetUid: any(named: 'targetUid'),
          hostId: any(named: 'hostId'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right<Failure, Unit>(unit));

      verify(() => authRepository.getCurrentUser()).called(1);
      verify(
        () => repository.kickPlayer(
          partyCode: params.partyCode,
          targetUid: params.targetUid,
          hostId: tUser.uid,
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(authRepository);
    },
  );
}
