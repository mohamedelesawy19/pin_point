// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/router/app_routes.dart';

// Feature imports:
import '/features/party/presentation/bloc/party_bloc.dart';
import '/features/party/presentation/screens/create_party_screen.dart';

class PartyRoutes {
  const PartyRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: AppRoutes.createParty,
      builder: (_, _) => BlocProvider(
        create: (context) => ServiceLocator.get<PartyBloc>(),
        child: const CreatePartyScreen(),
      ),
    ),
  ];
}
