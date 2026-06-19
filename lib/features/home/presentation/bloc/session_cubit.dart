// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/party/domain/usecases/restore_party_session_usecase.dart';

// Part imports:
part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required this._restorePartySession})
    : super(const SessionInitial());

  final RestorePartySessionUseCase _restorePartySession;

  Future<void> restorePartySession(String uid) async {
    emit(const SessionChecking());

    final result = await _restorePartySession(SingleParam(uid));
    if (isClosed) return;

    String? partyCode;
    result.fold((_) => partyCode = null, (code) => partyCode = code);

    emit(
      partyCode != null
          ? SessionRestored(partyCode: partyCode!)
          : const SessionClean(),
    );
  }

  void consumeSession() => emit(const SessionClean());

  void reset() => emit(const SessionInitial());
}
