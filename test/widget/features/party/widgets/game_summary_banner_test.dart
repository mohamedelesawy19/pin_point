import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/party/presentation/widgets/game_summary_banner.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('GameSummaryBanner shows minutes and seconds correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        const GameSummaryBanner(
          rounds: 2,
          durationSeconds: 90, // 2 * 90 = 180s => 3m
        ),
      ),
    );

    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.textContaining('m'), findsOneWidget);
    expect(find.textContaining('Estimated'), findsWidgets);
  });

  testWidgets('GameSummaryBanner shows only seconds when under 60s', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        const GameSummaryBanner(
          rounds: 1,
          durationSeconds: 45, // 45s
        ),
      ),
    );

    expect(find.textContaining('45s'), findsOneWidget);
  });

  testWidgets('GameSummaryBanner shows only minutes when seconds = 0', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        const GameSummaryBanner(
          rounds: 2,
          durationSeconds: 60, // 120s => 2m
        ),
      ),
    );

    expect(find.textContaining('2m'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+s')), findsNothing);
  });

  testWidgets('GameSummaryBanner renders container with icon and text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(const GameSummaryBanner(rounds: 1, durationSeconds: 30)),
    );

    expect(find.byType(Container), findsOneWidget);
    expect(find.byType(Row), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.byType(Text), findsWidgets);
  });
}
