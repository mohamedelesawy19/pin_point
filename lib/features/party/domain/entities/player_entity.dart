import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [uid, displayName, score];
}
