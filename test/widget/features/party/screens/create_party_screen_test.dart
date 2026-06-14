import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/core/widgets/buttons/primary_button.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/presentation/bloc/party_bloc.dart';
import 'package:pin_point/features/party/presentation/screens/create_party_screen.dart';
import 'package:pin_point/features/party/presentation/widgets/duration_toggle.dart';
import 'package:pin_point/features/party/presentation/widgets/game_summary_banner.dart';
import 'package:pin_point/features/party/presentation/widgets/rounds_selector.dart';

class MockPartyBloc extends MockBloc<PartyEvent, PartyState>
    implements PartyBloc {}

void whenBlocEmits(MockPartyBloc bloc, List<PartyState> states) {
  whenListen(bloc, Stream.fromIterable(states), initialState: states.first);
}

// ─── Finders ─────────────────────────────────────────────────────────────────

final _partyNameField = find.byType(TextFormField);
final _createButton = find.byType(PrimaryButton);
final _snackbar = find.byType(SnackBar);

// ─── Setup ───────────────────────────────────────────────────────────────────

Widget _buildScreen({
  required MockPartyBloc bloc,
  List<String> pushedRoutes = const [],
}) {
  return MaterialApp(
    localizationsDelegates: LocalizationConfig.localizationsDelegates,
    supportedLocales: LocalizationConfig.supportedLocales,
    onGenerateRoute: (settings) {
      pushedRoutes.add(settings.name ?? '');
      return MaterialPageRoute(builder: (_) => const SizedBox());
    },
    home: BlocProvider<PartyBloc>.value(
      value: bloc,
      child: const CreatePartyScreen(),
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockPartyBloc bloc;

  setUp(() {
    bloc = MockPartyBloc();
    when(() => bloc.state).thenReturn(const PartyState());
    // mocktail requires registering fallback values for custom types
    registerFallbackValue(
      const CreatePartyEvent(
        partyName: '',
        settings: PartySettings(roundDurationSeconds: 60, totalRounds: 5),
      ),
    );
  });

  tearDown(() => bloc.close());

  // ── 1. Rendering ───────────────────────────────────────────────────────────

  group('Rendering', () {
    testWidgets('shows all form sections on initial load', (tester) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      expect(_partyNameField, findsOneWidget);
      expect(find.byType(DurationToggle), findsOneWidget);
      expect(find.byType(RoundsSelector), findsOneWidget);
      expect(find.byType(GameSummaryBanner), findsOneWidget);
      expect(_createButton, findsOneWidget);
    });

    testWidgets('create button is enabled in idle state', (tester) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNotNull);
    });
  });

  // ── 2. Validation ──────────────────────────────────────────────────────────

  group('Form validation', () {
    testWidgets('shows error when party name is empty', (tester) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      await tester.tap(_createButton);
      await tester.pump();

      expect(find.text('Please enter a party name'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('shows error when party name is too short', (tester) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      await tester.enterText(_partyNameField, 'A');
      await tester.tap(_createButton);
      await tester.pump();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('trims whitespace before validation', (tester) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      await tester.enterText(_partyNameField, '   ');
      await tester.tap(_createButton);
      await tester.pump();

      // Whitespace-only → treated as empty
      expect(find.text('Please enter a party name'), findsOneWidget);
    });
  });

  // ── 3. Event dispatch ──────────────────────────────────────────────────────

  group('CreatePartyEvent dispatch', () {
    testWidgets('dispatches event with trimmed name and default settings', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      await tester.enterText(_partyNameField, '  Night Owls  ');
      await tester.tap(_createButton);
      await tester.pump();

      verify(
        () => bloc.add(
          const CreatePartyEvent(
            partyName: 'Night Owls', // trimmed
            settings: PartySettings(
              roundDurationSeconds: 60, // default
              totalRounds: 5, // default
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches event with updated duration and rounds', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen(bloc: bloc));

      await tester.enterText(_partyNameField, 'Speed Round');

      // Tap the 30s chip
      await tester.tap(find.text('Fast'));
      await tester.pump();

      // Tap the 3-rounds chip
      await tester.tap(find.text('3'));
      await tester.pump();

      await tester.tap(_createButton);
      await tester.pump();

      verify(
        () => bloc.add(
          const CreatePartyEvent(
            partyName: 'Speed Round',
            settings: PartySettings(roundDurationSeconds: 30, totalRounds: 3),
          ),
        ),
      ).called(1);
    });
  });

  // ── 4. Loading state ───────────────────────────────────────────────────────

  group('Loading state', () {
    testWidgets('button is disabled and shows loading indicator', (
      tester,
    ) async {
      whenBlocEmits(bloc, [const PartyState(status: PartyBlocStatus.loading)]);

      await tester.pumpWidget(_buildScreen(bloc: bloc));
      await tester.pump();

      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.isLoading, isTrue);
    });
  });

  // ── 5. Error handling ──────────────────────────────────────────────────────

  group('Error handling', () {
    testWidgets('shows snackbar on actionError', (tester) async {
      whenBlocEmits(bloc, [
        const PartyState(),
        const PartyState(actionError: 'Something went wrong'),
      ]);

      await tester.pumpWidget(_buildScreen(bloc: bloc));
      await tester.pump();

      expect(_snackbar, findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('does not show snackbar when actionError is null', (
      tester,
    ) async {
      whenBlocEmits(bloc, [const PartyState()]);

      await tester.pumpWidget(_buildScreen(bloc: bloc));
      await tester.pump();

      expect(_snackbar, findsNothing);
    });
  });
}
