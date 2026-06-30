part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

// ── Session lifecycle ─────────────────────────────────────────────────────

/// Host only. Creates the session document, then starts watching it.
class InitializeGameEvent extends GameEvent {
  const InitializeGameEvent({
    required this.partyCode,
    required this.hostId,
    required this.totalRounds,
    required this.initialPlayerScores,
  });

  final String partyCode;
  final String hostId;
  final int totalRounds;
  final Map<String, int> initialPlayerScores;

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    totalRounds,
    initialPlayerScores,
  ];
}

/// Non-host players dispatch this when they land on the game screen, so the
/// bloc starts listening to the session the host already created.
class JoinGameEvent extends GameEvent {
  const JoinGameEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

/// Re-attaches the session stream after a [GameBlocStatus.disconnected]
/// state, e.g. after the device regains connectivity.
class ReconnectGameEvent extends GameEvent {
  const ReconnectGameEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

/// Internal event used to (re)subscribe to [WatchGameSessionUseCase].
/// Private so the UI cannot dispatch it directly — use [InitializeGameEvent],
/// [JoinGameEvent], or [ReconnectGameEvent] instead.
class WatchGameSessionInternalEvent extends GameEvent {
  const WatchGameSessionInternalEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

// ── Host actions ───────────────────────────────────────────────────────────

class StartRoundEvent extends GameEvent {
  const StartRoundEvent({
    required this.partyCode,
    required this.hostId,
    required this.roundIndex,
    required this.landmark,
    required this.durationSeconds,
  });

  final String partyCode;
  final String hostId;
  final int roundIndex;
  final LandmarkEntity landmark;
  final int durationSeconds;

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    roundIndex,
    landmark,
    durationSeconds,
  ];
}

/// Scores the round (against the answers already submitted) and persists
/// the results + updated cumulative scores.
class EndRoundEvent extends GameEvent {
  const EndRoundEvent({
    required this.partyCode,
    required this.hostId,
    required this.roundIndex,
    required this.landmark,
  });

  final String partyCode;
  final String hostId;
  final int roundIndex;
  final LandmarkEntity landmark;

  @override
  List<Object?> get props => [partyCode, hostId, roundIndex, landmark];
}

class EndGameEvent extends GameEvent {
  const EndGameEvent({required this.partyCode, required this.hostId});

  final String partyCode;
  final String hostId;

  @override
  List<Object?> get props => [partyCode, hostId];
}

// ── Player actions ─────────────────────────────────────────────────────────

class SubmitAnswerEvent extends GameEvent {
  const SubmitAnswerEvent({
    required this.partyCode,
    required this.playerId,
    required this.playerName,
    this.photoUrl,
    required this.roundIndex,
    required this.latitude,
    required this.longitude,
  });

  final String partyCode;
  final String playerId;
  final String playerName;
  final String? photoUrl;
  final int roundIndex;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [
    partyCode,
    playerId,
    roundIndex,
    latitude,
    longitude,
  ];
}
