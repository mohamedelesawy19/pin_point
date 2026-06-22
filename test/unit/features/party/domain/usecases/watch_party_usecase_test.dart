import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/usecases/usecase.dart';

import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/watch_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late WatchPartyUseCase useCase;
  late MockPartyRepository repository;

  setUp(() {
    repository = MockPartyRepository();
    useCase = WatchPartyUseCase(repository);
  });

  test('should delegate stream from repository', () {
    // Arrange
    final party = PartyEntity(
      hostId: 'hostId',
      hostName: 'hostName',
      partyName: 'partyName',
      settings: const PartySettings(roundDurationSeconds: 30, totalRounds: 4),
      players: const [
        PlayerEntity(
          uid: 'playerId',
          displayName: 'playerName',
          isAnonymous: false,
          score: 0,
        ),
      ],
      kickedPlayers: const {},
      partyCode: 'ABC123',
      status: PartyStatus.waiting,
      createdAt: DateTime(2026, 1, 1, 12),
      currentRound: 0,
    );

    const params = SingleParam<String>('ABC123');

    final stream = Stream<PartyEntity>.value(party);

    when(() => repository.watchParty(params.value)).thenAnswer((_) => stream);

    // Act
    final result = useCase(params);

    // Assert
    expect(result, emits(party));

    verify(() => repository.watchParty(params.value)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
