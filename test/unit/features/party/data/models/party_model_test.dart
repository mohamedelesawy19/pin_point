import 'package:flutter_test/flutter_test.dart';
import 'package:pin_point/features/party/data/models/party_model.dart';
import 'package:pin_point/features/party/data/models/party_settings_model.dart';
import 'package:pin_point/features/party/data/models/player_model.dart';
import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';

void main() {
  group('PartyModel', () {
    final tCreatedAt = DateTime(2026);

    const tPartySettingsModel = PartySettingsModel(
      roundDurationSeconds: 60,
      totalRounds: 5,
    );

    const tPartySettings = PartySettings(
      roundDurationSeconds: 60,
      totalRounds: 5,
    );

    const tPlayerModel = PlayerModel(
      uid: '1',
      displayName: 'Player 1',
      photoUrl: 'url',
      isAnonymous: false,
      score: 0,
    );

    const tPlayerEntity = PlayerEntity(
      uid: '1',
      displayName: 'Player 1',
      photoUrl: 'url',
      isAnonymous: false,
      score: 0,
    );

    final tPartyModel = PartyModel(
      partyCode: '123456',
      hostId: 'host123',
      hostName: 'Host Name',
      partyName: 'Party Name',
      status: PartyStatus.waiting,
      settings: tPartySettingsModel,
      players: const [tPlayerModel],
      kickedPlayers: const {},
      currentRound: 1,
      createdAt: tCreatedAt,
    );

    final tPartyEntity = PartyEntity(
      partyCode: '123456',
      hostId: 'host123',
      hostName: 'Host Name',
      partyName: 'Party Name',
      status: PartyStatus.waiting,
      settings: tPartySettings,
      players: const [tPlayerEntity],
      kickedPlayers: const {},
      currentRound: 1,
      createdAt: tCreatedAt,
    );

    test('supports value equality', () {
      expect(
        tPartyModel,
        PartyModel(
          partyCode: '123456',
          hostId: 'host123',
          hostName: 'Host Name',
          partyName: 'Party Name',
          status: PartyStatus.waiting,
          settings: tPartySettingsModel,
          players: const [tPlayerModel],
          kickedPlayers: const {},
          currentRound: 1,
          createdAt: tCreatedAt,
        ),
      );
    });

    test('fromJson should return a valid model', () {
      // Arrange
      final json = <String, dynamic>{
        'partyCode': '123456',
        'hostId': 'host123',
        'hostName': 'Host Name',
        'partyName': 'Party Name',
        'status': 'waiting',
        'settings': {'roundDurationSeconds': 60, 'totalRounds': 5},
        'players': [
          {
            'uid': '1',
            'displayName': 'Player 1',
            'photoUrl': 'url',
            'isAnonymous': false,
            'score': 0,
          },
        ],
        'kickedPlayers': {},
        'currentRound': 1,
        'createdAt': tCreatedAt.toIso8601String(),
      };

      // Act
      final result = PartyModel.fromJson(json);

      // Assert
      expect(result, tPartyModel);
    });

    test('toJson should return a valid json map', () {
      // Act
      final result = tPartyModel.toJson();

      // Assert
      expect(result, <String, dynamic>{
        'partyCode': '123456',
        'hostId': 'host123',
        'hostName': 'Host Name',
        'partyName': 'Party Name',
        'status': 'waiting',
        'settings': {'roundDurationSeconds': 60, 'totalRounds': 5},
        'players': [
          {
            'uid': '1',
            'displayName': 'Player 1',
            'photoUrl': 'url',
            'isAnonymous': false,
            'score': 0,
          },
        ],
        'kickedPlayers': const {},
        'currentRound': 1,
        'createdAt': tCreatedAt.toIso8601String(),
      });
    });

    test('fromEntity should create model from entity', () {
      // Act
      final result = PartyModel.fromEntity(tPartyEntity);

      // Assert
      expect(result, tPartyModel);
    });

    test('toEntity should return domain entity', () {
      // Act
      final result = tPartyModel.toEntity();

      // Assert
      expect(result, tPartyEntity);
    });
  });
}
