import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/di/injection_container.dart';
import 'package:pin_point/core/di/service_locator.dart';

void main() {
  tearDown(() async {
    await InjectionContainer.reset();
  });

  group('InjectionContainer', () {
    test('init registers dependencies', () async {
      await InjectionContainer.init();

      expect(InjectionContainer.isInitialized, isTrue);
    });

    test('calling init twice does not throw', () async {
      await InjectionContainer.init();
      await InjectionContainer.init();

      expect(InjectionContainer.isInitialized, isTrue);
    });

    test('reset clears dependencies', () async {
      await InjectionContainer.init();

      await InjectionContainer.reset();

      expect(InjectionContainer.isInitialized, isFalse);
    });

    test('reinit initializes again', () async {
      await InjectionContainer.init();

      await InjectionContainer.reinit();

      expect(InjectionContainer.isInitialized, isTrue);
    });

    test('createScope creates scope', () async {
      InjectionContainer.createScope('auth');

      expect(ServiceLocator.currentScopeName, 'auth');

      expect(ServiceLocator.hasScope('auth'), isTrue);
    });

    test('destroyScope removes scope', () async {
      InjectionContainer.createScope('auth');

      await InjectionContainer.destroyScope();

      expect(ServiceLocator.hasScope('auth'), isFalse);
    });
  });
}
