// Package imports:
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Features imports:
import '/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    required super.isAnonymous,
  });

  factory UserModel.fromFirebaseUser(fb.User user) => UserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    isAnonymous: user.isAnonymous,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isAnonymous': isAnonymous,
  };
}
