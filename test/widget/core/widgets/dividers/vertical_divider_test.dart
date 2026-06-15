import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/dividers/vertical_divider.dart';

void main() {
  testWidgets('AppVerticalDivider uses default values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppVerticalDivider())),
    );

    final widget = tester.widget<AppVerticalDivider>(
      find.byType(AppVerticalDivider),
    );

    expect(widget.height, 48);
    expect(widget.width, 32);
  });

  testWidgets('AppVerticalDivider applies custom height and width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppVerticalDivider(height: 64, width: 16)),
      ),
    );

    final widget = tester.widget<AppVerticalDivider>(
      find.byType(AppVerticalDivider),
    );

    expect(widget.height, 64);
    expect(widget.width, 16);
  });
}
