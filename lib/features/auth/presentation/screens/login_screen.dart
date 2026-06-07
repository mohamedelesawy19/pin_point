// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () {
                context.read<AuthBloc>().add(const SignInWithGoogleEvent());
              },
              child: const Text('Login with Google'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                context.read<AuthBloc>().add(const SignInAnonymouslyEvent());
              },
              child: const Text('Login as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
