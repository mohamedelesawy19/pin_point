part of 'party_bloc.dart';

enum PartyBlocStatus { initial, loading, inLobby, left }

class PartyState extends Equatable {
  const PartyState({
    this.status = PartyBlocStatus.initial,
    this.party,
    this.actionError,
    this.isActionLoading = false,
  });

  final PartyBlocStatus status;
  final PartyEntity? party;
  final String? actionError;
  final bool isActionLoading;

  bool get isInLobby => status == PartyBlocStatus.inLobby;
  bool get hasLeft => status == PartyBlocStatus.left;

  bool isPlayerInParty(String playerId) =>
      party?.players.any((p) => p.uid == playerId) ?? false;

  bool isPlayerKicked(String playerId) =>
      party?.kickedPlayers.contains(playerId) ?? false;

  PartyState copyWith({
    PartyBlocStatus? status,
    PartyEntity? party,
    bool clearParty = false,
    String? actionError, // pass null to clear
    bool clearActionError = false,
    bool? isActionLoading,
  }) => PartyState(
    status: status ?? this.status,
    party: clearParty ? null : (party ?? this.party),
    actionError: clearActionError ? null : actionError ?? this.actionError,
    isActionLoading: isActionLoading ?? this.isActionLoading,
  );

  @override
  List<Object?> get props => [status, party, actionError, isActionLoading];
}
