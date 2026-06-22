import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/data/models/game_round_model.dart';
import 'package:pin_point/features/game/data/models/game_session_model.dart';
import 'package:pin_point/features/game/data/models/landmark_model.dart';
import 'package:pin_point/features/game/data/models/player_answer_model.dart';
import 'package:pin_point/features/game/domain/entities/game_round_entity.dart';
import 'package:pin_point/features/game/domain/entities/game_session_entity.dart';

void main() {
  final tDate = DateTime.parse('2025-01-01T12:00:00.000Z');

  const tLandmark = LandmarkModel(
    id: '1',
    name: 'Eiffel Tower',
    imageUrl: 'image.jpg',
    actualLatitude: 48.8584,
    actualLongitude: 2.2945,
    country: 'France',
    city: 'Paris',
  );

  final tRound = GameRoundModel(
    roundIndex: 1,
    landmark: tLandmark,
    startedAt: tDate,
    endsAt: tDate.add(const Duration(minutes: 1)),
    status: RoundStatus.active,
  );

  final tAnswer = PlayerAnswerModel(
    playerId: 'player1',
    playerName: 'Mohamed',
    roundIndex: 1,
    latitude: 30,
    longitude: 31,
    distanceKm: 12,
    score: 900,
    submittedAt: tDate,
  );

  final tModel = GameSessionModel(
    partyCode: 'ABC123',
    hostId: 'host1',
    status: GameStatus.roundActive,
    currentRoundIndex: 1,
    totalRounds: 5,
    playerScores: const {'player1': 900, 'player2': 850},
    currentRound: tRound,
    roundResults: [tAnswer],
  );

  final tJson = {
    'partyCode': 'ABC123',
    'hostId': 'host1',
    'status': 'roundActive',
    'currentRoundIndex': 1,
    'totalRounds': 5,
    'playerScores': {'player1': 900, 'player2': 850},
    'currentRound': tRound.toJson(),
    'roundResults': [tAnswer.toJson()],
  };

  group('GameSessionModel', () {
    test('fromJson should return model', () {
      final result = GameSessionModel.fromJson(tJson);

      expect(result, tModel);
    });

    test('toJson should return json', () {
      final result = tModel.toJson();

      expect(result, tJson);
    });

    test('fromEntity should return model', () {
      final entity = tModel.toEntity();

      final result = GameSessionModel.fromEntity(entity);

      expect(result, tModel);
    });

    test('toEntity should return entity', () {
      final result = tModel.toEntity();

      expect(result.partyCode, 'ABC123');
      expect(result.hostId, 'host1');
      expect(result.currentRoundIndex, 1);
      expect(result.totalRounds, 5);
    });

    test('should handle null currentRound and roundResults', () {
      const model = GameSessionModel(
        partyCode: 'ABC123',
        hostId: 'host1',
        status: GameStatus.initializing,
        currentRoundIndex: 0,
        totalRounds: 5,
        playerScores: {},
      );

      final json = model.toJson();

      final result = GameSessionModel.fromJson(json);

      expect(result.currentRound, isNull);
      expect(result.roundResults, isNull);
    });
  });
}
