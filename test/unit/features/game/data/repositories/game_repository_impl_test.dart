import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/exceptions.dart';
import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/game/data/datasources/game_remote_datasource.dart';
import 'package:pin_point/features/game/data/models/game_session_model.dart';
import 'package:pin_point/features/game/data/models/landmark_model.dart';
import 'package:pin_point/features/game/data/models/player_answer_model.dart';
import 'package:pin_point/features/game/data/repositories/game_repository_impl.dart';
import 'package:pin_point/features/game/domain/entities/game_session_entity.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/entities/player_answer_entity.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockGameRemoteDataSource extends Mock implements GameRemoteDataSource {}

class FakeLandmarkModel extends Fake implements LandmarkModel {}

// ── Test fixtures ────────────────────────────────────────────────────────────

const _kPartyCode = 'ABC123';
const _kHostId = 'host-uid-001';
const _kPlayerId = 'player-uid-007';
const _kPlayerName = 'Alice';
const _kRoundIndex = 0;
const _kTotalRounds = 3;
const _kDurationSeconds = 60;

const _kServerException = ServerException(message: 'Firestore unavailable');

const _landmarkEntity = LandmarkEntity(
  id: 'lm-001',
  name: 'Eiffel Tower',
  imageUrl: 'https://example.com/eiffel.jpg',
  actualLatitude: 48.8584,
  actualLongitude: 2.2945,
  country: 'France',
  city: 'Paris',
);

final _landmarkModel = LandmarkModel.fromEntity(_landmarkEntity);

final _playerAnswerEntity = PlayerAnswerEntity(
  playerId: _kPlayerId,
  playerName: _kPlayerName,
  roundIndex: _kRoundIndex,
  latitude: 48.85,
  longitude: 2.30,
  distanceKm: 1.2,
  score: 50,
  submittedAt: DateTime.utc(2024, 6, 1, 12),
);

final _playerAnswerModel = PlayerAnswerModel.fromEntity(_playerAnswerEntity);

const _gameSessionModel = GameSessionModel(
  partyCode: _kPartyCode,
  hostId: _kHostId,
  status: GameStatus.initializing,
  currentRoundIndex: 0,
  totalRounds: _kTotalRounds,
  playerScores: {_kPlayerId: 0},
);

