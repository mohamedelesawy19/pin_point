import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/domain/entities/game_round_entity.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';

void main() {
  group('GameRoundEntity', () {
    const landmark = LandmarkEntity(
      id: '1',
      name: 'Pyramids',
      actualLatitude: 29.9792,
      actualLongitude: 31.1342,
      imageUrl: 'https://example.com/pyramids.jpg',
    );

    test('totalDurationSeconds returns duration in seconds', () {
      final startedAt = DateTime(2026, 1, 1, 12);
      final endsAt = startedAt.add(const Duration(seconds: 90));

      final round = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: startedAt,
        endsAt: endsAt,
        status: RoundStatus.active,
      );

      expect(round.totalDurationSeconds, 90);
    });

    test('totalDurationSeconds is clamped to minimum 1 second', () {
      final now = DateTime.now();

      final round = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: now,
        endsAt: now,
        status: RoundStatus.active,
      );

      expect(round.totalDurationSeconds, 1);
    });

    test('remainingSeconds returns positive remaining time', () {
      final now = DateTime.now();

      final round = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: now.subtract(const Duration(seconds: 10)),
        endsAt: now.add(const Duration(seconds: 30)),
        status: RoundStatus.active,
      );

      expect(round.remainingSeconds, inInclusiveRange(29, 30));
    });

    test('remainingSeconds returns 0 when round expired', () {
      final now = DateTime.now();

      final round = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: now.subtract(const Duration(seconds: 60)),
        endsAt: now.subtract(const Duration(seconds: 10)),
        status: RoundStatus.results,
      );

      expect(round.remainingSeconds, 0);
    });

    test('isExpired returns true when end time passed', () {
      final now = DateTime.now();

      final round = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: now.subtract(const Duration(seconds: 60)),
        endsAt: now.subtract(const Duration(seconds: 1)),
        status: RoundStatus.results,
      );

      expect(round.isExpired, isTrue);
    });

    test('isExpired returns false when round still active', () {
      final now = DateTime.now();

      final round = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: now,
        endsAt: now.add(const Duration(seconds: 60)),
        status: RoundStatus.active,
      );

      expect(round.isExpired, isFalse);
    });

    test('supports value equality', () {
      final startedAt = DateTime(2026);
      final endsAt = startedAt.add(const Duration(seconds: 60));

      final round1 = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: startedAt,
        endsAt: endsAt,
        status: RoundStatus.active,
      );

      final round2 = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: startedAt,
        endsAt: endsAt,
        status: RoundStatus.active,
      );

      expect(round1, equals(round2));
      expect(round1.hashCode, equals(round2.hashCode));
    });

    test('different values are not equal', () {
      final startedAt = DateTime(2026);
      final endsAt = startedAt.add(const Duration(seconds: 60));

      final round1 = GameRoundEntity(
        roundIndex: 1,
        landmark: landmark,
        startedAt: startedAt,
        endsAt: endsAt,
        status: RoundStatus.active,
      );

      final round2 = GameRoundEntity(
        roundIndex: 2,
        landmark: landmark,
        startedAt: startedAt,
        endsAt: endsAt,
        status: RoundStatus.active,
      );

      expect(round1, isNot(equals(round2)));
    });
  });
}
