import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_point/core/constants/firestore_constants.dart';
import 'package:pin_point/core/errors/exceptions.dart';
import 'package:pin_point/features/game/data/datasources/game_remote_datasource.dart';
import 'package:pin_point/features/game/data/models/game_session_model.dart';
import 'package:pin_point/features/game/data/models/landmark_model.dart';
import 'package:pin_point/features/game/data/models/player_answer_model.dart';
import 'package:pin_point/features/game/domain/entities/game_round_entity.dart';
import 'package:pin_point/features/game/domain/entities/game_session_entity.dart';

// ── Test fixtures ────────────────────────────────────────────────────────────

const _kPartyCode = 'ABC123';
const _kHostId = 'host-uid-001';
const _kPlayerId = 'player-uid-007';
const _kPlayerName = 'Alice';
const _kTotalRounds = 3;

const _landmark = LandmarkModel(
  id: 'lm-001',
  name: 'Eiffel Tower',
  imageUrl: 'https://example.com/eiffel.jpg',
  actualLatitude: 48.8584,
  actualLongitude: 2.2945,
  country: 'France',
  city: 'Paris',
);

final _processedAnswer = PlayerAnswerModel(
  playerId: _kPlayerId,
  playerName: _kPlayerName,
  roundIndex: 0,
  latitude: 48.85,
  longitude: 2.30,
  distanceKm: 1.2,
  score: 50,
  submittedAt: DateTime.utc(2024, 6, 1, 12),
);

Map<String, int> get _initialScores => {_kPlayerId: 0};

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Seeds a minimal game session document into [firestore].
Future<void> _seedSession(
  FakeFirebaseFirestore firestore, {
  GameStatus status = GameStatus.initializing,
}) async {
  final data = GameSessionModel(
    partyCode: _kPartyCode,
    hostId: _kHostId,
    status: status,
    currentRoundIndex: 0,
    totalRounds: _kTotalRounds,
    playerScores: _initialScores,
  ).toJson();

  await firestore
      .collection(FirestoreConstants.gameSessionsCollection)
      .doc(_kPartyCode)
      .set(data);
}

