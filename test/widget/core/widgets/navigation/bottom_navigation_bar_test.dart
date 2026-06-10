import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/navigation/bottom_navigation_bar.dart';

void main() {
  group('CustomNavigationBar', () {
    final items = [
      const NavBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      const NavBarItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search',
        badge: 3,
      ),
      const NavBarItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    Widget buildWidget({
      int selectedIndex = 0,
      bool showLabels = false,
      ValueChanged<int>? onItemSelected,
    }) => MaterialApp(
      home: Scaffold(
        body: CustomNavigationBar(
          items: items,
          selectedIndex: selectedIndex,
          showLabels: showLabels,
          onItemSelected: onItemSelected ?? (_) {},
        ),
      ),
    );

    testWidgets('renders all navigation items', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows badge when badge value is greater than zero', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides labels by default', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Home'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('shows labels when showLabels is true', (tester) async {
      await tester.pumpWidget(buildWidget(showLabels: true));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls onItemSelected when tapping unselected item', (
      tester,
    ) async {
      int? selected;
      await tester.pumpWidget(buildWidget(onItemSelected: (i) => selected = i));

      await tester.tap(find.byKey(const ValueKey('Search')));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('does not call onItemSelected when tapping selected item', (
      tester,
    ) async {
      var callCount = 0;
      await tester.pumpWidget(buildWidget(onItemSelected: (_) => callCount++));

      await tester.tap(find.byKey(const ValueKey('Home')));
      await tester.pumpAndSettle();

      expect(callCount, 0);
    });

    testWidgets('completes selection animation without errors', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpWidget(buildWidget(selectedIndex: 2));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
