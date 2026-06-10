import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/buttons/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    Widget buildWidget({
      String text = 'Button',
      bool isLoading = false,
      VoidCallback? onPressed,
      Widget? leading,
    }) => MaterialApp(
      home: Scaffold(
        body: PrimaryButton(
          text: text,
          isLoading: isLoading,
          onPressed: onPressed ?? () {},
          leading: leading,
        ),
      ),
    );

    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(buildWidget(text: 'Click Me'));

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildWidget(onPressed: () => pressed = true));

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator and hides text when loading', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(text: 'Loading', isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('shows leading icon alongside text', (tester) async {
      await tester.pumpWidget(
        buildWidget(text: 'Icon', leading: const Icon(Icons.add)),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Icon'), findsOneWidget);
    });

    testWidgets('does not trigger onPressed when loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        buildWidget(isLoading: true, onPressed: () => pressed = true),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });
}
