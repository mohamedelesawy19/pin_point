import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/join_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late JoinPartyUseCase useCase;
  late MockPartyRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const PlayerEntity(uid: '', displayName: '', isAnonymous: true, score: 0),
    );
  });

  setUp(() {
    repository = MockPartyRepository();
    useCase = JoinPartyUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    const params = JoinPartyParams(
      partyCode: 'ABC123',
      playerEntity: PlayerEntity(
        uid: 'playerId',
        displayName: 'playerName',
        isAnonymous: false,
        score: 0,
      ),
    );

    const partyCode = '123456';

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

    verify(
      () => repository.joinParty(
        partyCode: params.partyCode,
        player: params.playerEntity,
      ),
    ).called(1);

    verifyNoMoreInteractions(repository);
  });
}
