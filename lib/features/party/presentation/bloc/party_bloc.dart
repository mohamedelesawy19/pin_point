// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/domain/usecases/create_party_usecase.dart';
import '/features/party/domain/usecases/join_party_usecase.dart';
import '/features/party/domain/usecases/kick_player_usecase.dart';
import '/features/party/domain/usecases/leave_party_usecase.dart';
import '/features/party/domain/usecases/start_game_usecase.dart';
import '/features/party/domain/usecases/watch_party_usecase.dart';

// Part imports:
part 'party_event.dart';
part 'party_state.dart';

class PartyBloc extends Bloc<PartyEvent, PartyState> {
  PartyBloc({
    required this._createParty,
    required this._joinParty,
    required this._kickPlayer,
    required this._leaveParty,
    required this._startGame,
    required this._watchParty,
  }) : super(const PartyState()) {
    on<CreatePartyEvent>(_onCreateParty, transformer: droppable());
    on<JoinPartyEvent>(_onJoinParty, transformer: droppable());
    on<ResumePartyEvent>(_onResumeParty, transformer: droppable());
    on<KickPlayerEvent>(_onKickPlayer, transformer: droppable());
    on<LeavePartyEvent>(_onLeaveParty, transformer: droppable());
    on<StartGameEvent>(_onStartGame, transformer: droppable());
    on<_WatchPartyEvent>(_onWatchParty, transformer: restartable());
  }

  final CreatePartyUseCase _createParty;
  final JoinPartyUseCase _joinParty;
  final KickPlayerUseCase _kickPlayer;
  final LeavePartyUseCase _leaveParty;
  final StartGameUseCase _startGame;
  final WatchPartyUseCase _watchParty;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onCreateParty(
    CreatePartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(
      state.copyWith(status: PartyBlocStatus.loading, clearActionError: true),
    );
    final result = await _createParty(
      CreatePartyParams(partyName: event.partyName, settings: event.settings),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PartyBlocStatus.initial,
          actionError: failure.message,
        ),
      ),
      (partyCode) => add(_WatchPartyEvent(partyCode: partyCode)),
    );
  }

  Future<void> _onJoinParty(
    JoinPartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(
      state.copyWith(status: PartyBlocStatus.loading, clearActionError: true),
    );
    final result = await _joinParty(SingleParam(event.partyCode));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PartyBlocStatus.initial,
          actionError: failure.message,
        ),
      ),
      (partyCode) => add(_WatchPartyEvent(partyCode: partyCode)),
    );
  }

  Future<void> _onResumeParty(
    ResumePartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(
      state.copyWith(status: PartyBlocStatus.loading, clearActionError: true),
    );
    add(_WatchPartyEvent(partyCode: event.partyCode));
  }

  // ── Party Stream ───────────────────────────────────────────────────────────

  Future<void> _onWatchParty(
    _WatchPartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    await emit.forEach<PartyEntity>(
      _watchParty(SingleParam(event.partyCode)),
      onData: (party) => state.hasLeft
          ? state
          : state.copyWith(
              status: PartyBlocStatus.inLobby,
              party: party,
              clearActionError: true,
            ),
      onError: (_, _) => state.copyWith(
        status: PartyBlocStatus.initial,
        actionError: 'Party connection lost',
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onKickPlayer(
    KickPlayerEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearActionError: true));
    final result = await _kickPlayer(
      KickPlayerParams(partyCode: event.partyCode, targetUid: event.targetUid),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, actionError: failure.message),
      ),
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }

  Future<void> _onLeaveParty(
    LeavePartyEvent event,
    Emitter<PartyState> emit,
  ) async {
    final result = await _leaveParty(
      LeavePartyParams(partyCode: event.partyCode),
    );
    result.fold(
      (failure) => emit(state.copyWith(actionError: failure.message)),
      (_) => emit(state.copyWith(status: PartyBlocStatus.left)),
    );
  }

  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<PartyState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearActionError: true));
    final result = await _startGame(SingleParam(event.partyCode));
    result.fold(
      (failure) => emit(
        state.copyWith(isActionLoading: false, actionError: failure.message),
      ),
      (_) => emit(state.copyWith(isActionLoading: false)),
    );
  }
}
