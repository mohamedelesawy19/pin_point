part of 'party_bloc.dart';

abstract class PartyEvent extends Equatable {
  const PartyEvent();
  @override
  List<Object?> get props => [];
}

class CreatePartyEvent extends PartyEvent {
  const CreatePartyEvent({required this.partyName, required this.settings});

  final String partyName;
  final PartySettings settings;

  @override
  List<Object?> get props => [partyName, settings];
}

class JoinPartyEvent extends PartyEvent {
  const JoinPartyEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

final class ResumePartyEvent extends PartyEvent {
  const ResumePartyEvent({required this.partyCode});
  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

// Internal event — dispatched automatically after create/join
class _WatchPartyEvent extends PartyEvent {
  const _WatchPartyEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

class KickPlayerEvent extends PartyEvent {
  const KickPlayerEvent({required this.partyCode, required this.targetUid});

  final String partyCode;
  final String targetUid;

  @override
  List<Object?> get props => [partyCode, targetUid];
}

class LeavePartyEvent extends PartyEvent {
  const LeavePartyEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}

class StartGameEvent extends PartyEvent {
  const StartGameEvent({required this.partyCode});

  final String partyCode;

  @override
  List<Object?> get props => [partyCode];
}
