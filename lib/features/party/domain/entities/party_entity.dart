// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/party/domain/entities/player_entity.dart';

class PartyEntity extends Equatable {
  const PartyEntity({
    required this.partyCode,
    required this.hostId,
    required this.hostName,
    required this.partyName,
    required this.status,
    required this.settings,
    required this.players,
    required this.currentRound,
    required this.createdAt,
  });

  final String partyCode;
  final String hostId;
  final String hostName;
  final String partyName;
  final PartyStatus status;
  final PartySettings settings;
  final List<PlayerEntity> players;
  final int currentRound;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    partyCode,
    hostId,
    hostName,
    partyName,
    status,
    settings,
    players,
    currentRound,
    createdAt,
  ];
}

enum PartyStatus { waiting, playing, finished }

class PartySettings extends Equatable {
  const PartySettings({
    required this.roundDurationSeconds,
    required this.totalRounds,
  });

  final int roundDurationSeconds; // 30 or 60
  final int totalRounds;

  @override
  List<Object?> get props => [roundDurationSeconds, totalRounds];
}
