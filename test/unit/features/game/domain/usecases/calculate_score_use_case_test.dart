import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/game/domain/usecases/calculate_score_usecase.dart';

void main() {
  late CalculateScoreUseCase useCase;

  setUp(() {
    useCase = const CalculateScoreUseCase();
  });

  group('CalculateScoreUseCase', () {
    test('should return 50 points when distance is less than 10 km', () {
      expect(useCase(0), 50);
      expect(useCase(5), 50);
      expect(useCase(9.99), 50);
    });

    test(
      'should return 30 points when distance is between 10 and 99.99 km',
      () {
        expect(useCase(10), 30);
        expect(useCase(50), 30);
        expect(useCase(99.99), 30);
      },
    );

    test(
      'should return 10 points when distance is between 100 and 499.99 km',
      () {
        expect(useCase(100), 10);
        expect(useCase(250), 10);
        expect(useCase(499.99), 10);
      },
    );

    test('should return 1 point when distance is 500 km or more', () {
      expect(useCase(500), 1);
      expect(useCase(1000), 1);
      expect(useCase(5000), 1);
    });

    test('should handle boundary values correctly', () {
      expect(useCase(9.999), 50);
      expect(useCase(10), 30);

      expect(useCase(99.999), 30);
      expect(useCase(100), 10);

      expect(useCase(499.999), 10);
      expect(useCase(500), 1);
    });
  });
}
