import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/cards/gradient_card.dart';

void main() {
  group('GradientCard', () {
    Widget buildWidget({Widget child = const Text('content')}) => MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(body: GradientCard(child: child)),
    );

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(buildWidget(child: const Text('Hello')));
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders as Container', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('applies gradient decoration', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('gradient runs from top-left to bottom-right', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      final gradient =
          (container.decoration as BoxDecoration).gradient as LinearGradient;

      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    testWidgets('gradient has two color stops', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      final gradient =
          (container.decoration as BoxDecoration).gradient as LinearGradient;

      expect(gradient.colors.length, 2);
    });

    testWidgets('applies correct border radius', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('applies border', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.border, isA<Border>());
    });

    testWidgets('applies box shadow', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.boxShadow, isNotEmpty);
      expect(decoration.boxShadow!.length, 1);
    });

    testWidgets('accepts any widget as child', (tester) async {
      await tester.pumpWidget(buildWidget(child: const Icon(Icons.star)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
