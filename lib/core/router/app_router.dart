// Package imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';
import '/core/router/go_router_refresh_stream.dart';
import '/core/router/routes/main_routes.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,

    // Re-evaluate redirect on every AuthBloc state change.
    refreshListenable: GoRouterRefreshStream(
      ServiceLocator.get<AuthBloc>().stream,
    ),

    redirect: _authGuard,

    routes: [...MainRoutes.routes],
  );

  /// Centralized auth guard — evaluated before any route renders.
  static String? _authGuard(BuildContext context, GoRouterState state) {
    final authState = ServiceLocator.get<AuthBloc>().state;

    // Waiting for the stream to emit the first value.
    if (authState is AuthInitial || authState is AuthLoading) {
      return AppRoutes.splash;
    }

    final isAuthenticated = authState is AuthAuthenticated;
    final isOnPublicRoute = AppRoutes.publicRoutes.contains(
      state.matchedLocation,
    );
    final isOnSplash = state.matchedLocation == AppRoutes.splash;

    // Unauthenticated users should only be able to access public routes
    // (excluding splash).
    if (!isAuthenticated) {
      if (isOnSplash || !isOnPublicRoute) {
        return AppRoutes.login;
      }
    } else {
      // Authenticated users should not be on public routes or splash screen.
      if (isOnSplash || isOnPublicRoute) {
        return AppRoutes.home;
      }
    }

    return null; // No redirect needed.
  }

  static GoRouter get router => _router;
}
