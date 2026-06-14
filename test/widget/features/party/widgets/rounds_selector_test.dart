import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/chips/selectable_chip.dart';
import 'package:pin_point/features/party/presentation/widgets/rounds_selector.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('RoundsSelector renders correct number of options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        RoundsSelector(
          selected: 2,
          options: const [1, 2, 3],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('RoundsSelector calls onChanged with correct value', (
    WidgetTester tester,
  ) async {
    int? selectedValue;

    await tester.pumpWidget(
      buildTestWidget(
        RoundsSelector(
          selected: 1,
          options: const [1, 2, 3],
          onChanged: (value) => selectedValue = value,
        ),
      ),
    );

    await tester.tap(find.text('3'));
    await tester.pump();

    expect(selectedValue, 3);
  });

  testWidgets('RoundsSelector marks correct chip as selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        RoundsSelector(
          selected: 2,
          options: const [1, 2, 3],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('RoundsSelector renders SelectableChips for each option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        RoundsSelector(selected: 1, options: const [1, 2], onChanged: (_) {}),
      ),
    );

    expect(find.byType(SelectableChip), findsNWidgets(2));
  });

  testWidgets('RoundsSelector wraps chips inside Row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        RoundsSelector(
          selected: 1,
          options: const [1, 2, 3],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(Row), findsOneWidget);
  });
}
