import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/chips/selectable_chip.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('SelectableChip shows child widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        SelectableChip(
          isSelected: false,
          onTap: () {},
          child: const Text('Chip'),
        ),
      ),
    );

    expect(find.text('Chip'), findsOneWidget);
  });

  testWidgets('SelectableChip triggers onTap when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      buildTestWidget(
        SelectableChip(
          isSelected: false,
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
      ),
    );

    await tester.tap(find.text('Tap Me'));
    await tester.pump();

    expect(tapped, true);
  });

  testWidgets('SelectableChip renders in selected state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        SelectableChip(
          isSelected: true,
          onTap: () {},
          child: const Text('Selected'),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );

    final decoration = container.decoration as BoxDecoration;

    // selected state => no border
    expect(decoration.border, null);
    expect(decoration.color, isNotNull);
  });

  testWidgets('SelectableChip renders in unselected state with border', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        SelectableChip(
          isSelected: false,
          onTap: () {},
          child: const Text('Not Selected'),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );

    final decoration = container.decoration as BoxDecoration;

    expect(decoration.border, isNotNull);
    expect(decoration.border!.top.color, isNotNull);
  });

  testWidgets('SelectableChip has InkWell for interaction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        SelectableChip(
          isSelected: false,
          onTap: () {},
          child: const Text('Ink'),
        ),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
  });
}
