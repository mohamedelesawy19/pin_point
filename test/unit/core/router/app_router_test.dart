import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/router/app_router.dart';
import 'package:pin_point/core/router/app_routes.dart';

void main() {
  group('AppRouter', () {
    test('should return a GoRouter instance', () {
      expect(AppRouter.router, isNotNull);
    });

    test('should have correct initial location', () {
      expect(AppRouter.router.configuration.routes.isNotEmpty, isTrue);

      expect(AppRoutes.initial, '/');
    });
  });
}
