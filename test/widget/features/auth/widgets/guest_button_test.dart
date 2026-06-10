import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/auth/presentation/widgets/guest_button.dart';

void main() {
  group('GuestButton', () {
    Widget buildWidget({required VoidCallback onPressed}) => MaterialApp(
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      home: Scaffold(body: GuestButton(onPressed: onPressed)),
    );

    testWidgets('renders button with icon and text', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildWidget(onPressed: () => pressed = true));

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.person_outline_rounded),
      );
      expect(icon.size, 21);
    });

    testWidgets('button has correct vertical padding', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));
      await tester.pumpAndSettle();

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(
        button.style!.padding?.resolve({}),
        const EdgeInsets.symmetric(vertical: 17),
      );
    });
  });
}
