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

  PartyState copyWith({
    PartyBlocStatus? status,
    PartyEntity? party,
    String? actionError, // pass null to clear
    bool clearActionError = false,
    bool? isActionLoading,
  }) => PartyState(
    status: status ?? this.status,
    party: party ?? this.party,
    actionError: clearActionError ? null : actionError ?? this.actionError,
    isActionLoading: isActionLoading ?? this.isActionLoading,
  );

  @override
  List<Object?> get props => [status, party, actionError, isActionLoading];
}
