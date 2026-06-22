import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/data/models/game_round_model.dart';
import 'package:pin_point/features/game/data/models/landmark_model.dart';
import 'package:pin_point/features/game/domain/entities/game_round_entity.dart';

void main() {
  final tStartedAt = DateTime.parse('2025-01-01T12:00:00.000Z');
  final tEndsAt = DateTime.parse('2025-01-01T12:01:00.000Z');

  const tLandmark = LandmarkModel(
    id: '1',
    name: 'Eiffel Tower',
    imageUrl: 'image.jpg',
    actualLatitude: 48.8584,
    actualLongitude: 2.2945,
    country: 'France',
    city: 'Paris',
  );

  final tModel = GameRoundModel(
    roundIndex: 1,
    landmark: tLandmark,
    startedAt: tStartedAt,
    endsAt: tEndsAt,
    status: RoundStatus.active,
  );

  final tJson = {
    'roundIndex': 1,
    'landmark': tLandmark.toJson(),
    'startedAt': tStartedAt.toIso8601String(),
    'endsAt': tEndsAt.toIso8601String(),
    'status': 'active',
  };

  final tEntity = GameRoundEntity(
    roundIndex: 1,
    landmark: tLandmark.toEntity(),
    startedAt: tStartedAt,
    endsAt: tEndsAt,
    status: RoundStatus.active,
  );

  group('GameRoundModel', () {
    test('fromJson should return model', () {
      final result = GameRoundModel.fromJson(tJson);

      expect(result, tModel);
    });

    test('toJson should return json', () {
      final result = tModel.toJson();

      expect(result, tJson);
    });

    test('fromEntity should return model', () {
      final result = GameRoundModel.fromEntity(tEntity);

      expect(result, tModel);
    });

    test('toEntity should return entity', () {
      final result = tModel.toEntity();

      expect(result, tEntity);
    });
  });
}
