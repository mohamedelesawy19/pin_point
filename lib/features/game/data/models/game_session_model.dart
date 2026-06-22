// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/game/data/models/game_round_model.dart';
import '/features/game/data/models/player_answer_model.dart';
import '/features/game/domain/entities/game_session_entity.dart';

class GameSessionModel extends Equatable {
  const GameSessionModel({
    required this.partyCode,
    required this.hostId,
    required this.status,
    required this.currentRoundIndex,
    required this.totalRounds,
    required this.playerScores,
    this.currentRound,
    this.roundResults,
  });

  final String partyCode;
  final String hostId;
  final GameStatus status;
  final int currentRoundIndex;
  final int totalRounds;
  final Map<String, int> playerScores;
  final GameRoundModel? currentRound;
  final List<PlayerAnswerModel>? roundResults;

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      partyCode: json['partyCode'] as String,
      hostId: json['hostId'] as String,
      status: GameStatus.values.byName(json['status'] as String),
      currentRoundIndex: json['currentRoundIndex'] as int,
      totalRounds: json['totalRounds'] as int,
      playerScores: Map<String, int>.from(json['playerScores'] as Map),
      currentRound: json['currentRound'] != null
          ? GameRoundModel.fromJson(
              json['currentRound'] as Map<String, dynamic>,
            )
          : null,
      roundResults: (json['roundResults'] as List<dynamic>?)
          ?.map((e) => PlayerAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partyCode': partyCode,
      'hostId': hostId,
      'status': status.name,
      'currentRoundIndex': currentRoundIndex,
      'totalRounds': totalRounds,
      'playerScores': playerScores,
      'currentRound': currentRound?.toJson(),
      'roundResults': roundResults?.map((answer) => answer.toJson()).toList(),
    };
  }

  factory GameSessionModel.fromEntity(GameSessionEntity entity) {
    return GameSessionModel(
      partyCode: entity.partyCode,
      hostId: entity.hostId,
      status: entity.status,
      currentRoundIndex: entity.currentRoundIndex,
      totalRounds: entity.totalRounds,
      playerScores: Map<String, int>.from(entity.playerScores),
      currentRound: entity.currentRound != null
          ? GameRoundModel.fromEntity(entity.currentRound!)
          : null,
      roundResults: entity.roundResults
          ?.map(PlayerAnswerModel.fromEntity)
          .toList(),
    );
  }

  GameSessionEntity toEntity() {
    return GameSessionEntity(
      partyCode: partyCode,
      hostId: hostId,
      status: status,
      currentRoundIndex: currentRoundIndex,
      totalRounds: totalRounds,
      playerScores: Map<String, int>.from(playerScores),
      currentRound: currentRound?.toEntity(),
      roundResults: roundResults?.map((answer) => answer.toEntity()).toList(),
    );
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
    roundResults,
  ];
}
