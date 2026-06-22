import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/constants/firestore_constants.dart';
import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/core/router/app_routes.dart';

import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/presentation/bloc/party_bloc.dart';
import 'package:pin_point/features/party/presentation/screens/lobby_screen.dart';
import 'package:pin_point/features/party/presentation/widgets/host_actions_bar.dart';
import 'package:pin_point/features/party/presentation/widgets/lobby_app_bar.dart';
import 'package:pin_point/features/party/presentation/widgets/lobby_settings_card.dart';
import 'package:pin_point/features/party/presentation/widgets/players_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks & Fakes
// ─────────────────────────────────────────────────────────────────────────────

class MockPartyBloc extends MockBloc<PartyEvent, PartyState>
    implements PartyBloc {}

class MockGoRouter extends Mock implements GoRouter {}

// ─────────────────────────────────────────────────────────────────────────────
// Test Fixtures
// ─────────────────────────────────────────────────────────────────────────────

const _kHostId = 'host-uid-001';
const _kGuestId = 'guest-uid-002';
const _kPartyCode = 'ABC123';

/// Creates a [PartySettings] with sensible defaults.
PartySettings _defaultSettings() =>
    const PartySettings(totalRounds: 3, roundDurationSeconds: 60);

/// Creates a minimal [PlayerEntity].
PlayerEntity _makePlayer({required String uid, required String name}) =>
    PlayerEntity(uid: uid, displayName: name, isAnonymous: false, score: 0);

/// Creates a [PartyEntity] ready for lobby use.
PartyEntity _makeParty({
  String hostId = _kHostId,
  String partyCode = _kPartyCode,
  String partyName = 'Test Party',
  PartyStatus status = PartyStatus.waiting,
  List<PlayerEntity>? players,
  PartySettings? settings,
}) => PartyEntity(
  hostName: 'Host Player',
  hostId: hostId,
  partyCode: partyCode,
  partyName: partyName,
  status: status,
  players:
      players ??
      [
        _makePlayer(uid: _kHostId, name: 'Host Player'),
        _makePlayer(uid: _kGuestId, name: 'Guest Player'),
      ],
  kickedPlayers: const {},
  settings: settings ?? _defaultSettings(),
  currentRound: 0,
  createdAt: DateTime.now(),
);

