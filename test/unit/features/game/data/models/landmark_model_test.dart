import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/data/models/landmark_model.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';

void main() {
  const tModel = LandmarkModel(
    id: '1',
    name: 'Eiffel Tower',
    imageUrl: 'image.jpg',
    actualLatitude: 48.8584,
    actualLongitude: 2.2945,
    country: 'France',
    city: 'Paris',
  );

  final tJson = {
    'id': '1',
    'name': 'Eiffel Tower',
    'imageUrl': 'image.jpg',
    'actualLatitude': 48.8584,
    'actualLongitude': 2.2945,
    'country': 'France',
    'city': 'Paris',
  };

  const tEntity = LandmarkEntity(
    id: '1',
    name: 'Eiffel Tower',
    imageUrl: 'image.jpg',
    actualLatitude: 48.8584,
    actualLongitude: 2.2945,
    country: 'France',
    city: 'Paris',
  );

  group('LandmarkModel', () {
    test('fromJson should return valid model', () {
      final result = LandmarkModel.fromJson(tJson);

      expect(result, tModel);
    });

    test('toJson should return valid json', () {
      final result = tModel.toJson();

      expect(result, tJson);
    });

    test('fromEntity should create model from entity', () {
      final result = LandmarkModel.fromEntity(tEntity);

      expect(result, tModel);
    });

    test('toEntity should return entity', () {
      final result = tModel.toEntity();

      expect(result, tEntity);
    });

    test('supports value equality', () {
      expect(tModel, equals(LandmarkModel.fromJson(tJson)));
    });
  });
}
