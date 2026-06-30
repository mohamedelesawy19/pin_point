import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';
import 'package:pin_point/features/game/domain/entities/game_session_entity.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/usecases/end_game_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/end_round_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/initialize_game_session_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/start_round_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/submit_answer_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/watch_game_session_usecase.dart';
import 'package:pin_point/features/game/presentation/bloc/game/game_bloc.dart';

class MockInitializeGameSessionUseCase extends Mock
    implements InitializeGameSessionUseCase {}

class MockStartRoundUseCase extends Mock implements StartRoundUseCase {}

class MockEndRoundUseCase extends Mock implements EndRoundUseCase {}

class MockEndGameUseCase extends Mock implements EndGameUseCase {}

class MockSubmitAnswerUseCase extends Mock implements SubmitAnswerUseCase {}

class MockWatchGameSessionUseCase extends Mock
    implements WatchGameSessionUseCase {}

class _ServerFailure extends Failure {
  const _ServerFailure(String message) : super(message: message, code: 'Error');
}

void main() {
  late MockInitializeGameSessionUseCase initializeGameSession;
  late MockStartRoundUseCase startRound;
  late MockEndRoundUseCase endRound;
  late MockEndGameUseCase endGame;
  late MockSubmitAnswerUseCase submitAnswer;
  late MockWatchGameSessionUseCase watchGameSession;

  const partyCode = 'ABCD';
  const hostId = 'host-1';
  const playerId = 'player-1';

  const landmark = LandmarkEntity(
    id: 'landmark-1',
    name: 'Eiffel Tower',
    imageUrl: 'https://example.com/eiffel.jpg',
    actualLatitude: 48.8584,
    actualLongitude: 2.2945,
  );

  GameSessionEntity sessionWith({
    GameSessionStatus status = GameSessionStatus.waitingToStart,
    int currentRoundIndex = 0,
    Map<String, int> playerScores = const {hostId: 0, playerId: 0},
  }) {
    return GameSessionEntity(
      partyCode: partyCode,
      hostId: hostId,
      status: status,
      currentRoundIndex: currentRoundIndex,
      totalRounds: 5,
      playerScores: playerScores,
    );
  }

  setUpAll(() {
    registerFallbackValue(
      const InitializeGameSessionParams(
        partyCode: partyCode,
        hostId: hostId,
        totalRounds: 5,
        initialPlayerScores: {},
      ),
    );
    registerFallbackValue(
      const StartRoundParams(
        partyCode: partyCode,
        hostId: hostId,
        roundIndex: 0,
        landmark: landmark,
        durationSeconds: 30,
      ),
    );
    registerFallbackValue(
      const EndRoundParams(
        partyCode: partyCode,
        hostId: hostId,
        roundIndex: 0,
        landmark: landmark,
        currentPlayerScores: {},
      ),
    );
    registerFallbackValue(
      const EndGameParams(partyCode: partyCode, hostId: hostId),
    );
    registerFallbackValue(
      const SubmitAnswerParams(
        partyCode: partyCode,
        playerId: playerId,
        playerName: 'Player One',
        roundIndex: 0,
        latitude: 0,
        longitude: 0,
      ),
    );
    registerFallbackValue(const SingleParam<String>(partyCode));
  });

  setUp(() {
    initializeGameSession = MockInitializeGameSessionUseCase();
    startRound = MockStartRoundUseCase();
    endRound = MockEndRoundUseCase();
    endGame = MockEndGameUseCase();
    submitAnswer = MockSubmitAnswerUseCase();
    watchGameSession = MockWatchGameSessionUseCase();
  });

  GameBloc buildBloc() => GameBloc(
    initializeGameSession: initializeGameSession,
    startRound: startRound,
    endRound: endRound,
    endGame: endGame,
    submitAnswer: submitAnswer,
    watchGameSession: watchGameSession,
  );

  group('InitializeGameEvent', () {
    blocTest<GameBloc, GameState>(
      'emits [loading, connected] when initialization succeeds and the '
      'session stream pushes a snapshot',
      setUp: () {
        when(
          () => initializeGameSession(any()),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => watchGameSession(any()),
        ).thenAnswer((_) => Stream.value(sessionWith()));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const InitializeGameEvent(
          partyCode: partyCode,
          hostId: hostId,
          totalRounds: 5,
          initialPlayerScores: {hostId: 0, playerId: 0},
        ),
      ),
      expect: () => [
        const GameState(status: GameBlocStatus.loading),
        GameState(status: GameBlocStatus.connected, session: sessionWith()),
      ],
      verify: (_) {
        verify(() => initializeGameSession(any())).called(1);
        verify(() => watchGameSession(any())).called(1);
      },
    );

    blocTest<GameBloc, GameState>(
      'emits [loading, initial+error] and never subscribes to the stream '
      'when initialization fails',
      setUp: () {
        when(() => initializeGameSession(any())).thenAnswer(
          (_) async => const Left(_ServerFailure('Could not create session')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const InitializeGameEvent(
          partyCode: partyCode,
          hostId: hostId,
          totalRounds: 5,
          initialPlayerScores: {hostId: 0},
        ),
      ),
      expect: () => [
        const GameState(status: GameBlocStatus.loading),
        const GameState(actionError: 'Could not create session'),
      ],
      verify: (_) {
        verifyNever(() => watchGameSession(any()));
      },
    );
  });

  group('JoinGameEvent', () {
    blocTest<GameBloc, GameState>(
      'emits [loading, connected] by subscribing directly to the session '
      'stream, without calling any host-only use case',
      setUp: () {
        when(
          () => watchGameSession(any()),
        ).thenAnswer((_) => Stream.value(sessionWith()));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const JoinGameEvent(partyCode: partyCode)),
      expect: () => [
        const GameState(status: GameBlocStatus.loading),
        GameState(status: GameBlocStatus.connected, session: sessionWith()),
      ],
      verify: (_) {
        verifyNever(() => initializeGameSession(any()));
      },
    );
  });

  group('session stream', () {
    blocTest<GameBloc, GameState>(
      'emits a connected state per snapshot, in order, as rounds progress',
      setUp: () {
        when(() => watchGameSession(any())).thenAnswer(
          (_) => Stream.fromIterable([
            sessionWith(),
            sessionWith(
              status: GameSessionStatus.roundInProgress,
              currentRoundIndex: 1,
            ),
          ]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const JoinGameEvent(partyCode: partyCode)),
      expect: () => [
        const GameState(status: GameBlocStatus.loading),
        GameState(status: GameBlocStatus.connected, session: sessionWith()),
        GameState(
          status: GameBlocStatus.connected,
          session: sessionWith(
            status: GameSessionStatus.roundInProgress,
            currentRoundIndex: 1,
          ),
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'maps a finished snapshot to GameBlocStatus.finished',
      setUp: () {
        when(() => watchGameSession(any())).thenAnswer(
          (_) => Stream.value(sessionWith(status: GameSessionStatus.finished)),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const JoinGameEvent(partyCode: partyCode)),
      expect: () => [
        const GameState(status: GameBlocStatus.loading),
        GameState(
          status: GameBlocStatus.finished,
          session: sessionWith(status: GameSessionStatus.finished),
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'emits disconnected, preserving the last known session, when the '
      'stream errors out',
      setUp: () {
        when(() => watchGameSession(any())).thenAnswer(
          (_) =>
              Stream<GameSessionEntity>.fromFutures([
                Future.value(sessionWith()),
              ]).asyncExpand(
                (session) => Stream<GameSessionEntity>.multi((controller) {
                  controller
                    ..add(session)
                    ..addError(Exception('connection dropped'));
                }),
              ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const JoinGameEvent(partyCode: partyCode)),
      expect: () => [
        const GameState(status: GameBlocStatus.loading),
        GameState(status: GameBlocStatus.connected, session: sessionWith()),
        GameState(
          status: GameBlocStatus.disconnected,
          session: sessionWith(),
          actionError: 'Lost connection to the game session.',
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'ReconnectGameEvent re-subscribes after a disconnect',
      setUp: () {
        when(
          () => watchGameSession(any()),
        ).thenAnswer((_) => Stream.value(sessionWith()));
      },
      build: buildBloc,
      seed: () => GameState(
        status: GameBlocStatus.disconnected,
        session: sessionWith(),
        actionError: 'Lost connection to the game session.',
      ),
      act: (bloc) => bloc.add(const ReconnectGameEvent(partyCode: partyCode)),
      expect: () => [
        GameState(status: GameBlocStatus.loading, session: sessionWith()),
        GameState(status: GameBlocStatus.connected, session: sessionWith()),
      ],
    );
  });

  group('StartRoundEvent', () {
    blocTest<GameBloc, GameState>(
      'emits [actionLoading, idle] when starting the round succeeds',
      setUp: () {
        when(
          () => startRound(any()),
        ).thenAnswer((_) async => const Right(unit));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const StartRoundEvent(
          partyCode: partyCode,
          hostId: hostId,
          roundIndex: 0,
          landmark: landmark,
          durationSeconds: 30,
        ),
      ),
      expect: () => [const GameState(isActionLoading: true), const GameState()],
    );

    blocTest<GameBloc, GameState>(
      'surfaces the failure message as actionError without touching the '
      'session stream',
      setUp: () {
        when(() => startRound(any())).thenAnswer(
          (_) async => const Left(_ServerFailure('Round already in progress')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const StartRoundEvent(
          partyCode: partyCode,
          hostId: hostId,
          roundIndex: 0,
          landmark: landmark,
          durationSeconds: 30,
        ),
      ),
      expect: () => [
        const GameState(isActionLoading: true),
        const GameState(actionError: 'Round already in progress'),
      ],
    );
  });

  group('EndRoundEvent', () {
    blocTest<GameBloc, GameState>(
      'emits an actionError and never calls the use case when no session '
      'has been loaded yet',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EndRoundEvent(
          partyCode: partyCode,
          hostId: hostId,
          roundIndex: 0,
          landmark: landmark,
        ),
      ),
      expect: () => [
        const GameState(
          actionError: 'Cannot end a round before a session is loaded.',
        ),
      ],
      verify: (_) => verifyNever(() => endRound(any())),
    );

    blocTest<GameBloc, GameState>(
      'uses the current session scores and emits [actionLoading, idle] on '
      'success',
      setUp: () {
        when(() => endRound(any())).thenAnswer((_) async => const Right(unit));
      },
      build: buildBloc,
      seed: () => GameState(
        status: GameBlocStatus.connected,
        session: sessionWith(
          status: GameSessionStatus.roundInProgress,
          playerScores: const {hostId: 100, playerId: 50},
        ),
      ),
      act: (bloc) => bloc.add(
        const EndRoundEvent(
          partyCode: partyCode,
          hostId: hostId,
          roundIndex: 0,
          landmark: landmark,
        ),
      ),
      expect: () => [
        GameState(
          status: GameBlocStatus.connected,
          session: sessionWith(
            status: GameSessionStatus.roundInProgress,
            playerScores: const {hostId: 100, playerId: 50},
          ),
          isActionLoading: true,
        ),
        GameState(
          status: GameBlocStatus.connected,
          session: sessionWith(
            status: GameSessionStatus.roundInProgress,
            playerScores: const {hostId: 100, playerId: 50},
          ),
        ),
      ],
      verify: (_) {
        final captured =
            verify(() => endRound(captureAny())).captured.single
                as EndRoundParams;
        expect(captured.currentPlayerScores, {hostId: 100, playerId: 50});
      },
    );

    blocTest<GameBloc, GameState>(
      'surfaces a failure without losing the existing session state',
      setUp: () {
        when(() => endRound(any())).thenAnswer(
          (_) async => const Left(_ServerFailure('Could not score round')),
        );
      },
      build: buildBloc,
      seed: () => GameState(
        status: GameBlocStatus.connected,
        session: sessionWith(status: GameSessionStatus.roundInProgress),
      ),
      act: (bloc) => bloc.add(
        const EndRoundEvent(
          partyCode: partyCode,
          hostId: hostId,
          roundIndex: 0,
          landmark: landmark,
        ),
      ),
      expect: () => [
        GameState(
          status: GameBlocStatus.connected,
          session: sessionWith(status: GameSessionStatus.roundInProgress),
          isActionLoading: true,
        ),
        GameState(
          status: GameBlocStatus.connected,
          session: sessionWith(status: GameSessionStatus.roundInProgress),
          actionError: 'Could not score round',
        ),
      ],
    );
  });

  group('EndGameEvent', () {
    blocTest<GameBloc, GameState>(
      'emits [actionLoading, idle] on success without forcing status to '
      'finished locally (the stream is the source of truth)',
      setUp: () {
        when(() => endGame(any())).thenAnswer((_) async => const Right(unit));
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const EndGameEvent(partyCode: partyCode, hostId: hostId)),
      expect: () => [const GameState(isActionLoading: true), const GameState()],
    );

    blocTest<GameBloc, GameState>(
      'surfaces a failure message on error',
      setUp: () {
        when(() => endGame(any())).thenAnswer(
          (_) async => const Left(_ServerFailure('Permission denied')),
        );
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const EndGameEvent(partyCode: partyCode, hostId: hostId)),
      expect: () => [
        const GameState(isActionLoading: true),
        const GameState(actionError: 'Permission denied'),
      ],
    );
  });

  group('SubmitAnswerEvent', () {
    blocTest<GameBloc, GameState>(
      'emits [actionLoading, idle] when the answer is accepted',
      setUp: () {
        when(
          () => submitAnswer(any()),
        ).thenAnswer((_) async => const Right(unit));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SubmitAnswerEvent(
          partyCode: partyCode,
          playerId: playerId,
          playerName: 'Player One',
          roundIndex: 0,
          latitude: 48.85,
          longitude: 2.29,
        ),
      ),
      expect: () => [const GameState(isActionLoading: true), const GameState()],
      verify: (_) => verify(() => submitAnswer(any())).called(1),
    );

    blocTest<GameBloc, GameState>(
      'surfaces a failure message when the answer is rejected (e.g. the '
      'round already ended)',
      setUp: () {
        when(() => submitAnswer(any())).thenAnswer(
          (_) async => const Left(_ServerFailure('Round has already ended')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SubmitAnswerEvent(
          partyCode: partyCode,
          playerId: playerId,
          playerName: 'Player One',
          roundIndex: 0,
          latitude: 48.85,
          longitude: 2.29,
        ),
      ),
      expect: () => [
        const GameState(isActionLoading: true),
        const GameState(actionError: 'Round has already ended'),
      ],
    );
  });
}
