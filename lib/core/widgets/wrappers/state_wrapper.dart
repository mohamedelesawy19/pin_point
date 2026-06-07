// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/di/service_locator.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';

class StateWrapper extends StatelessWidget {
  const StateWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) =>
              ServiceLocator.get<AuthBloc>()..add(const AuthStartedEvent()),
        ),
      ],
      child: child,
    );
  }
}
