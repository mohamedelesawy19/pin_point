// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/party/presentation/bloc/party_bloc.dart';
import '/features/party/presentation/router/lobby_args.dart';
import '/features/party/presentation/screens/create_party_screen.dart';
import '/features/party/presentation/screens/lobby_screen.dart';

class PartyRoutes {
  const PartyRoutes._();

  static List<RouteBase> get routes => [
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => ServiceLocator.get<PartyBloc>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.createParty,
          builder: (_, _) => const CreatePartyScreen(),
        ),

        // ── Normal join (called from HomeScreen with extra args) ────────────
        GoRoute(
          path: AppRoutes.lobby,
          builder: (_, state) {
            final args = state.extra as LobbyArgs;
            return LobbyScreen(
              currentUserId: args.currentUserId,
              roomCode: args.roomCode,
              entrySource: args.entrySource,
            );
          },
        ),

        // ── Session restoration (called via router redirect, no extra) ──────
        GoRoute(
          path: '${AppRoutes.resumeLobby}/:code',
          builder: (context, state) {
            final code = state.pathParameters['code']!;
            // Safe: this route is only reachable when authenticated.
            final uid =
                (ServiceLocator.get<AuthBloc>().state as AuthAuthenticated)
                    .user
                    .uid;
            return LobbyScreen(
              currentUserId: uid,
              roomCode: code,
              entrySource: LobbyEntrySource.resume,
            );
          },
        ),
      ],
    ),
  ];
}
