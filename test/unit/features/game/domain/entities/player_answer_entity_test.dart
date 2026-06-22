import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/domain/entities/player_answer_entity.dart';

void main() {
  group('PlayerAnswerEntity', () {
    test('distanceLabel formats < 10 km with 1 decimal', () {
      final answer = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        roundIndex: 0,
        latitude: 0,
        longitude: 0,
        distanceKm: 5.25,
        score: 100,
        submittedAt: DateTime(2026),
      );

      expect(answer.distanceLabel, '5.3 km');
    });

    test('distanceLabel rounds < 1000 km to integer', () {
      final answer = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        roundIndex: 0,
        latitude: 0,
        longitude: 0,
        distanceKm: 123.7,
        score: 100,
        submittedAt: DateTime(2026),
      );

      expect(answer.distanceLabel, '124 km');
    });

    test('distanceLabel formats >= 1000 km as k km', () {
      final answer = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        roundIndex: 0,
        latitude: 0,
        longitude: 0,
        distanceKm: 1500,
        score: 100,
        submittedAt: DateTime(2026),
      );

      expect(answer.distanceLabel, '1.5k km');
    });

    test('supports value equality', () {
      final t = DateTime(2026);

      final a1 = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        photoUrl: 'url1',
        roundIndex: 0,
        latitude: 10,
        longitude: 10,
        distanceKm: 10,
        score: 100,
        submittedAt: t,
      );

      final a2 = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        photoUrl: 'different-url', // ignored in equality
        roundIndex: 0,
        latitude: 10,
        longitude: 10,
        distanceKm: 10,
        score: 100,
        submittedAt: t,
      );

      expect(a1, equals(a2));
    });

    test('different score makes entities not equal', () {
      final t = DateTime(2026);

      final a1 = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        roundIndex: 0,
        latitude: 10,
        longitude: 10,
        distanceKm: 10,
        score: 100,
        submittedAt: t,
      );

      final a2 = PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        roundIndex: 0,
        latitude: 10,
        longitude: 10,
        distanceKm: 10,
        score: 200,
        submittedAt: t,
      );

      expect(a1, isNot(equals(a2)));
    });
  });
}
