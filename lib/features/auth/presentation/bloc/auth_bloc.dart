// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Feature imports:
import '/features/auth/domain/entities/user_entity.dart';
import '/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_out_usecase.dart';
import '/features/auth/domain/usecases/watch_auth_state_usecase.dart';

// Part imports:
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._signInWithGoogle,
    required this._signInAnonymously,
    required this._signOut,
    required this._watchAuthState,
  }) : super(const AuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle, transformer: droppable());
    on<SignInAnonymouslyEvent>(_onSignInAnonymously, transformer: droppable());
    on<SignOutEvent>(_onSignOut, transformer: droppable());
    on<AuthStartedEvent>(_onAuthStarted, transformer: restartable());
  }

  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignInAnonymouslyUseCase _signInAnonymously;
  final SignOutUseCase _signOut;
  final WatchAuthStateUseCase _watchAuthState;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent _,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();
    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {
      // No need to emit AuthAuthenticated here; the auth state stream will
      // emit the new user when the sign-in completes successfully.
    });
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymouslyEvent _,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInAnonymously();
    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {});
  }

  Future<void> _onSignOut(SignOutEvent _, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signOut();
    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {});
  }

  // ── Auth State Stream ──────────────────────────────────────────────────────

  Future<void> _onAuthStarted(
    AuthStartedEvent _,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach<UserEntity?>(
      _watchAuthState(),
      onData: (user) => user != null
          ? AuthAuthenticated(user: user)
          : const AuthUnauthenticated(),
      onError: (_, _) => const AuthUnauthenticated(),
    );
  }
}
