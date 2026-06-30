import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/domain/entities/game_round_entity.dart';
import 'package:pin_point/features/game/domain/entities/game_session_entity.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/entities/player_answer_entity.dart';

void main() {
  group('GameSessionEntity', () {
    const landmark = LandmarkEntity(
      id: 'l1',
      name: 'Pyramids',
      actualLatitude: 29.9792,
      actualLongitude: 31.1342,
      imageUrl: 'https://example.com/pyramids.jpg',
    );

    final round = GameRoundEntity(
      roundIndex: 0,
      landmark: landmark,
      startedAt: DateTime(2026),
      endsAt: DateTime(2026, 1, 1, 0, 1),
      status: RoundStatus.active,
    );

    final answers = <PlayerAnswerEntity>[
      PlayerAnswerEntity(
        playerId: 'p1',
        playerName: 'Ahmed',
        roundIndex: 0,
        latitude: 10,
        longitude: 10,
        distanceKm: 5,
        score: 100,
        submittedAt: DateTime(2026),
      ),
      PlayerAnswerEntity(
        playerId: 'p2',
        playerName: 'Ali',
        roundIndex: 0,
        latitude: 20,
        longitude: 20,
        distanceKm: 10,
        score: 50,
        submittedAt: DateTime(2026),
      ),
    ];

    test('isLastRound returns true when last round reached', () {
      const session = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.roundInProgress,
        currentRoundIndex: 4,
        totalRounds: 5,
        playerScores: {},
      );

      expect(session.isLastRound, isTrue);
    });

    test('isLastRound returns false when not last round', () {
      const session = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.roundInProgress,
        currentRoundIndex: 2,
        totalRounds: 5,
        playerScores: {},
      );

      expect(session.isLastRound, isFalse);
    });

    test('leaderboard sorts scores descending', () {
      const session = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.finished,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: {'p1': 100, 'p2': 300, 'p3': 200},
      );

      final leaderboard = session.leaderboard;

      expect(leaderboard.first.key, 'p2');
      expect(leaderboard.first.value, 300);

      expect(leaderboard[1].key, 'p3');
      expect(leaderboard[2].key, 'p1');
    });

    test('answerForPlayer returns correct answer', () {
      final session = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.roundEnded,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: const {},
        lastRoundResults: answers,
      );

      final result = session.answerForPlayer('p2');

      expect(result, isNotNull);
      expect(result!.playerName, 'Ali');
      expect(result.score, 50);
    });

    test('answerForPlayer returns null if player not found', () {
      final session = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.roundEnded,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: const {},
        lastRoundResults: answers,
      );

      final result = session.answerForPlayer('unknown');

      expect(result, isNull);
    });

    test('answerForPlayer returns null when roundResults is null', () {
      const session = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.roundEnded,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: {},
      );

      final result = session.answerForPlayer('p1');

      expect(result, isNull);
    });

    test('supports value equality', () {
      final session1 = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.waitingToStart,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: const {'p1': 10},
        currentRound: round,
        lastRoundResults: answers,
      );

      final session2 = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.waitingToStart,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: const {'p1': 10},
        currentRound: round,
        lastRoundResults: answers,
      );

      expect(session1, equals(session2));
    });

    test('different sessions are not equal', () {
      const session1 = GameSessionEntity(
        partyCode: 'ABC',
        hostId: 'host1',
        status: GameSessionStatus.waitingToStart,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: {'p1': 10},
      );

      const session2 = GameSessionEntity(
        partyCode: 'XYZ',
        hostId: 'host1',
        status: GameSessionStatus.waitingToStart,
        currentRoundIndex: 0,
        totalRounds: 3,
        playerScores: {'p1': 10},
      );

      expect(session1, isNot(equals(session2)));
    });
  });
}
