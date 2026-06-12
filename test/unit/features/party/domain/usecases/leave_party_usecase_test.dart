import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/leave_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LeavePartyUseCase useCase;
  late MockPartyRepository repository;
  late MockAuthRepository authRepository;

  const tUser = UserEntity(
    uid: 'playerId',
    displayName: 'playerName',
    isAnonymous: false,
  );

  setUp(() {
    repository = MockPartyRepository();
    authRepository = MockAuthRepository();
    useCase = LeavePartyUseCase(
      partyRepository: repository,
      authRepository: authRepository,
    );
  });

  test(
    'should delegate call to repository after getting current user',
    () async {
      // Arrange
      const params = LeavePartyParams(partyCode: 'ABC123');

      when(
        () => authRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      when(
        () => repository.leaveParty(
          partyCode: any(named: 'partyCode'),
          uid: any(named: 'uid'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right<Failure, Unit>(unit));

      verify(() => authRepository.getCurrentUser()).called(1);
      verify(
        () =>
            repository.leaveParty(partyCode: params.partyCode, uid: tUser.uid),
      ).called(1);

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(authRepository);
    },
  );
}
