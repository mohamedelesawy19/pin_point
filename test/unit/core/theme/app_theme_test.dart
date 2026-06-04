import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/theme/app_colors.dart';
import 'package:pin_point/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    final theme = AppTheme.theme;

    test('should use app typography', () {
      expect(theme.textTheme.displayLarge?.fontSize, 57);
      expect(theme.textTheme.headlineLarge?.fontSize, 32);
      expect(theme.textTheme.bodyMedium?.fontSize, 14);
      expect(theme.textTheme.labelSmall?.fontSize, 11);
    });

    test('should use app colors', () {
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.tertiary, AppColors.tertiary);
    });
  });
}
