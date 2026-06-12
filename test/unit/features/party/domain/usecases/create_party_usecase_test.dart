import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/repositories/auth_repository.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/create_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CreatePartyUseCase useCase;
  late MockPartyRepository repository;
  late MockAuthRepository authRepository;

  const tUser = UserEntity(
    uid: 'hostId',
    displayName: 'hostName',
    isAnonymous: false,
  );

  setUpAll(() {
    registerFallbackValue(
      const PartySettings(roundDurationSeconds: 30, totalRounds: 4),
    );
    registerFallbackValue(PlayerEntity.fromUser(tUser));
  });

  setUp(() {
    repository = MockPartyRepository();
    authRepository = MockAuthRepository();
    useCase = CreatePartyUseCase(
      partyRepository: repository,
      authRepository: authRepository,
    );
  });

  test(
    'should delegate call to repository after getting current user',
    () async {
      // Arrange
      const params = CreatePartyParams(
        partyName: 'partyName',
        settings: PartySettings(roundDurationSeconds: 30, totalRounds: 4),
      );

      when(
        () => authRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      when(
        () => repository.createParty(
          hostPlayer: any(named: 'hostPlayer'),
          partyName: any(named: 'partyName'),
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async => const Right('partyId'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right<Failure, String>('partyId'));

      verify(() => authRepository.getCurrentUser()).called(1);
      verify(
        () => repository.createParty(
          hostPlayer: PlayerEntity.fromUser(tUser),
          partyName: params.partyName,
          settings: params.settings,
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(authRepository);
    },
  );
}
