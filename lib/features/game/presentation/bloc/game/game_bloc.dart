// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/entities/game_session_entity.dart';
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/entities/player_answer_entity.dart';
import '/features/game/domain/usecases/end_game_usecase.dart';
import '/features/game/domain/usecases/end_round_usecase.dart';
import '/features/game/domain/usecases/initialize_game_session_usecase.dart';
import '/features/game/domain/usecases/start_round_usecase.dart';
import '/features/game/domain/usecases/submit_answer_usecase.dart';
import '/features/game/domain/usecases/watch_game_session_usecase.dart';

// Part imports:
part 'game_event.dart';
part 'game_state.dart';

/// Drives the in-game screen for both the host and regular players.
///
/// The host dispatches [InitializeGameEvent], [StartRoundEvent],
/// [EndRoundEvent], and [EndGameEvent]; every player (host included)
/// dispatches [SubmitAnswerEvent]. All state transitions ultimately come
/// from the [WatchGameSessionUseCase] stream, since Firestore is the single
/// source of truth — host actions just write to it, they never optimistically
/// mutate local state.
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required this._initializeGameSession,
    required this._startRound,
    required this._endRound,
    required this._endGame,
    required this._submitAnswer,
    required this._watchGameSession,
  }) : super(const GameState()) {
    on<InitializeGameEvent>(_onInitializeGame, transformer: droppable());
    on<JoinGameEvent>(_onJoinGame, transformer: droppable());
    on<ReconnectGameEvent>(_onReconnect, transformer: droppable());
    on<StartRoundEvent>(_onStartRound, transformer: droppable());
    on<EndRoundEvent>(_onEndRound, transformer: droppable());
    on<EndGameEvent>(_onEndGame, transformer: droppable());
    on<SubmitAnswerEvent>(_onSubmitAnswer, transformer: droppable());
    on<WatchGameSessionInternalEvent>(
      _onWatchGameSession,
      transformer: restartable(),
    );
  }

  final InitializeGameSessionUseCase _initializeGameSession;
  final StartRoundUseCase _startRound;
  final EndRoundUseCase _endRound;
  final EndGameUseCase _endGame;
  final SubmitAnswerUseCase _submitAnswer;
  final WatchGameSessionUseCase _watchGameSession;

  // ── Session lifecycle ─────────────────────────────────────────────────────

  Future<void> _onInitializeGame(
    InitializeGameEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GameBlocStatus.loading,
        clearSession: true,
        clearActionError: true,
      ),
    );

    final result = await _initializeGameSession(
      InitializeGameSessionParams(
        partyCode: event.partyCode,
        hostId: event.hostId,
        totalRounds: event.totalRounds,
        initialPlayerScores: event.initialPlayerScores,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GameBlocStatus.initial,
          actionError: failure.message,
        ),
      ),
      (_) => add(WatchGameSessionInternalEvent(partyCode: event.partyCode)),
    );
  }

  Future<void> _onJoinGame(JoinGameEvent event, Emitter<GameState> emit) async {
    emit(
      state.copyWith(
        status: GameBlocStatus.loading,
        clearSession: true,
        clearActionError: true,
      ),
    );
    add(WatchGameSessionInternalEvent(partyCode: event.partyCode));
  }

  Future<void> _onReconnect(
    ReconnectGameEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(
      state.copyWith(status: GameBlocStatus.loading, clearActionError: true),
    );
    add(WatchGameSessionInternalEvent(partyCode: event.partyCode));
  }

  Future<void> _onWatchGameSession(
    WatchGameSessionInternalEvent event,
    Emitter<GameState> emit,
  ) async {
    await emit.forEach<GameSessionEntity>(
      _watchGameSession(SingleParam(event.partyCode)),
      onData: (session) => state.copyWith(
        status: session.status == GameSessionStatus.finished
            ? GameBlocStatus.finished
            : GameBlocStatus.connected,
        session: session,
        clearActionError: true,
      ),
      onError: (_, _) => state.copyWith(
        status: GameBlocStatus.disconnected,
        actionError: 'Lost connection to the game session.',
      ),
    );
  }

  // ── Host actions ───────────────────────────────────────────────────────────

  Future<void> _onStartRound(
    StartRoundEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearActionError: true));

    final result = await _startRound(
      StartRoundParams(
        partyCode: event.partyCode,
        hostId: event.hostId,
        roundIndex: event.roundIndex,
        landmark: event.landmark,
        durationSeconds: event.durationSeconds,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, actionError: failure.message),
      ),
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }

  Future<void> _onEndRound(EndRoundEvent event, Emitter<GameState> emit) async {
    // Cumulative scores must come from the session we're currently watching;
    // ending a round before that snapshot has arrived would silently zero
    // out everyone's prior points.
    final currentScores = state.session?.playerScores;
    if (currentScores == null) {
      emit(
        state.copyWith(
          actionError: 'Cannot end a round before a session is loaded.',
        ),
      );
      return;
    }

    emit(state.copyWith(isActionLoading: true, clearActionError: true));

    final result = await _endRound(
      EndRoundParams(
        partyCode: event.partyCode,
        hostId: event.hostId,
        roundIndex: event.roundIndex,
        landmark: event.landmark,
        currentPlayerScores: currentScores,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, actionError: failure.message),
      ),
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }

  Future<void> _onEndGame(EndGameEvent event, Emitter<GameState> emit) async {
    emit(state.copyWith(isActionLoading: true, clearActionError: true));

    final result = await _endGame(
      EndGameParams(partyCode: event.partyCode, hostId: event.hostId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, actionError: failure.message),
      ),
      // Don't force status -> finished here: the session stream will push
      // the authoritative "finished" snapshot, keeping a single source of
      // truth for every connected client (including the host).
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }

  // ── Player actions ─────────────────────────────────────────────────────────

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearActionError: true));

    final result = await _submitAnswer(
      SubmitAnswerParams(
        partyCode: event.partyCode,
        playerId: event.playerId,
        playerName: event.playerName,
        photoUrl: event.photoUrl,
        roundIndex: event.roundIndex,
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, actionError: failure.message),
      ),
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }
}
