// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';

// Feature imports:
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
        GoRoute(
          path: AppRoutes.lobby,
          builder: (_, state) {
            final args = state.extra as LobbyArgs;
            return LobbyScreen(currentUserId: args.currentUserId);
          },
        ),
      ],
    ),
  ];
}
