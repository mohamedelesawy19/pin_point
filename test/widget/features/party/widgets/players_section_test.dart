import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/presentation/widgets/player_tile.dart';
import 'package:pin_point/features/party/presentation/widgets/players_section.dart';

void main() {
  group('PlayersSection', () {
    const hostId = 'host';

    PlayerEntity player(String id, {String? name}) => PlayerEntity(
      uid: id,
      displayName: name ?? id,
      isAnonymous: false,
      score: 0,
    );

    Widget buildWidget({
      required List<PlayerEntity> players,
      int maxPlayers = 3,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlayersSection(
            players: players,
            hostId: hostId,
            isHost: true,
            maxPlayers: maxPlayers,
            onKick: (_) {},
          ),
        ),
      );
    }

    testWidgets('renders header with correct counts', (tester) async {
      await tester.pumpWidget(
        buildWidget(players: [player('1'), player('2')], maxPlayers: 4),
      );

      expect(find.text('2 / 4'), findsOneWidget);
    });

    testWidgets('renders correct number of PlayerTiles', (tester) async {
      await tester.pumpWidget(buildWidget(players: [player('1'), player('2')]));

      // 2 players → 2 PlayerTile widgets
      expect(find.byType(PlayerTile), findsNWidgets(2));
    });

    testWidgets('marks host correctly via icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(players: [player('host'), player('2')], maxPlayers: 2),
      );

      // host icon should exist once
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('passes canKick correctly (host only)', (tester) async {
      await tester.pumpWidget(
        buildWidget(players: [player('host'), player('2')], maxPlayers: 2),
      );

      // host can't kick himself → only one kick button possible
      expect(find.byIcon(Icons.remove_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty slots when lobby not full', (tester) async {
      await tester.pumpWidget(buildWidget(players: [player('1')]));

      // 1 player + 2 empty slots
      expect(find.text('...'), findsNWidgets(2));
      expect(find.byIcon(Icons.person_add_rounded), findsNWidgets(2));
    });

    testWidgets('renders no empty slots when full', (tester) async {
      await tester.pumpWidget(
        buildWidget(players: [player('1'), player('2'), player('3')]),
      );

      expect(find.text('...'), findsNothing);
      expect(find.byIcon(Icons.person_add_rounded), findsNothing);
    });

    testWidgets('empty state works when no players', (tester) async {
      await tester.pumpWidget(buildWidget(players: [], maxPlayers: 2));

      expect(find.byType(PlayerTile), findsNothing);
      expect(find.text('...'), findsNWidgets(2));
    });
  });
}
