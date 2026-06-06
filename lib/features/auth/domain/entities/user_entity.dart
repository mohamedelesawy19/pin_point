import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isAnonymous];
}
