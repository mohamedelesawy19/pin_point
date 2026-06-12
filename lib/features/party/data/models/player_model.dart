// Package imports:
import 'package:equatable/equatable.dart';

// Features imports:
import '/features/party/domain/entities/player_entity.dart';

class PlayerModel extends Equatable {
  const PlayerModel({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.isAnonymous,
    required this.score,
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final int score;

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      isAnonymous: json['isAnonymous'] as bool,
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
      'score': score,
    };
  }

  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      uid: entity.uid,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      isAnonymous: entity.isAnonymous,
      score: entity.score,
    );
  }

  PlayerEntity toEntity() {
    return PlayerEntity(
      uid: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      isAnonymous: isAnonymous,
      score: score,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, photoUrl, isAnonymous, score];
}
