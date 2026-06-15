// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/exceptions.dart';

// Features imports:
import '/features/party/data/models/party_settings_model.dart';
import '/features/party/data/models/player_model.dart';
import '/features/party/domain/entities/party_entity.dart';

class PartyModel extends Equatable {
  const PartyModel({
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
  final PartySettingsModel settings;
  final List<PlayerModel> players;
  final int currentRound;
  final DateTime createdAt;

  factory PartyModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) throw const ServerException(message: 'Party not found.');
    final data = doc.data()!;
    final rawPlayers = data['players'] as Map<String, dynamic>? ?? {};
    return PartyModel(
      partyCode: data['partyCode'] as String,
      hostId: data['hostId'] as String,
      hostName: data['hostName'] as String,
      partyName: data['partyName'] as String,
      status: PartyStatus.values.byName(data['status'] as String),
      settings: PartySettingsModel.fromJson(
        data['settings'] as Map<String, dynamic>,
      ),
      currentRound: data['currentRound'] as int,
      players: rawPlayers.values
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList(growable: false),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    ...toJson(),
    'players': {for (final p in players) p.uid: p.toJson()}, // Override
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      partyCode: json['partyCode'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      partyName: json['partyName'] as String,
      status: PartyStatus.values.byName(json['status'] as String),
      settings: PartySettingsModel.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      players: (json['players'] as List<dynamic>)
          .map((player) => PlayerModel.fromJson(player as Map<String, dynamic>))
          .toList(),
      currentRound: json['currentRound'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partyCode': partyCode,
      'hostId': hostId,
      'hostName': hostName,
      'partyName': partyName,
      'status': status.name,
      'settings': settings.toJson(),
      'players': players.map((player) => player.toJson()).toList(),
      'currentRound': currentRound,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PartyModel.fromEntity(PartyEntity entity) {
    return PartyModel(
      partyCode: entity.partyCode,
      hostId: entity.hostId,
      hostName: entity.hostName,
      partyName: entity.partyName,
      status: entity.status,
      settings: PartySettingsModel.fromEntity(entity.settings),
      players: entity.players
          .map(PlayerModel.fromEntity)
          .toList(growable: false),
      currentRound: entity.currentRound,
      createdAt: entity.createdAt,
    );
  }

  PartyEntity toEntity() {
    return PartyEntity(
      partyCode: partyCode,
      hostId: hostId,
      hostName: hostName,
      partyName: partyName,
      status: status,
      settings: settings.toEntity(),
      players: players
          .map((player) => player.toEntity())
          .toList(growable: false),
      currentRound: currentRound,
      createdAt: createdAt,
    );
  }

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
