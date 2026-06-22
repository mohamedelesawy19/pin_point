import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/domain/usecases/calculate_distance_usecase.dart';

void main() {
  late CalculateDistanceUseCase useCase;

  setUp(() {
    useCase = const CalculateDistanceUseCase();
  });

  group('CalculateDistanceUseCase', () {
    test('should return 0 when coordinates are identical', () {
      final result = useCase(
        lat1: 30.0444,
        lon1: 31.2357,
        lat2: 30.0444,
        lon2: 31.2357,
      );

      expect(result, 0);
    });

    test('should calculate known distance between Cairo and Alexandria', () {
      final result = useCase(
        lat1: 30.0444,
        lon1: 31.2357,
        lat2: 31.2001,
        lon2: 29.9187,
      );

      expect(result, closeTo(180, 5));
    });

    test('should return positive distance for different coordinates', () {
      final result = useCase(
        lat1: 30.0444,
        lon1: 31.2357,
        lat2: 31.2001,
        lon2: 29.9187,
      );

      expect(result, greaterThan(0));
    });

    test('should return same distance regardless of direction', () {
      final distanceAB = useCase(
        lat1: 30.0444,
        lon1: 31.2357,
        lat2: 31.2001,
        lon2: 29.9187,
      );

      final distanceBA = useCase(
        lat1: 31.2001,
        lon1: 29.9187,
        lat2: 30.0444,
        lon2: 31.2357,
      );

      expect(distanceAB, closeTo(distanceBA, 0.0001));
    });
  });
}
