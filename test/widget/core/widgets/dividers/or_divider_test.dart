import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/core/widgets/dividers/or_divider.dart';

void main() {
  group('OrDivider', () {
    Widget buildWidget() => const MaterialApp(
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      home: Scaffold(body: OrDivider()),
    );

    testWidgets('renders text in center', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('has correct row structure with two dividers', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 3);
      expect(find.byType(Expanded), findsNWidgets(2));
      expect(find.byType(Container), findsNWidgets(2));
    });

    testWidgets('text has correct style', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, 12);
      expect(text.style?.fontWeight, FontWeight.w700);
    });
  });
}
