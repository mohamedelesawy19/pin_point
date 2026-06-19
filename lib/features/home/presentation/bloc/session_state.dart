part of 'session_cubit.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionChecking extends SessionState {
  const SessionChecking();
}

final class SessionClean extends SessionState {
  const SessionClean();
}

final class SessionRestored extends SessionState {
  const SessionRestored({required this.partyCode});
  final String partyCode;
  @override
  List<Object?> get props => [partyCode];
}
