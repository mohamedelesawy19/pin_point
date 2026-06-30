// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import 'game_round_entity.dart';
import 'player_answer_entity.dart';

enum GameSessionStatus { waitingToStart, roundInProgress, roundEnded, finished }

class GameSessionEntity extends Equatable {
  const GameSessionEntity({
    required this.partyCode,
    required this.hostId,
    required this.status,
    required this.currentRoundIndex,
    required this.totalRounds,
    required this.playerScores,
    this.currentRound,
    this.lastRoundResults,
  });

  final String partyCode;
  final String hostId;
  final GameSessionStatus status;

  /// 0-based index of the current or most recent round.
  final int currentRoundIndex;
  final int totalRounds;

  /// Cumulative scores keyed by player UID.
  final Map<String, int> playerScores;

  /// Present when status is roundInProgress or roundEnded.
  final GameRoundEntity? currentRound;

  /// Populated by the host at the end of each round.
  /// Contains processed answers with calculated distances and scores.
  final List<PlayerAnswerEntity>? lastRoundResults;

  bool get isLastRound => currentRoundIndex >= totalRounds - 1;

  /// Returns the answer for a specific player in the current round results.
  PlayerAnswerEntity? answerForPlayer(String uid) {
    return lastRoundResults?.where((a) => a.playerId == uid).firstOrNull;
  }

  /// Sorted leaderboard: highest score first.
  List<MapEntry<String, int>> get leaderboard {
    final entries = playerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    status,
    currentRoundIndex,
    totalRounds,
    playerScores,
    currentRound,
    lastRoundResults,
  ];
}
