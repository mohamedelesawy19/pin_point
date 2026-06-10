import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/home/presentation/widgets/home_header.dart';

void main() {
  group('HomeHeader', () {
    Widget buildWidget() => const MaterialApp(
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      home: Scaffold(body: HomeHeader()),
    );

    testWidgets('renders location icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    });

    testWidgets('renders app name', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('PinPoint'), findsOneWidget);
    });
  });
}
