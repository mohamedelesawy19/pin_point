import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/auth/presentation/widgets/guest_button.dart';

void main() {
  group('GuestButton', () {
    Widget createWidget({required VoidCallback onPressed}) {
      return MaterialApp(
        localizationsDelegates: LocalizationConfig.localizationsDelegates,
        supportedLocales: LocalizationConfig.supportedLocales,
        home: Scaffold(body: GuestButton(onPressed: onPressed)),
      );
    }

    testWidgets('should render OutlinedButton with icon and text', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(onPressed: () {}));

      expect(find.byType(GuestButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createWidget(
          onPressed: () {
            pressed = true;
          },
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('should display correct icon', (tester) async {
      await tester.pumpWidget(createWidget(onPressed: () {}));

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.person_outline_rounded),
      );

      expect(icon.size, 21);
      expect(icon.color, Colors.white54);
    });

    testWidgets('should have correct button style', (tester) async {
      await tester.pumpWidget(createWidget(onPressed: () {}));

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));

      final style = button.style!;

      expect(style.foregroundColor?.resolve({}), Colors.white60);

      expect(
        style.padding?.resolve({}),
        const EdgeInsets.symmetric(vertical: 17),
      );
    });
  });
}
