import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/party/data/models/player_model.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';

void main() {
  group('PlayerModel', () {
    const model = PlayerModel(
      uid: 'u1',
      displayName: 'Mohamed',
      photoUrl: 'http://photo.url',
      isAnonymous: false,
      score: 10,
    );

    const entity = PlayerEntity(
      uid: 'u1',
      displayName: 'Mohamed',
      photoUrl: 'http://photo.url',
      isAnonymous: false,
      score: 10,
    );

    test('supports value equality', () {
      expect(
        model,
        const PlayerModel(
          uid: 'u1',
          displayName: 'Mohamed',
          photoUrl: 'http://photo.url',
          isAnonymous: false,
          score: 10,
        ),
      );
    });

    test('fromJson should return valid model', () {
      // Arrange
      final json = <String, dynamic>{
        'uid': 'u1',
        'displayName': 'Mohamed',
        'photoUrl': 'http://photo.url',
        'isAnonymous': false,
        'score': 10,
      };

      // Act
      final result = PlayerModel.fromJson(json);

      // Assert
      expect(result, model);
    });

    test('toJson should return valid map', () {
      // Act
      final result = model.toJson();

      // Assert
      expect(result, <String, dynamic>{
        'uid': 'u1',
        'displayName': 'Mohamed',
        'photoUrl': 'http://photo.url',
        'isAnonymous': false,
        'score': 10,
      });
    });

    test('fromEntity should map entity to model correctly', () {
      // Act
      final result = PlayerModel.fromEntity(entity);

      // Assert
      expect(result, model);
    });

    test('toEntity should map model to entity correctly', () {
      // Act
      final result = model.toEntity();

      // Assert
      expect(result, entity);
    });
  });
}
