import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen bottom navigation changes page index', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // initial state
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(HomeScreen), findsOneWidget);

    // Items should be findable by key even if labels are hidden
    expect(find.byKey(const ValueKey('Home')), findsOneWidget);
    expect(find.byKey(const ValueKey('Explore')), findsOneWidget);
    expect(find.byKey(const ValueKey('Profile')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('Explore')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('Profile')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('Home')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('IndexedStack keeps pages alive and switches index', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(indexedStack.index, 0);

    await tester.tap(find.byKey(const ValueKey('Explore')));
    await tester.pumpAndSettle();

    final indexedStack1 = tester.widget<IndexedStack>(
      find.byType(IndexedStack),
    );
    expect(indexedStack1.index, 1);

    await tester.tap(find.byKey(const ValueKey('Profile')));
    await tester.pumpAndSettle();

    final indexedStack2 = tester.widget<IndexedStack>(
      find.byType(IndexedStack),
    );
    expect(indexedStack2.index, 2);
  });
}
