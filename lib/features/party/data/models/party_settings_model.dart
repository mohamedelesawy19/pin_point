// Package imports:
import 'package:equatable/equatable.dart';

// Features imports:
import '/features/party/domain/entities/party_settings.dart';

class PartySettingsModel extends Equatable {
  const PartySettingsModel({
    required this.roundDurationSeconds,
    required this.totalRounds,
  });

  final int roundDurationSeconds;
  final int totalRounds;

  factory PartySettingsModel.fromJson(Map<String, dynamic> json) {
    return PartySettingsModel(
      roundDurationSeconds: json['roundDurationSeconds'] as int,
      totalRounds: json['totalRounds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundDurationSeconds': roundDurationSeconds,
      'totalRounds': totalRounds,
    };
  }

  factory PartySettingsModel.fromEntity(PartySettings entity) {
    return PartySettingsModel(
      roundDurationSeconds: entity.roundDurationSeconds,
      totalRounds: entity.totalRounds,
    );
  }

  PartySettings toEntity() {
    return PartySettings(
      roundDurationSeconds: roundDurationSeconds,
      totalRounds: totalRounds,
    );
  }

  @override
  List<Object?> get props => [roundDurationSeconds, totalRounds];
}
