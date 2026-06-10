import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/home/presentation/screens/home_screen.dart';
import 'package:pin_point/features/home/presentation/widgets/home_action_card.dart';
import 'package:pin_point/features/home/presentation/widgets/home_header.dart';

void main() {
  group('HomeScreen', () {
    Future<void> pumpHomeScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: LocalizationConfig.localizationsDelegates,
          supportedLocales: LocalizationConfig.supportedLocales,
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders all initial UI elements', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(ActionCard), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('does not navigate on invalid room code', (tester) async {
      await pumpHomeScreen(tester);

      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      await tester.tap(find.textContaining('Join').first);
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('stays on screen after valid code (navigation pending)', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.tap(find.textContaining('Join').first);
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('stays on screen after create tap (navigation pending)', (
      tester,
    ) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.textContaining('Create').first);
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
