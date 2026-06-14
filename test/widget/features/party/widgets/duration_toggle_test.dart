import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/chips/selectable_chip.dart';
import 'package:pin_point/features/party/presentation/widgets/duration_toggle.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  final options = [30, 60];
  String labelBuilder(int value) => value == 30 ? 'Short' : 'Medium';

  testWidgets('DurationToggle renders all options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        DurationToggle(
          selected: 30,
          options: options,
          labelBuilder: labelBuilder,
          onChanged: (value) {},
        ),
      ),
    );

    expect(find.text('30s'), findsOneWidget);
    expect(find.text('60s'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('DurationToggle calls onChanged with correct option', (
    WidgetTester tester,
  ) async {
    int? tapped;

    await tester.pumpWidget(
      buildTestWidget(
        DurationToggle(
          selected: 30,
          options: options,
          labelBuilder: labelBuilder,
          onChanged: (value) => tapped = value,
        ),
      ),
    );

    await tester.tap(find.text('60s'));
    await tester.pump();

    expect(tapped, equals(60));
  });

  testWidgets('DurationToggle highlights selected option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        DurationToggle(
          selected: 60,
          options: options,
          labelBuilder: labelBuilder,
          onChanged: (value) {},
        ),
      ),
    );

    expect(find.text('60s'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('DurationToggle renders correct number of chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        DurationToggle(
          selected: 30,
          options: options,
          labelBuilder: labelBuilder,
          onChanged: (value) {},
        ),
      ),
    );

    expect(find.byType(SelectableChip), findsNWidgets(2));
  });

  testWidgets('DurationToggle renders subtitle labels correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        DurationToggle(
          selected: 30,
          options: options,
          labelBuilder: labelBuilder,
          onChanged: (value) {},
        ),
      ),
    );

    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
  });
}
