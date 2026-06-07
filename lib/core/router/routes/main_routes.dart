// Package imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';
import '/core/widgets/screens/splash_screen.dart';

// Feature imports:
import '/features/auth/presentation/screens/login_screen.dart';

class MainRoutes {
  const MainRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: AppRoutes.home,
      builder: (_, _) => const Scaffold(
        body: Center(child: Text('Home Screen - Authenticated')),
      ),
    ),
  ];
}
