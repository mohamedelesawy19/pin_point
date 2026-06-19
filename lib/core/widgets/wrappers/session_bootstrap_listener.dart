// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/home/presentation/bloc/session_cubit.dart';

class SessionBootstrapListener extends StatelessWidget {
  const SessionBootstrapListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        final sessionCubit = context.read<SessionCubit>();

        switch (state) {
          case AuthAuthenticated(:final user):
            sessionCubit.restorePartySession(user.uid);
          case AuthUnauthenticated():
            sessionCubit.reset();
          default:
            break;
        }
      },
      child: child,
    );
  }
}
