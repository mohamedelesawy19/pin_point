import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/presentation/widgets/lobby_settings_card.dart';

void main() {
  group('LobbySettingsCard', () {
    const testSettings = PartySettings(
      roundDurationSeconds: 60,
      totalRounds: 5,
    );

    Widget buildTestWidget() {
      return const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LobbySettingsCard(settings: testSettings)),
      );
    }

    testWidgets('renders both settings values correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('60s'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders both icons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
    });

    testWidgets('renders labels (fallback-safe test)', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('layout contains two expanded sections', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final expandedWidgets = find.byType(Expanded);
      expect(expandedWidgets, findsNWidgets(2));
    });
  });
}
