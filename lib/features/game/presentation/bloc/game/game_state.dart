part of 'game_bloc.dart';

enum GameBlocStatus {
  /// No session has been initialized or joined yet.
  initial,

  /// Initializing/joining/reconnecting — waiting for the first snapshot.
  loading,

  /// Receiving live updates from [WatchGameSessionUseCase].
  connected,

  /// The session stream errored out (e.g. lost connectivity). The last known
  /// [GameState.session] is preserved so the UI can keep showing it.
  disconnected,

  /// The host has called [EndGameEvent] and the session is over.
  finished,
}

class GameState extends Equatable {
  const GameState({
    this.status = GameBlocStatus.initial,
    this.session,
    this.actionError,
    this.isActionLoading = false,
  });

  final GameBlocStatus status;
  final GameSessionEntity? session;

  /// Surfaces a failure from a one-off action (start round, submit answer,
  /// end round...) without tearing down the live session connection.
  final String? actionError;

  /// True while a host/player action use case is in flight. Distinct from
  /// [status] == loading, which only applies to the initial connection.
  final bool isActionLoading;

  bool get isConnected => status == GameBlocStatus.connected;
  bool get isDisconnected => status == GameBlocStatus.disconnected;
  bool get isFinished => status == GameBlocStatus.finished;

  GameSessionStatus? get sessionStatus => session?.status;
  int get currentRoundIndex => session?.currentRoundIndex ?? 0;
  int get totalRounds => session?.totalRounds ?? 0;
  Map<String, int> get playerScores => session?.playerScores ?? const {};
  List<PlayerAnswerEntity> get lastRoundResults =>
      session?.lastRoundResults ?? const [];

  GameState copyWith({
    GameBlocStatus? status,
    GameSessionEntity? session,
    bool clearSession = false,
    String? actionError, // pass null to clear via [clearActionError]
    bool clearActionError = false,
    bool? isActionLoading,
  }) {
    return GameState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [status, session, actionError, isActionLoading];
}
