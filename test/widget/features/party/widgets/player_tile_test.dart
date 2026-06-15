import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/presentation/widgets/player_tile.dart';

void main() {
  group('PlayerTile', () {
    const testPlayer = PlayerEntity(
      uid: '1',
      displayName: 'Mohamed',
      isAnonymous: false,
      score: 0,
    );

    Widget buildWidget({
      required PlayerEntity player,
      bool isHost = false,
      bool canKick = false,
      VoidCallback? onKick,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlayerTile(
            player: player,
            isHost: isHost,
            canKick: canKick,
            onKick: onKick ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders player name', (tester) async {
      await tester.pumpWidget(buildWidget(player: testPlayer));

      expect(find.text('Mohamed'), findsOneWidget);
    });

    testWidgets('shows kick button when canKick is true', (tester) async {
      await tester.pumpWidget(buildWidget(player: testPlayer, canKick: true));

      expect(find.byIcon(Icons.remove_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('does NOT show kick button when canKick is false', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(player: testPlayer));

      expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNothing);
    });

    testWidgets('shows host icon when isHost is true', (tester) async {
      await tester.pumpWidget(buildWidget(player: testPlayer, isHost: true));

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('does not show host icon when isHost is false', (tester) async {
      await tester.pumpWidget(buildWidget(player: testPlayer));

      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('calls onKick when kick button is pressed', (tester) async {
      var kicked = false;

      await tester.pumpWidget(
        buildWidget(
          player: testPlayer,
          canKick: true,
          onKick: () => kicked = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_circle_outline_rounded));
      await tester.pump();

      expect(kicked, true);
    });

    testWidgets('renders initials when photoUrl is null', (tester) async {
      await tester.pumpWidget(buildWidget(player: testPlayer));

      expect(find.text('M'), findsOneWidget);
    });
  });
}