/// Seeds [count] landmark documents into [firestore].
Future<void> _seedLandmarks(FakeFirebaseFirestore firestore, int count) async {
  for (var i = 0; i < count; i++) {
    await firestore
        .collection(FirestoreConstants.landmarksCollection)
        .doc('lm-$i')
        .set({
          'name': 'Landmark $i',
          'imageUrl': 'https://example.com/$i.jpg',
          'actualLatitude': 48.0 + i,
          'actualLongitude': 2.0 + i,
          'country': 'Country $i',
          'city': 'City $i',
        });
  }
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GameRemoteDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = GameRemoteDataSourceImpl(firestore: fakeFirestore);
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('initializeGameSession', () {
    test('creates a session document with correct initial values', () async {
      await dataSource.initializeGameSession(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        totalRounds: _kTotalRounds,
        initialPlayerScores: _initialScores,
      );

      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .get();

      expect(snap.exists, isTrue);
      final data = snap.data()!;
      expect(data['partyCode'], equals(_kPartyCode));
      expect(data['hostId'], equals(_kHostId));
      expect(data['status'], equals(GameStatus.initializing.name));
      expect(data['currentRoundIndex'], equals(0));
      expect(data['totalRounds'], equals(_kTotalRounds));
      expect(data['playerScores'], equals(_initialScores));
      expect(data['currentRound'], isNull);
      expect(data['roundResults'], isNull);
    });

    test('overwrites an existing session document (idempotent)', () async {
      await _seedSession(fakeFirestore, status: GameStatus.finished);

      await dataSource.initializeGameSession(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        totalRounds: _kTotalRounds,
        initialPlayerScores: _initialScores,
      );

      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .get();

      expect(snap.data()!['status'], equals(GameStatus.initializing.name));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('startRound', () {
    setUp(() async => _seedSession(fakeFirestore));

    test(
      'transitions status to inProgress and populates currentRound',
      () async {
        await dataSource.startRound(
          partyCode: _kPartyCode,
          hostId: _kHostId,
          roundIndex: 0,
          landmark: _landmark,
          durationSeconds: 60,
        );

        final snap = await fakeFirestore
            .collection(FirestoreConstants.gameSessionsCollection)
            .doc(_kPartyCode)
            .get();
        final data = snap.data()!;

        expect(data['status'], equals(GameStatus.roundActive.name));
        expect(data['currentRoundIndex'], equals(0));
        expect(data['roundResults'], isNull);

        final round = data['currentRound'] as Map<String, dynamic>;
        expect(round['roundIndex'], equals(0));
        expect(round['status'], equals(RoundStatus.active.name));

        final landmark = round['landmark'] as Map<String, dynamic>;
        expect(landmark['name'], equals(_landmark.name));
      },
    );

    test('endsAt is approximately durationSeconds after startedAt', () async {
      const duration = 90;
      final before = DateTime.now().toUtc();

      await dataSource.startRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: 0,
        landmark: _landmark,
        durationSeconds: duration,
      );

      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .get();
      final round = snap.data()!['currentRound'] as Map<String, dynamic>;

      final startedAt = (round['startedAt'] as Timestamp).toDate();
      final endsAt = (round['endsAt'] as Timestamp).toDate();

      expect(endsAt.difference(startedAt).inSeconds, equals(duration));
      expect(
        startedAt.isAfter(before.subtract(const Duration(seconds: 2))),
        isTrue,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('endRound', () {
    setUp(() async {
      await _seedSession(fakeFirestore, status: GameStatus.roundActive);

      // Manually start a round so currentRound is populated.
      await dataSource.startRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: 0,
        landmark: _landmark,
        durationSeconds: 60,
      );
    });

    test(
      'writes processed answers, updates scores, and closes the round',
      () async {
        const updatedScores = {_kPlayerId: 50};

        await dataSource.endRound(
          partyCode: _kPartyCode,
          hostId: _kHostId,
          roundIndex: 0,
          processedAnswers: [_processedAnswer],
          updatedPlayerScores: updatedScores,
        );

        final snap = await fakeFirestore
            .collection(FirestoreConstants.gameSessionsCollection)
            .doc(_kPartyCode)
            .get();
        final data = snap.data()!;

        expect(data['playerScores'], equals(updatedScores));

        final results = data['roundResults'] as List<dynamic>;
        expect(results, hasLength(1));

        final answer = results.first as Map<String, dynamic>;
        expect(answer['playerId'], equals(_kPlayerId));
        expect(answer['score'], equals(50));
        expect(answer['distanceKm'], equals(1.2));

        final round = data['currentRound'] as Map<String, dynamic>;
        expect(round['status'], equals(RoundStatus.results.name));
      },
    );

    test('handles multiple processed answers correctly', () async {
      final secondAnswer = PlayerAnswerModel(
        playerId: 'player-uid-008',
        playerName: 'Bob',
        roundIndex: 0,
        latitude: 40.0,
        longitude: 3.0,
        distanceKm: 950.0,
        score: 1,
        submittedAt: DateTime.utc(2024, 6, 1, 12),
      );

      await dataSource.endRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: 0,
        processedAnswers: [_processedAnswer, secondAnswer],
        updatedPlayerScores: {_kPlayerId: 50, 'player-uid-008': 1},
      );

      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .get();
      final results = snap.data()!['roundResults'] as List<dynamic>;

      expect(results, hasLength(2));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('endGame', () {
    setUp(
      () async => _seedSession(fakeFirestore, status: GameStatus.roundActive),
    );

    test('transitions session status to finished', () async {
      await dataSource.endGame(partyCode: _kPartyCode, hostId: _kHostId);

      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .get();

      expect(snap.data()!['status'], equals(GameStatus.finished.name));
    });

    test('does not modify other fields', () async {
      await dataSource.endGame(partyCode: _kPartyCode, hostId: _kHostId);

      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .get();
      final data = snap.data()!;

      expect(data['hostId'], equals(_kHostId));
      expect(data['totalRounds'], equals(_kTotalRounds));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('submitAnswer', () {
    const roundIndex = 0;

    test('creates an answer document with composite key', () async {
      await dataSource.submitAnswer(
        partyCode: _kPartyCode,
        playerId: _kPlayerId,
        playerName: _kPlayerName,
        roundIndex: roundIndex,
        latitude: 48.85,
        longitude: 2.30,
      );

      const docId = '${roundIndex}_$_kPlayerId';
      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .collection(FirestoreConstants.answersCollection)
          .doc(docId)
          .get();

      expect(snap.exists, isTrue);
      final data = snap.data()!;
      expect(data['playerId'], equals(_kPlayerId));
      expect(data['playerName'], equals(_kPlayerName));
      expect(data['latitude'], equals(48.85));
      expect(data['longitude'], equals(2.30));
      expect(data['distanceKm'], equals(0.0));
      expect(data['score'], equals(0));
      expect(data['photoUrl'], isNull);
    });

    test('includes photoUrl when provided', () async {
      const photo = 'https://example.com/alice.jpg';

      await dataSource.submitAnswer(
        partyCode: _kPartyCode,
        playerId: _kPlayerId,
        playerName: _kPlayerName,
        photoUrl: photo,
        roundIndex: roundIndex,
        latitude: 48.85,
        longitude: 2.30,
      );

      const docId = '${roundIndex}_$_kPlayerId';
      final snap = await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .collection(FirestoreConstants.answersCollection)
          .doc(docId)
          .get();

      expect(snap.data()!['photoUrl'], equals(photo));
    });

    test(
      'second submission overwrites the first (one answer per player)',
      () async {
        await dataSource.submitAnswer(
          partyCode: _kPartyCode,
          playerId: _kPlayerId,
          playerName: _kPlayerName,
          roundIndex: roundIndex,
          latitude: 10.0,
          longitude: 20.0,
        );

        await dataSource.submitAnswer(
          partyCode: _kPartyCode,
          playerId: _kPlayerId,
          playerName: _kPlayerName,
          roundIndex: roundIndex,
          latitude: 48.85,
          longitude: 2.30,
        );

        final allAnswers = await fakeFirestore
            .collection(FirestoreConstants.gameSessionsCollection)
            .doc(_kPartyCode)
            .collection(FirestoreConstants.answersCollection)
            .get();

        expect(allAnswers.docs, hasLength(1));
        expect(allAnswers.docs.first.data()['latitude'], equals(48.85));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('watchGameSession', () {
    test('emits a GameSessionModel when the document exists', () async {
      await _seedSession(fakeFirestore);

      expect(
        dataSource.watchGameSession(_kPartyCode),
        emits(
          isA<GameSessionModel>()
              .having((s) => s.partyCode, 'partyCode', _kPartyCode)
              .having((s) => s.hostId, 'hostId', _kHostId)
              .having((s) => s.status, 'status', GameStatus.initializing),
        ),
      );
    });

    test('emits updated models on document changes', () async {
      await _seedSession(fakeFirestore);

      final stream = dataSource.watchGameSession(_kPartyCode);

      // First emission: initializing
      // Then update the document and expect a second emission.
      await expectLater(
        stream,
        emitsInOrder([
          isA<GameSessionModel>().having(
            (s) => s.status,
            'status',
            GameStatus.initializing,
          ),
        ]),
      );

      await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .update({'status': GameStatus.roundActive.name});

      await expectLater(
        dataSource.watchGameSession(_kPartyCode),
        emits(
          isA<GameSessionModel>().having(
            (s) => s.status,
            'status',
            GameStatus.roundActive,
          ),
        ),
      );
    });

    test(
      'emits a ServerException error when the document does not exist',
      () async {
        expect(
          dataSource.watchGameSession('NON_EXISTENT'),
          emitsError(isA<ServerException>()),
        );
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('getRoundAnswers', () {
    Future<void> seedAnswers() async {
      for (final playerId in ['p1', 'p2', 'p3']) {
        await fakeFirestore
            .collection(FirestoreConstants.gameSessionsCollection)
            .doc(_kPartyCode)
            .collection(FirestoreConstants.answersCollection)
            .doc('0_$playerId')
            .set({
              'playerId': playerId,
              'playerName': playerId,
              'roundIndex': 0,
              'latitude': 48.0,
              'longitude': 2.0,
              'distanceKm': 0.0,
              'score': 0,
              'submittedAt': Timestamp.fromDate(DateTime.utc(2024, 6)),
            });
      }
      // Add one answer for round 1 to verify isolation.
      await fakeFirestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(_kPartyCode)
          .collection(FirestoreConstants.answersCollection)
          .doc('1_p1')
          .set({
            'playerId': 'p1',
            'playerName': 'p1',
            'roundIndex': 1,
            'latitude': 48.0,
            'longitude': 2.0,
            'distanceKm': 0.0,
            'score': 0,
            'submittedAt': Timestamp.fromDate(DateTime.utc(2024, 6)),
          });
    }

    test('returns only answers for the requested round', () async {
      await seedAnswers();

      final answers = await dataSource.getRoundAnswers(
        partyCode: _kPartyCode,
        roundIndex: 0,
      );

      expect(answers, hasLength(3));
      expect(answers.every((a) => a.roundIndex == 0), isTrue);
    });

    test('returns an empty list when no answers exist for the round', () async {
      final answers = await dataSource.getRoundAnswers(
        partyCode: _kPartyCode,
        roundIndex: 99,
      );

      expect(answers, isEmpty);
    });

    test('maps documents to valid PlayerAnswerModel instances', () async {
      await seedAnswers();

      final answers = await dataSource.getRoundAnswers(
        partyCode: _kPartyCode,
        roundIndex: 0,
      );

      for (final answer in answers) {
        expect(answer, isA<PlayerAnswerModel>());
        expect(answer.latitude, isNotNull);
        expect(answer.submittedAt, isA<DateTime>());
      }
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('getLandmarks', () {
    test(
      'returns exactly [count] landmarks when the collection is large enough',
      () async {
        await _seedLandmarks(fakeFirestore, 20);

        final landmarks = await dataSource.getLandmarks();

        expect(landmarks, hasLength(5));
      },
    );

    test(
      'returns all available landmarks when fewer than [count] exist',
      () async {
        await _seedLandmarks(fakeFirestore, 3);

        final landmarks = await dataSource.getLandmarks();

        expect(landmarks, hasLength(3));
      },
    );

    test('maps documents to valid LandmarkModel instances', () async {
      await _seedLandmarks(fakeFirestore, 5);

      final landmarks = await dataSource.getLandmarks(count: 3);

      for (final lm in landmarks) {
        expect(lm, isA<LandmarkModel>());
        expect(lm.id, isNotEmpty);
        expect(lm.name, isNotEmpty);
        expect(lm.imageUrl, startsWith('https://'));
      }
    });

    test('injects document ID as the landmark id field', () async {
      await _seedLandmarks(fakeFirestore, 5);

      final landmarks = await dataSource.getLandmarks();

      // All IDs should match their Firestore document IDs (lm-0 … lm-4).
      for (final lm in landmarks) {
        expect(lm.id, matches(RegExp(r'^lm-\d+$')));
      }
    });

    test(
      'throws ServerException when the landmarks collection is empty',
      () async {
        expect(
          () => dataSource.getLandmarks(),
          throwsA(
            isA<ServerException>().having((e) => e.code, 'code', 'not-found'),
          ),
        );
      },
    );
  });
}
