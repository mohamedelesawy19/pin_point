import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';

void main() {
  group('PartyEntity', () {
    test('supports value equality', () {
      expect(
        PartyEntity(
          partyCode: 'ABC123',
          hostId: 'host1',
          hostName: 'Host Name',
          partyName: 'My Party',
          status: PartyStatus.waiting,
          settings: const PartySettings(
            roundDurationSeconds: 30,
            totalRounds: 5,
          ),
          players: const [],
          currentRound: 0,
          createdAt: DateTime(2026, 1, 1, 12),
        ),
        equals(
          PartyEntity(
            partyCode: 'ABC123',
            hostId: 'host1',
            hostName: 'Host Name',
            partyName: 'My Party',
            status: PartyStatus.waiting,
            settings: const PartySettings(
              roundDurationSeconds: 30,
              totalRounds: 5,
            ),
            players: const [],
            currentRound: 0,
            createdAt: DateTime(2026, 1, 1, 12),
          ),
        ),
      );
    });

    test('props are correct', () {
      final party = PartyEntity(
        partyCode: 'ABC123',
        hostId: 'host1',
        hostName: 'Host Name',
        partyName: 'My Party',
        status: PartyStatus.waiting,
        settings: const PartySettings(roundDurationSeconds: 30, totalRounds: 5),
        players: const [],
        currentRound: 0,
        createdAt: DateTime(2026, 1, 1, 12),
      );

      expect(party.props, [
        'ABC123',
        'host1',
        'Host Name',
        'My Party',
        PartyStatus.waiting,
        const PartySettings(roundDurationSeconds: 30, totalRounds: 5),
        [],
        0,
        DateTime(2026, 1, 1, 12),
      ]);
    });
  });
}
