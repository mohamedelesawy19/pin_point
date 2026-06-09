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

    Widget createWidget({
      int selectedIndex = 0,
      bool showLabels = false,
      ValueChanged<int>? onItemSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CustomNavigationBar(
            items: items,
            selectedIndex: selectedIndex,
            showLabels: showLabels,
            onItemSelected: onItemSelected ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders all navigation items', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows badge when badge value is greater than zero', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('does not show labels by default', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Home'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('shows labels when showLabels is true', (tester) async {
      await tester.pumpWidget(createWidget(showLabels: true));

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls onItemSelected when tapping unselected item', (
      tester,
    ) async {
      int? selected;

      await tester.pumpWidget(
        createWidget(
          onItemSelected: (index) {
            selected = index;
          },
        ),
      );

      await tester.tap(find.byKey(const ValueKey('Search')));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('does not call onItemSelected when tapping selected item', (
      tester,
    ) async {
      int count = 0;

      await tester.pumpWidget(
        createWidget(
          onItemSelected: (_) {
            count++;
          },
        ),
      );

      await tester.tap(find.byKey(const ValueKey('Home')));
      await tester.pumpAndSettle();

      expect(count, 0);
    });

    testWidgets('renders correct number of icons', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Icon), findsNWidgets(3));
    });

    testWidgets(
      'animation completes without exceptions when selection changes',
      (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.pumpWidget(createWidget(selectedIndex: 2));

        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
      },
    );
  });
}
