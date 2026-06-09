// Package imports:
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/auth/presentation/screens/login_screen.dart';
import '/features/main/presentation/screens/main_screen.dart';
import '/features/splash/presentation/screens/splash_screen.dart';

class MainRoutes {
  const MainRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: AppRoutes.main, builder: (_, _) => const MainScreen()),
  ];
}
