import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/cards/section_card.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets(
    'SectionCard displays title and child only when subtitle is null',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SectionCard(title: 'Main Title', child: Text('Child Content')),
        ),
      );

      expect(find.text('Main Title'), findsOneWidget);
      expect(find.text('Child Content'), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    },
  );

  testWidgets('SectionCard displays subtitle when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        const SectionCard(
          title: 'Main Title',
          subtitle: 'Subtitle Text',
          child: Text('Child Content'),
        ),
      ),
    );

    expect(find.text('Main Title'), findsOneWidget);
    expect(find.text('Subtitle Text'), findsOneWidget);
    expect(find.text('Child Content'), findsOneWidget);
  });

  testWidgets('SectionCard does not show subtitle when null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        const SectionCard(title: 'Main Title', child: Text('Child Content')),
      ),
    );

    expect(find.text('Subtitle Text'), findsNothing);
  });
}