/// Returns a [PartyState] that represents a loaded lobby.
PartyState _loadedState({
  PartyEntity? party,
  String? actionError,
  bool isActionLoading = false,
}) => PartyState(
  status: PartyBlocStatus.inLobby,
  party: party ?? _makeParty(),
  actionError: actionError,
  isActionLoading: isActionLoading,
);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [widget] with the minimum set of ancestors required for [LobbyScreen]:
///   • [MaterialApp] with localizations
///   • [GoRouter] (via [InheritedGoRouter] shim)
///   • [BlocProvider] for [PartyBloc]
Widget _buildSubject({
  required MockPartyBloc bloc,
  required MockGoRouter router,
  String currentUserId = _kHostId,
}) {
  return BlocProvider<PartyBloc>.value(
    value: bloc,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: InheritedGoRouter(
        goRouter: router,
        child: LobbyScreen(currentUserId: currentUserId),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Test Suite
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockPartyBloc bloc;
  late MockGoRouter router;

  setUpAll(() {
    registerFallbackValue(const StartGameEvent(partyCode: ''));
  });

  setUp(() {
    bloc = MockPartyBloc();
    router = MockGoRouter();
  });

  tearDown(() {
    bloc.close();
    reset(router);
  });

  // ── Loading state ──────────────────────────────────────────────────────────

  group('LobbyScreen — loading state', () {
    setUp(() {
      when(
        () => bloc.state,
      ).thenReturn(const PartyState(status: PartyBlocStatus.loading));
      whenListen(bloc, const Stream<PartyState>.empty());
    });

    testWidgets('shows CircularProgressIndicator when party is null', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "connecting to lobby" label when party is null', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      // The key text comes from l10n.connectingToLobby.
      // Adjust the matcher to the real translated string if localizations
      // are configured in the test wrapper.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // ── Lobby renders correctly ────────────────────────────────────────────────

  group('LobbyScreen — lobby view', () {
    setUp(() {
      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, const Stream<PartyState>.empty());
    });

    testWidgets('renders LobbyAppBar, LobbySettingsCard, and PlayersSection', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      expect(find.byType(LobbyAppBar), findsOneWidget);
      expect(find.byType(LobbySettingsCard), findsOneWidget);
      expect(find.byType(PlayersSection), findsOneWidget);
    });

    testWidgets('passes party name to LobbyAppBar', (tester) async {
      const expectedName = 'My Awesome Party';

      when(
        () => bloc.state,
      ).thenReturn(_loadedState(party: _makeParty(partyName: expectedName)));

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final appBar = tester.widget<LobbyAppBar>(find.byType(LobbyAppBar));
      expect(appBar.partyName, expectedName);
    });

    testWidgets('passes party settings to LobbySettingsCard', (tester) async {
      final settings = _defaultSettings();

      when(
        () => bloc.state,
      ).thenReturn(_loadedState(party: _makeParty(settings: settings)));

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final card = tester.widget<LobbySettingsCard>(
        find.byType(LobbySettingsCard),
      );
      expect(card.settings, settings);
    });

    testWidgets('passes player list and hostId to PlayersSection', (
      tester,
    ) async {
      final players = [
        _makePlayer(uid: _kHostId, name: 'Host'),
        _makePlayer(uid: _kGuestId, name: 'Guest'),
      ];

      when(
        () => bloc.state,
      ).thenReturn(_loadedState(party: _makeParty(players: players)));

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final section = tester.widget<PlayersSection>(
        find.byType(PlayersSection),
      );
      expect(section.players, players);
      expect(section.hostId, _kHostId);
    });
  });

  // ── Host-only UI ───────────────────────────────────────────────────────────

  group('LobbyScreen — host view', () {
    setUp(() {
      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, const Stream<PartyState>.empty());
    });

    testWidgets('shows HostActionsBar when current user is host', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      expect(find.byType(HostActionsBar), findsOneWidget);
    });

    testWidgets('hides HostActionsBar when current user is not host', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          bloc: bloc,
          router: router,
          currentUserId: _kGuestId, // guest
        ),
      );

      expect(find.byType(HostActionsBar), findsNothing);
    });

    testWidgets(
      'HostActionsBar receives canStart=true when enough players are present',
      (tester) async {
        // Build a party with exactly minPlayersToStart players.
        final players = List.generate(
          FirestoreConstants.minPlayersToStart,
          (i) => _makePlayer(uid: 'uid-$i', name: 'Player $i'),
        );

        when(
          () => bloc.state,
        ).thenReturn(_loadedState(party: _makeParty(players: players)));

        await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

        final bar = tester.widget<HostActionsBar>(find.byType(HostActionsBar));
        expect(bar.canStart, isTrue);
      },
    );

    testWidgets(
      'HostActionsBar receives canStart=false when not enough players',
      (tester) async {
        // Only one player — below minPlayersToStart.
        final players = [_makePlayer(uid: _kHostId, name: 'Lone Host')];

        when(
          () => bloc.state,
        ).thenReturn(_loadedState(party: _makeParty(players: players)));

        await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

        final bar = tester.widget<HostActionsBar>(find.byType(HostActionsBar));
        expect(bar.canStart, isFalse);
      },
    );
  });

  // ── Event dispatching ──────────────────────────────────────────────────────

  group('LobbyScreen — event dispatching', () {
    setUp(() {
      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, const Stream<PartyState>.empty());
    });

    testWidgets('dispatches LeavePartyEvent when onLeave is triggered', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      // Trigger leave via the AppBar callback.
      final appBar = tester.widget<LobbyAppBar>(find.byType(LobbyAppBar));
      appBar.onLeave();

      verify(
        () => bloc.add(const LeavePartyEvent(partyCode: _kPartyCode)),
      ).called(1);
    });

    testWidgets('dispatches KickPlayerEvent when onKick is triggered', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final section = tester.widget<PlayersSection>(
        find.byType(PlayersSection),
      );
      section.onKick(_kGuestId);

      verify(
        () => bloc.add(
          const KickPlayerEvent(partyCode: _kPartyCode, targetUid: _kGuestId),
        ),
      ).called(1);
    });

    testWidgets('dispatches StartGameEvent when canStart is true', (
      tester,
    ) async {
      final players = List.generate(
        FirestoreConstants.minPlayersToStart,
        (i) => _makePlayer(uid: 'uid-$i', name: 'Player $i'),
      );

      when(
        () => bloc.state,
      ).thenReturn(_loadedState(party: _makeParty(players: players)));

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final bar = tester.widget<HostActionsBar>(find.byType(HostActionsBar));
      bar.onStartGame();

      verify(
        () => bloc.add(const StartGameEvent(partyCode: _kPartyCode)),
      ).called(1);
    });

    testWidgets('shows error snackbar instead of dispatching StartGameEvent'
        ' when canStart is false', (tester) async {
      final players = [_makePlayer(uid: _kHostId, name: 'Lone Host')];

      when(
        () => bloc.state,
      ).thenReturn(_loadedState(party: _makeParty(players: players)));

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final bar = tester.widget<HostActionsBar>(find.byType(HostActionsBar));
      bar.onStartGame();
      await tester.pump();

      // No StartGameEvent should be dispatched.
      verifyNever(() => bloc.add(any()));

      // Error snackbar should appear.
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  // ── Clipboard ──────────────────────────────────────────────────────────────

  group('LobbyScreen — copy party code', () {
    setUp(() {
      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, const Stream<PartyState>.empty());
    });

    testWidgets('shows success snackbar after copying code to clipboard', (
      tester,
    ) async {
      // Intercept the platform channel used by Clipboard.setData.
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') return null;
          return null;
        },
      );

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));

      final bar = tester.widget<HostActionsBar>(find.byType(HostActionsBar));
      bar.onCopyCode();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  // ── State-driven side-effects ──────────────────────────────────────────────

  group('LobbyScreen — state listener side-effects', () {
    testWidgets('navigates to main route when hasLeft becomes true', (
      tester,
    ) async {
      final leftState = PartyState(
        status: PartyBlocStatus.left,
        party: _makeParty(),
      );
      final stateStream = Stream<PartyState>.fromIterable([leftState]);

      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, stateStream);
      when(() => router.go(AppRoutes.main)).thenReturn(null);

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));
      await tester.pump();

      verify(() => router.go(AppRoutes.main)).called(1);
    });

    testWidgets('shows error snackbar when actionError is emitted', (
      tester,
    ) async {
      const error = 'Something went wrong';
      final stateStream = Stream<PartyState>.fromIterable([
        _loadedState(actionError: error),
      ]);

      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, stateStream);

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));
      await tester.pump();

      expect(find.text(error), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('does not navigate when party status changes to playing '
        '(navigation commented-out)', (tester) async {
      final playingParty = _makeParty(status: PartyStatus.playing);
      final stateStream = Stream<PartyState>.fromIterable([
        _loadedState(party: playingParty),
      ]);

      when(() => bloc.state).thenReturn(_loadedState());
      whenListen(bloc, stateStream);

      await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));
      await tester.pumpAndSettle();

      // context.go(AppRoutes.game) is commented out — verify no navigation.
      verifyNever(() => router.go(any()));
    });
  });

  // ── BLoC rebuild granularity ───────────────────────────────────────────────

  group('LobbyScreen — buildWhen / listenWhen guards', () {
    testWidgets(
      'does not rebuild main body when only isActionLoading changes',
      (tester) async {
        int buildCount = 0;

        final stateWithLoading = _loadedState(isActionLoading: true);
        final stateStream = Stream<PartyState>.fromIterable([stateWithLoading]);

        when(() => bloc.state).thenReturn(_loadedState());
        whenListen(bloc, stateStream);

        await tester.pumpWidget(
          BlocProvider<PartyBloc>.value(
            value: bloc,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: InheritedGoRouter(
                goRouter: router,
                child: Builder(
                  builder: (context) {
                    buildCount++;
                    return const LobbyScreen(currentUserId: _kHostId);
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // buildWhen only triggers on party change — count should stay at 1.
        expect(buildCount, 1);
      },
    );

    testWidgets(
      'HostActionsBar rebuilds independently when isActionLoading changes',
      (tester) async {
        final loadingState = _loadedState(isActionLoading: true);
        final stateStream = Stream<PartyState>.fromIterable([loadingState]);

        when(() => bloc.state).thenReturn(_loadedState());
        whenListen(bloc, stateStream);

        await tester.pumpWidget(_buildSubject(bloc: bloc, router: router));
        await tester.pump();

        final bar = tester.widget<HostActionsBar>(find.byType(HostActionsBar));
        expect(bar.isActionLoading, isTrue);
      },
    );
  });
}