Map<String, int> get _initialScores => {_kPlayerId: 0};
Map<String, int> get _updatedScores => {_kPlayerId: 50};

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLandmarkModel());
  });

  late MockGameRemoteDataSource mockDataSource;
  late GameRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockGameRemoteDataSource();
    repository = GameRepositoryImpl(remoteDataSource: mockDataSource);
  });

  // ── initializeGameSession ──────────────────────────────────────────────────
  group('initializeGameSession', () {
    void arrange() {
      when(
        () => mockDataSource.initializeGameSession(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          totalRounds: any(named: 'totalRounds'),
          initialPlayerScores: any(named: 'initialPlayerScores'),
        ),
      ).thenAnswer((_) async {});
    }

    test('returns Right(unit) on success', () async {
      arrange();

      final result = await repository.initializeGameSession(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        totalRounds: _kTotalRounds,
        initialPlayerScores: _initialScores,
      );

      expect(result, equals(const Right(unit)));
    });

    test('delegates to the data source with correct parameters', () async {
      arrange();

      await repository.initializeGameSession(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        totalRounds: _kTotalRounds,
        initialPlayerScores: _initialScores,
      );

      verify(
        () => mockDataSource.initializeGameSession(
          partyCode: _kPartyCode,
          hostId: _kHostId,
          totalRounds: _kTotalRounds,
          initialPlayerScores: _initialScores,
        ),
      ).called(1);
    });

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.initializeGameSession(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          totalRounds: any(named: 'totalRounds'),
          initialPlayerScores: any(named: 'initialPlayerScores'),
        ),
      ).thenThrow(_kServerException);

      final result = await repository.initializeGameSession(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        totalRounds: _kTotalRounds,
        initialPlayerScores: _initialScores,
      );

      expect(result, isA<Left<Failure, Unit>>());
      final failure = (result as Left).value as ServerFailure;
      expect(failure.message, equals(_kServerException.message));
    });
  });

  // ── startRound ─────────────────────────────────────────────────────────────
  group('startRound', () {
    void arrange() {
      when(
        () => mockDataSource.startRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          landmark: any(named: 'landmark'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async {});
    }

    test('returns Right(unit) on success', () async {
      arrange();

      final result = await repository.startRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: _kRoundIndex,
        landmark: _landmarkEntity,
        durationSeconds: _kDurationSeconds,
      );

      expect(result, equals(const Right(unit)));
    });

    test(
      'converts LandmarkEntity to LandmarkModel before delegating',
      () async {
        arrange();

        await repository.startRound(
          partyCode: _kPartyCode,
          hostId: _kHostId,
          roundIndex: _kRoundIndex,
          landmark: _landmarkEntity,
          durationSeconds: _kDurationSeconds,
        );

        verify(
          () => mockDataSource.startRound(
            partyCode: _kPartyCode,
            hostId: _kHostId,
            roundIndex: _kRoundIndex,
            landmark: _landmarkModel,
            durationSeconds: _kDurationSeconds,
          ),
        ).called(1);
      },
    );

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.startRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          landmark: any(named: 'landmark'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenThrow(_kServerException);

      final result = await repository.startRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: _kRoundIndex,
        landmark: _landmarkEntity,
        durationSeconds: _kDurationSeconds,
      );

      expect(result, isA<Left<Failure, Unit>>());
    });
  });

  // ── endRound ───────────────────────────────────────────────────────────────
  group('endRound', () {
    void arrange() {
      when(
        () => mockDataSource.endRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          processedAnswers: any(named: 'processedAnswers'),
          updatedPlayerScores: any(named: 'updatedPlayerScores'),
        ),
      ).thenAnswer((_) async {});
    }

    test('returns Right(unit) on success', () async {
      arrange();

      final result = await repository.endRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: _kRoundIndex,
        processedAnswers: [_playerAnswerEntity],
        updatedPlayerScores: _updatedScores,
      );

      expect(result, equals(const Right(unit)));
    });

    test(
      'converts PlayerAnswerEntity list to PlayerAnswerModel list',
      () async {
        arrange();

        await repository.endRound(
          partyCode: _kPartyCode,
          hostId: _kHostId,
          roundIndex: _kRoundIndex,
          processedAnswers: [_playerAnswerEntity],
          updatedPlayerScores: _updatedScores,
        );

        verify(
          () => mockDataSource.endRound(
            partyCode: _kPartyCode,
            hostId: _kHostId,
            roundIndex: _kRoundIndex,
            processedAnswers: [_playerAnswerModel],
            updatedPlayerScores: _updatedScores,
          ),
        ).called(1);
      },
    );

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.endRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          processedAnswers: any(named: 'processedAnswers'),
          updatedPlayerScores: any(named: 'updatedPlayerScores'),
        ),
      ).thenThrow(_kServerException);

      final result = await repository.endRound(
        partyCode: _kPartyCode,
        hostId: _kHostId,
        roundIndex: _kRoundIndex,
        processedAnswers: [_playerAnswerEntity],
        updatedPlayerScores: _updatedScores,
      );

      expect(result, isA<Left<Failure, Unit>>());
    });
  });

  // ── endGame ────────────────────────────────────────────────────────────────
  group('endGame', () {
    test('returns Right(unit) on success', () async {
      when(
        () => mockDataSource.endGame(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.endGame(
        partyCode: _kPartyCode,
        hostId: _kHostId,
      );

      expect(result, equals(const Right(unit)));
    });

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.endGame(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
        ),
      ).thenThrow(_kServerException);

      final result = await repository.endGame(
        partyCode: _kPartyCode,
        hostId: _kHostId,
      );

      expect(result, isA<Left<Failure, Unit>>());
      final failure = (result as Left).value as ServerFailure;
      expect(failure.message, equals(_kServerException.message));
    });
  });

  // ── submitAnswer ───────────────────────────────────────────────────────────
  group('submitAnswer', () {
    void arrangeSuccess() {
      when(
        () => mockDataSource.submitAnswer(
          partyCode: any(named: 'partyCode'),
          playerId: any(named: 'playerId'),
          playerName: any(named: 'playerName'),
          photoUrl: any(named: 'photoUrl'),
          roundIndex: any(named: 'roundIndex'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async {});
    }

    test('returns Right(unit) on success', () async {
      arrangeSuccess();

      final result = await repository.submitAnswer(
        partyCode: _kPartyCode,
        playerId: _kPlayerId,
        playerName: _kPlayerName,
        roundIndex: _kRoundIndex,
        latitude: 48.85,
        longitude: 2.30,
      );

      expect(result, equals(const Right(unit)));
    });

    test('forwards optional photoUrl to the data source', () async {
      arrangeSuccess();

      const photo = 'https://example.com/alice.jpg';
      await repository.submitAnswer(
        partyCode: _kPartyCode,
        playerId: _kPlayerId,
        playerName: _kPlayerName,
        photoUrl: photo,
        roundIndex: _kRoundIndex,
        latitude: 48.85,
        longitude: 2.30,
      );

      verify(
        () => mockDataSource.submitAnswer(
          partyCode: _kPartyCode,
          playerId: _kPlayerId,
          playerName: _kPlayerName,
          photoUrl: photo,
          roundIndex: _kRoundIndex,
          latitude: 48.85,
          longitude: 2.30,
        ),
      ).called(1);
    });

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.submitAnswer(
          partyCode: any(named: 'partyCode'),
          playerId: any(named: 'playerId'),
          playerName: any(named: 'playerName'),
          photoUrl: any(named: 'photoUrl'),
          roundIndex: any(named: 'roundIndex'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(_kServerException);

      final result = await repository.submitAnswer(
        partyCode: _kPartyCode,
        playerId: _kPlayerId,
        playerName: _kPlayerName,
        roundIndex: _kRoundIndex,
        latitude: 48.85,
        longitude: 2.30,
      );

      expect(result, isA<Left<Failure, Unit>>());
    });
  });

  // ── watchGameSession ───────────────────────────────────────────────────────
  group('watchGameSession', () {
    test('maps GameSessionModel to GameSessionEntity', () async {
      when(
        () => mockDataSource.watchGameSession(_kPartyCode),
      ).thenAnswer((_) => Stream.value(_gameSessionModel));

      expect(
        repository.watchGameSession(_kPartyCode),
        emits(
          isA<Object>()
          // Verify the entity has the same partyCode as the source model.
          .having((e) => (e as dynamic).partyCode, 'partyCode', _kPartyCode),
        ),
      );
    });
  });

  // ── getRoundAnswers ────────────────────────────────────────────────────────
  group('getRoundAnswers', () {
    test('returns Right with mapped entity list on success', () async {
      when(
        () => mockDataSource.getRoundAnswers(
          partyCode: any(named: 'partyCode'),
          roundIndex: any(named: 'roundIndex'),
        ),
      ).thenAnswer((_) async => [_playerAnswerModel]);

      final result = await repository.getRoundAnswers(
        partyCode: _kPartyCode,
        roundIndex: _kRoundIndex,
      );

      expect(result.isRight(), isTrue);
      final entities = result.getOrElse(() => []);
      expect(entities, hasLength(1));
      expect(entities.first, isA<PlayerAnswerEntity>());
      expect(entities.first.playerId, equals(_kPlayerId));
    });

    test('returns Right with an empty list when no answers exist', () async {
      when(
        () => mockDataSource.getRoundAnswers(
          partyCode: any(named: 'partyCode'),
          roundIndex: any(named: 'roundIndex'),
        ),
      ).thenAnswer((_) async => []);

      final result = await repository.getRoundAnswers(
        partyCode: _kPartyCode,
        roundIndex: _kRoundIndex,
      );

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.getRoundAnswers(
          partyCode: any(named: 'partyCode'),
          roundIndex: any(named: 'roundIndex'),
        ),
      ).thenThrow(_kServerException);

      final result = await repository.getRoundAnswers(
        partyCode: _kPartyCode,
        roundIndex: _kRoundIndex,
      );

      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<ServerFailure>());
    });
  });

  // ── getLandmarks ───────────────────────────────────────────────────────────
  group('getLandmarks', () {
    test('returns Right with mapped entity list on success', () async {
      when(
        () => mockDataSource.getLandmarks(count: any(named: 'count')),
      ).thenAnswer((_) async => [_landmarkModel]);

      final result = await repository.getLandmarks(count: 1);

      expect(result.isRight(), isTrue);
      final entities = result.getOrElse(() => []);
      expect(entities, hasLength(1));
      expect(entities.first, isA<LandmarkEntity>());
      expect(entities.first.name, equals(_landmarkEntity.name));
    });

    test('forwards [count] to the data source', () async {
      when(
        () => mockDataSource.getLandmarks(count: any(named: 'count')),
      ).thenAnswer((_) async => []);

      await repository.getLandmarks(count: 7);

      verify(() => mockDataSource.getLandmarks(count: 7)).called(1);
    });

    test('uses default count of 5 when not specified', () async {
      when(
        () => mockDataSource.getLandmarks(count: any(named: 'count')),
      ).thenAnswer((_) async => []);

      await repository.getLandmarks();

      verify(() => mockDataSource.getLandmarks()).called(1);
    });

    test('returns Left(ServerFailure) when data source throws', () async {
      when(
        () => mockDataSource.getLandmarks(count: any(named: 'count')),
      ).thenThrow(_kServerException);

      final result = await repository.getLandmarks();

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value as ServerFailure;
      expect(failure.message, equals(_kServerException.message));
    });
  });
}
