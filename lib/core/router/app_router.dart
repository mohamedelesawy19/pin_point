// Package imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';
import '/core/router/go_router_refresh_stream.dart';
import '/core/router/routes/main_routes.dart';
import '/core/router/routes/party_routes.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/home/presentation/bloc/session_cubit.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,

    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(ServiceLocator.get<AuthBloc>().stream),
      GoRouterRefreshStream(ServiceLocator.get<SessionCubit>().stream),
    ]),

    redirect: _authGuard,

    routes: [...MainRoutes.routes, ...PartyRoutes.routes],
  );

  /// Centralized auth guard — evaluated before any route renders.
  static String? _authGuard(BuildContext context, GoRouterState state) {
    final authState = ServiceLocator.get<AuthBloc>().state;
    final sessionState = ServiceLocator.get<SessionCubit>().state;

    final loc = state.matchedLocation;

    // ── Splash: block until auth resolves; session only matters when signed in
    final authPending =
        authState is AuthInitial || authState is AuthLoading;
    final sessionPending = authState is AuthAuthenticated &&
        (sessionState is SessionInitial || sessionState is SessionChecking);

    if (authPending || sessionPending) {
      return AppRoutes.splash;
    }

    final isAuthenticated = authState is AuthAuthenticated;
    final isOnPublicRoute = AppRoutes.publicRoutes.contains(loc);
    final isOnSplash = loc == AppRoutes.splash;

    // ── Unauthenticated ──────────────────────────────────────────────────────
    if (!isAuthenticated) {
      return (isOnSplash || !isOnPublicRoute) ? AppRoutes.login : null;
    }

    // ── Authenticated on splash / public routes ─────────────────────────────
    if (isOnSplash || isOnPublicRoute) {
      // Check for a restored session before defaulting to /main.
      if (sessionState is SessionRestored) {
        return '${AppRoutes.resumeLobby}/${sessionState.partyCode}';
      }
      return AppRoutes.main;
    }

    // ── Authenticated, inside the app — check for unhandled restoration ─────
    if (sessionState is SessionRestored) {
      final alreadyOnLobby =
          loc == AppRoutes.lobby || loc.startsWith(AppRoutes.resumeLobby);
      if (!alreadyOnLobby) {
        return '${AppRoutes.resumeLobby}/${sessionState.partyCode}';
      }
    }

    return null; // No redirect needed.
  }

  static GoRouter get router => _router;
}
