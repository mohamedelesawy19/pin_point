import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('supports value equality', () {
      expect(
        const UserEntity(
          uid: '123',
          email: 'test@example.com',
          displayName: 'Mohamed',
          photoUrl: 'photo.jpg',
          isAnonymous: false,
        ),
        equals(
          const UserEntity(
            uid: '123',
            email: 'test@example.com',
            displayName: 'Mohamed',
            photoUrl: 'photo.jpg',
            isAnonymous: false,
          ),
        ),
      );
    });

    test('props are correct', () {
      const user = UserEntity(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Mohamed',
        photoUrl: 'photo.jpg',
        isAnonymous: false,
      );

      expect(user.props, [
        '123',
        'test@example.com',
        'Mohamed',
        'photo.jpg',
        false,
      ]);
    });
  });
}
