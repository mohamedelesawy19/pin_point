import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/core/widgets/buttons/primary_button.dart';
import 'package:pin_point/core/widgets/dividers/or_divider.dart';
import 'package:pin_point/features/home/presentation/widgets/home_action_card.dart';

void main() {
  group('ActionCard', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    Widget buildWidget({VoidCallback? onJoin, VoidCallback? onCreate}) {
      return MaterialApp(
        localizationsDelegates: LocalizationConfig.localizationsDelegates,
        supportedLocales: LocalizationConfig.supportedLocales,
        home: Scaffold(
          body: ActionCard(
            roomCodeController: controller,
            onJoinParty: onJoin ?? () {},
            onCreateParty: onCreate ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Join a Party'), findsNWidgets(2));
      expect(find.text('Create a Party'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(OrDivider), findsOneWidget);
    });

    testWidgets('calls onJoinParty when join button is tapped', (tester) async {
      var joinCalled = false;
      await tester.pumpWidget(buildWidget(onJoin: () => joinCalled = true));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(PrimaryButton, 'Join a Party'));
      await tester.pump();

      expect(joinCalled, isTrue);
    });

    testWidgets('calls onCreateParty when create button is tapped', (
      tester,
    ) async {
      var createCalled = false;
      await tester.pumpWidget(buildWidget(onCreate: () => createCalled = true));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(PrimaryButton, 'Create a Party'));
      await tester.pump();

      expect(createCalled, isTrue);
    });
  });
}
