import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/di/service_locator.dart';

class TestService {
  TestService(this.value);
  final String value;
}

void main() {
  setUp(() async {
    await ServiceLocator.reset();
  });

  tearDown(() async {
    await ServiceLocator.reset();
  });

  group('ServiceLocator', () {
    test('registerSingleton and get', () {
      final service = TestService('singleton');

      ServiceLocator.registerSingleton<TestService>(service);

      final result = ServiceLocator.get<TestService>();

      expect(result, same(service));
    });

    test('registerLazySingleton', () {
      ServiceLocator.registerLazySingleton<TestService>(
        () => TestService('lazy'),
      );

      final first = ServiceLocator.get<TestService>();
      final second = ServiceLocator.get<TestService>();

      expect(first.value, 'lazy');
      expect(identical(first, second), isTrue);
    });

    test('registerFactory creates new instance each time', () {
      ServiceLocator.registerFactory<TestService>(() => TestService('factory'));

      final first = ServiceLocator.get<TestService>();
      final second = ServiceLocator.get<TestService>();

      expect(first.value, 'factory');
      expect(second.value, 'factory');
      expect(identical(first, second), isFalse);
    });

    test('registerFactoryParam', () {
      ServiceLocator.registerFactoryParam<TestService, String, void>(
        (param, _) => TestService(param),
      );

      final service = ServiceLocator.get<TestService>(param1: 'dynamic-value');

      expect(service.value, 'dynamic-value');
    });

    test('isRegistered returns true when service exists', () {
      ServiceLocator.registerSingleton<TestService>(TestService('registered'));

      expect(ServiceLocator.isRegistered<TestService>(), isTrue);
    });

    test('isRegistered returns false when service does not exist', () {
      expect(ServiceLocator.isRegistered<TestService>(), isFalse);
    });

    test('getOrNull returns service when registered', () {
      final service = TestService('exists');

      ServiceLocator.registerSingleton<TestService>(service);

      expect(ServiceLocator.getOrNull<TestService>(), same(service));
    });

    test('getOrNull returns null when not registered', () {
      expect(ServiceLocator.getOrNull<TestService>(), isNull);
    });

    test('unregister removes service', () async {
      ServiceLocator.registerSingleton<TestService>(TestService('remove'));

      await ServiceLocator.unregister<TestService>();

      expect(ServiceLocator.isRegistered<TestService>(), isFalse);
    });

    test('pushNewScope and popScope', () async {
      ServiceLocator.pushNewScope(scopeName: 'test_scope');

      expect(ServiceLocator.currentScopeName, 'test_scope');

      expect(ServiceLocator.hasScope('test_scope'), isTrue);

      await ServiceLocator.popScope();

      expect(ServiceLocator.hasScope('test_scope'), isFalse);
    });

    test('registerSingletonAsync and allReady', () async {
      ServiceLocator.registerSingletonAsync<TestService>(
        () async => TestService('async'),
      );

      await ServiceLocator.allReady();

      final service = ServiceLocator.get<TestService>();

      expect(service.value, 'async');
    });
  });
}
