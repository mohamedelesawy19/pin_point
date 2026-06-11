import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/party/domain/entities/player_entity.dart';

void main() {
  group('PlayerEntity', () {
    test('supports value equality', () {
      expect(
        const PlayerEntity(
          uid: '123',
          isAnonymous: false,
          score: 0,
          displayName: 'Mohamed',
          photoUrl: 'photo.jpg',
        ),
        equals(
          const PlayerEntity(
            uid: '123',
            isAnonymous: false,
            score: 0,
            displayName: 'Mohamed',
            photoUrl: 'photo.jpg',
          ),
        ),
      );
    });

    test('props are correct', () {
      const player = PlayerEntity(
        uid: '123',
        isAnonymous: false,
        score: 0,
        displayName: 'Mohamed',
        photoUrl: 'photo.jpg',
      );

      expect(player.props, ['123', 'Mohamed', 0]);
    });
  });
}
