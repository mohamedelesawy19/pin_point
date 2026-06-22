// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/auth/domain/entities/user_entity.dart';

class PlayerEntity extends Equatable {
  const PlayerEntity({
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

  factory PlayerEntity.fromUser(UserEntity user, {int score = 0}) {
    // displayName should always be present for Google sign-in users
    // If somehow null, use email domain or fallback to 'Anonymous'
    final displayName =
        user.displayName ?? (user.email?.split('@').first ?? 'Anonymous');

    return PlayerEntity(
      uid: user.uid,
      displayName: displayName,
      photoUrl: user.photoUrl,
      isAnonymous: user.isAnonymous,
      score: score,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, score, photoUrl, isAnonymous];
}
