part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStartedEvent extends AuthEvent {
  const AuthStartedEvent();
}

class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

class SignInAnonymouslyEvent extends AuthEvent {
  const SignInAnonymouslyEvent();
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
