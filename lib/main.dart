// Package imports:
import 'package:flutter/material.dart';

// Core imports:
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
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
