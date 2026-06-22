import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';

void main() {
  group('LandmarkEntity', () {
    test('locationLabel returns "city, country" when both exist', () {
      const landmark = LandmarkEntity(
        id: '1',
        name: 'Pyramids',
        imageUrl: 'url',
        actualLatitude: 29.9,
        actualLongitude: 31.1,
        city: 'Giza',
        country: 'Egypt',
      );

      expect(landmark.locationLabel, 'Giza, Egypt');
    });

    test('locationLabel returns country only when city is null', () {
      const landmark = LandmarkEntity(
        id: '1',
        name: 'Pyramids',
        imageUrl: 'url',
        actualLatitude: 29.9,
        actualLongitude: 31.1,
        country: 'Egypt',
      );

      expect(landmark.locationLabel, 'Egypt');
    });

    test('locationLabel returns empty string when both null', () {
      const landmark = LandmarkEntity(
        id: '1',
        name: 'Unknown',
        imageUrl: 'url',
        actualLatitude: 0,
        actualLongitude: 0,
      );

      expect(landmark.locationLabel, '');
    });

    test('supports value equality', () {
      const l1 = LandmarkEntity(
        id: '1',
        name: 'Pyramids',
        imageUrl: 'url',
        actualLatitude: 29.9,
        actualLongitude: 31.1,
        city: 'Giza',
        country: 'Egypt',
      );

      const l2 = LandmarkEntity(
        id: '1',
        name: 'Pyramids',
        imageUrl: 'url',
        actualLatitude: 29.9,
        actualLongitude: 31.1,
        city: 'Giza',
        country: 'Egypt',
      );

      expect(l1, equals(l2));
      expect(l1.hashCode, equals(l2.hashCode));
    });

    test('different landmarks are not equal', () {
      const l1 = LandmarkEntity(
        id: '1',
        name: 'Pyramids',
        imageUrl: 'url',
        actualLatitude: 29.9,
        actualLongitude: 31.1,
        city: 'Giza',
        country: 'Egypt',
      );

      const l2 = LandmarkEntity(
        id: '2',
        name: 'Pyramids',
        imageUrl: 'url',
        actualLatitude: 29.9,
        actualLongitude: 31.1,
        city: 'Giza',
        country: 'Egypt',
      );

      expect(l1, isNot(equals(l2)));
    });
  });
}
