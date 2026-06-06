import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/features/auth/data/models/user_model.dart';

class MockFirebaseUser extends Mock implements fb.User {}

void main() {
  late MockFirebaseUser firebaseUser;

  setUp(() {
    firebaseUser = MockFirebaseUser();

    when(() => firebaseUser.uid).thenReturn('123');
    when(() => firebaseUser.email).thenReturn('test@example.com');
    when(() => firebaseUser.displayName).thenReturn('Mohamed');
    when(
      () => firebaseUser.photoURL,
    ).thenReturn('https://example.com/photo.jpg');
    when(() => firebaseUser.isAnonymous).thenReturn(false);
  });

  group('UserModel', () {
    test('fromFirebaseUser should create UserModel correctly', () {
      final result = UserModel.fromFirebaseUser(firebaseUser);

      expect(result.uid, '123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Mohamed');
      expect(result.photoUrl, 'https://example.com/photo.jpg');
      expect(result.isAnonymous, false);
    });

    test('toJson should return correct map', () {
      const model = UserModel(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Mohamed',
        photoUrl: 'https://example.com/photo.jpg',
        isAnonymous: false,
      );

      expect(model.toJson(), {
        'uid': '123',
        'email': 'test@example.com',
        'displayName': 'Mohamed',
        'photoUrl': 'https://example.com/photo.jpg',
        'isAnonymous': false,
      });
    });

    test('toJson should handle nullable fields', () {
      const model = UserModel(uid: '123', isAnonymous: true);

      expect(model.toJson(), {
        'uid': '123',
        'email': null,
        'displayName': null,
        'photoUrl': null,
        'isAnonymous': true,
      });
    });
  });
}
