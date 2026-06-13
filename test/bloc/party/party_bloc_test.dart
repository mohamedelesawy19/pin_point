import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';
import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/usecases/create_party_usecase.dart';
import 'package:pin_point/features/party/domain/usecases/join_party_usecase.dart';
import 'package:pin_point/features/party/domain/usecases/kick_player_usecase.dart';
import 'package:pin_point/features/party/domain/usecases/leave_party_usecase.dart';
import 'package:pin_point/features/party/domain/usecases/start_game_usecase.dart';
import 'package:pin_point/features/party/domain/usecases/watch_party_usecase.dart';
import 'package:pin_point/features/party/presentation/bloc/party_bloc.dart';

class MockCreatePartyUseCase extends Mock implements CreatePartyUseCase {}

class MockJoinPartyUseCase extends Mock implements JoinPartyUseCase {}

class MockKickPlayerUseCase extends Mock implements KickPlayerUseCase {}

class MockLeavePartyUseCase extends Mock implements LeavePartyUseCase {}

class MockStartGameUseCase extends Mock implements StartGameUseCase {}

class MockWatchPartyUseCase extends Mock implements WatchPartyUseCase {}

class FakeCreatePartyParams extends Fake implements CreatePartyParams {}

class FakeKickPlayerParams extends Fake implements KickPlayerParams {}

class FakeLeavePartyParams extends Fake implements LeavePartyParams {}

class FakeSingleParam extends Fake implements SingleParam<String> {}

void main() {
  late PartyBloc bloc;

  late MockCreatePartyUseCase createParty;
  late MockJoinPartyUseCase joinParty;
  late MockKickPlayerUseCase kickPlayer;
  late MockLeavePartyUseCase leaveParty;
  late MockStartGameUseCase startGame;
  late MockWatchPartyUseCase watchParty;

  const code = 'ABC123';

  const settings = PartySettings(roundDurationSeconds: 60, totalRounds: 4);

  late PartyEntity party;

  setUpAll(() {
    registerFallbackValue(FakeCreatePartyParams());
    registerFallbackValue(FakeKickPlayerParams());
    registerFallbackValue(FakeLeavePartyParams());
    registerFallbackValue(FakeSingleParam());
  });

  setUp(() {
    createParty = MockCreatePartyUseCase();
    joinParty = MockJoinPartyUseCase();
    kickPlayer = MockKickPlayerUseCase();
    leaveParty = MockLeavePartyUseCase();
    startGame = MockStartGameUseCase();
    watchParty = MockWatchPartyUseCase();

    party = PartyEntity(
      hostId: 'host',
      hostName: 'Host',
      partyCode: code,
      partyName: 'Party',
      currentRound: 0,
      status: PartyStatus.waiting,
      players: const [],
      settings: settings,
      createdAt: DateTime.now(),
    );

    bloc = PartyBloc(
      createParty: createParty,
      joinParty: joinParty,
      kickPlayer: kickPlayer,
      leaveParty: leaveParty,
      startGame: startGame,
      watchParty: watchParty,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  // ── CreateParty ────────────────────────────────────────────────────────────

  group('CreatePartyEvent', () {
    blocTest<PartyBloc, PartyState>(
      'emits loading → inLobby when successful',
      build: () {
        when(
          () => createParty(any()),
        ).thenAnswer((_) async => const Right(code));
        when(() => watchParty(any())).thenAnswer((_) => Stream.value(party));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const CreatePartyEvent(partyName: 'Party', settings: settings),
      ),
      expect: () => [
        const PartyState(status: PartyBlocStatus.loading),
        PartyState(status: PartyBlocStatus.inLobby, party: party),
      ],
      verify: (_) {
        verify(() => createParty(any())).called(1);
        verify(() => watchParty(any())).called(1);
      },
    );

    blocTest<PartyBloc, PartyState>(
      'emits loading → initial with actionError when failed',
      build: () {
        when(
          () => createParty(any()),
        ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const CreatePartyEvent(partyName: 'Party', settings: settings),
      ),
      expect: () => const [
        PartyState(status: PartyBlocStatus.loading),
        PartyState(actionError: 'error'),
      ],
    );
  });

  // ── JoinParty ──────────────────────────────────────────────────────────────

  group('JoinPartyEvent', () {
    blocTest<PartyBloc, PartyState>(
      'emits loading → inLobby when successful',
      build: () {
        when(() => joinParty(any())).thenAnswer((_) async => const Right(code));
        when(() => watchParty(any())).thenAnswer((_) => Stream.value(party));
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinPartyEvent(partyCode: code)),
      expect: () => [
        const PartyState(status: PartyBlocStatus.loading),
        PartyState(status: PartyBlocStatus.inLobby, party: party),
      ],
    );

    blocTest<PartyBloc, PartyState>(
      'emits loading → initial with actionError when failed',
      build: () {
        when(() => joinParty(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'join failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinPartyEvent(partyCode: code)),
      expect: () => const [
        PartyState(status: PartyBlocStatus.loading),
        PartyState(actionError: 'join failed'),
      ],
    );
  });

  // ── KickPlayer ─────────────────────────────────────────────────────────────

  group('KickPlayerEvent', () {
    blocTest<PartyBloc, PartyState>(
      'emits actionLoading → actionError when failed',
      build: () {
        when(() => kickPlayer(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'kick failed')),
        );
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const KickPlayerEvent(partyCode: code, targetUid: 'user1')),
      expect: () => const [
        PartyState(isActionLoading: true),
        PartyState(actionError: 'kick failed'),
      ],
    );

    blocTest<PartyBloc, PartyState>(
      'emits actionLoading → idle when successful',
      build: () {
        when(
          () => kickPlayer(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const KickPlayerEvent(partyCode: code, targetUid: 'user1')),
      expect: () => const [
        PartyState(isActionLoading: true),
        PartyState(), // isActionLoading: false = initial state
      ],
    );
  });

  // ── LeaveParty ─────────────────────────────────────────────────────────────

  group('LeavePartyEvent', () {
    blocTest<PartyBloc, PartyState>(
      'emits left when successful',
      build: () {
        when(
          () => leaveParty(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeavePartyEvent(partyCode: code)),
      expect: () => const [PartyState(status: PartyBlocStatus.left)],
    );

    blocTest<PartyBloc, PartyState>(
      'emits actionError when failed',
      build: () {
        when(() => leaveParty(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'leave failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LeavePartyEvent(partyCode: code)),
      expect: () => const [PartyState(actionError: 'leave failed')],
    );
  });

  // ── StartGame ──────────────────────────────────────────────────────────────

  group('StartGameEvent', () {
    blocTest<PartyBloc, PartyState>(
      'emits actionLoading → idle when successful',
      build: () {
        when(() => startGame(any())).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartGameEvent(partyCode: code)),
      expect: () => const [PartyState(isActionLoading: true), PartyState()],
    );

    blocTest<PartyBloc, PartyState>(
      'emits actionLoading → actionError when failed',
      build: () {
        when(() => startGame(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'start failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const StartGameEvent(partyCode: code)),
      expect: () => const [
        PartyState(isActionLoading: true),
        PartyState(actionError: 'start failed'),
      ],
    );
  });
}
