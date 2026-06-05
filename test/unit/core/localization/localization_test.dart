import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/core/localization/localization_delegate.dart';

void main() {
  group('AppLocalizationDelegate', () {
    const delegate = AppLocalizationDelegate();

    test('should support english locale', () {
      expect(delegate.isSupported(const Locale('en')), isTrue);
    });

    test('should support arabic locale', () {
      expect(delegate.isSupported(const Locale('ar')), isTrue);
    });

    test('should not support unsupported locale', () {
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test('should never reload delegate', () {
      expect(delegate.shouldReload(const AppLocalizationDelegate()), isFalse);
    });
  });

  group('LocalizationConfig.supportedLocales', () {
    test('should contain english locale', () {
      expect(LocalizationConfig.supportedLocales, contains(const Locale('en')));
    });

    test('should contain arabic locale', () {
      expect(LocalizationConfig.supportedLocales, contains(const Locale('ar')));
    });

    test('should contain exactly two locales', () {
      expect(LocalizationConfig.supportedLocales.length, 2);
    });
  });

  group('LocalizationConfig.isRTL', () {
    test('should return true for arabic locale', () {
      expect(LocalizationConfig.isRTL(const Locale('ar')), isTrue);
    });

    test('should return false for english locale', () {
      expect(LocalizationConfig.isRTL(const Locale('en')), isFalse);
    });

    test('should return false for unsupported locale', () {
      expect(LocalizationConfig.isRTL(const Locale('fr')), isFalse);
    });
  });

  group('LocalizationConfig.getTextDirection', () {
    test('should return rtl for arabic locale', () {
      expect(
        LocalizationConfig.getTextDirection(const Locale('ar')),
        TextDirection.rtl,
      );
    });

    test('should return ltr for english locale', () {
      expect(
        LocalizationConfig.getTextDirection(const Locale('en')),
        TextDirection.ltr,
      );
    });

    test('should return ltr for unsupported locale', () {
      expect(
        LocalizationConfig.getTextDirection(const Locale('fr')),
        TextDirection.ltr,
      );
    });
  });

  group('LocalizationConfig.localizationsDelegates', () {
    test('should not be empty', () {
      expect(LocalizationConfig.localizationsDelegates, isNotEmpty);
    });

    test('should contain app localization delegate', () {
      expect(
        LocalizationConfig.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
    });
  });
}
