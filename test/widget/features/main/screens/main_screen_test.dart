import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/main/presentation/screens/main_screen.dart';

void main() {
  group('MainScreen', () {
    Widget buildWidget() => const MaterialApp(
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      home: MainScreen(),
    );

    testWidgets('renders all navigation items', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('Home')), findsOneWidget);
      expect(find.byKey(const ValueKey('Explore')), findsOneWidget);
      expect(find.byKey(const ValueKey('Profile')), findsOneWidget);
    });

    testWidgets('IndexedStack starts at index 0', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);
    });

    testWidgets('IndexedStack updates index on tab change', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byKey(const ValueKey('Explore')));
      await tester.pumpAndSettle();
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);

      await tester.tap(find.byKey(const ValueKey('Profile')));
      await tester.pumpAndSettle();
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 2);

      await tester.tap(find.byKey(const ValueKey('Home')));
      await tester.pumpAndSettle();
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    });
  });
}
