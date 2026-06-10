import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pin_point/features/auth/presentation/screens/login_screen.dart';
import 'package:pin_point/features/auth/presentation/widgets/google_button.dart';
import 'package:pin_point/features/auth/presentation/widgets/guest_button.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
  });

  Widget buildWidget() => MaterialApp(
    localizationsDelegates: LocalizationConfig.localizationsDelegates,
    supportedLocales: LocalizationConfig.supportedLocales,
    home: BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: const LoginScreen(),
    ),
  );

  group('LoginScreen', () {
    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(GoogleButton), findsOneWidget);
      expect(find.byType(GuestButton), findsOneWidget);
      expect(find.byIcon(Icons.location_pin), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('adds SignInWithGoogleEvent when google button tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(GoogleButton));
      await tester.pump();

      verify(() => mockAuthBloc.add(const SignInWithGoogleEvent())).called(1);
    });

    testWidgets('adds SignInAnonymouslyEvent when guest button tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(GuestButton));
      await tester.pump();

      verify(() => mockAuthBloc.add(const SignInAnonymouslyEvent())).called(1);
    });
  });
}
