// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_delegate.dart';
import '/core/router/app_router.dart';
import '/core/theme/app_theme.dart';

void main() {
  runApp(const PinPoint());
}

class PinPoint extends StatelessWidget {
  const PinPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PinPoint',

      // Localization configuration
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      locale: LocalizationConfig.getDeviceLocale(),

      // Theme configuration
      theme: AppTheme.theme,

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
