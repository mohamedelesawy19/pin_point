import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/data/models/player_answer_model.dart';
import 'package:pin_point/features/game/domain/entities/player_answer_entity.dart';

void main() {
  final tDate = DateTime.parse('2025-01-01T12:00:00.000Z');

  final tModel = PlayerAnswerModel(
    playerId: 'player1',
    playerName: 'Mohamed',
    photoUrl: 'photo.png',
    roundIndex: 1,
    latitude: 30.0,
    longitude: 31.0,
    distanceKm: 10.5,
    score: 950,
    submittedAt: tDate,
  );

  final tJson = {
    'playerId': 'player1',
    'playerName': 'Mohamed',
    'photoUrl': 'photo.png',
    'roundIndex': 1,
    'latitude': 30.0,
    'longitude': 31.0,
    'distanceKm': 10.5,
    'score': 950,
    'submittedAt': tDate.toIso8601String(),
  };

  final tEntity = PlayerAnswerEntity(
    playerId: 'player1',
    playerName: 'Mohamed',
    photoUrl: 'photo.png',
    roundIndex: 1,
    latitude: 30.0,
    longitude: 31.0,
    distanceKm: 10.5,
    score: 950,
    submittedAt: tDate,
  );

  group('PlayerAnswerModel', () {
    test('fromJson should return valid model', () {
      final result = PlayerAnswerModel.fromJson(tJson);

      expect(result, tModel);
    });

    test('toJson should return valid json', () {
      final result = tModel.toJson();

      expect(result, tJson);
    });

    test('fromEntity should return model', () {
      final result = PlayerAnswerModel.fromEntity(tEntity);

      expect(result, tModel);
    });

    test('toEntity should return entity', () {
      final result = tModel.toEntity();

      expect(result, tEntity);
    });
  });
}
