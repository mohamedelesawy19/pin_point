import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/features/party/presentation/widgets/host_actions_bar.dart';

class MockCallback extends Mock {
  void call();
}

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  late MockCallback onCopy;
  late MockCallback onStart;

  setUp(() {
    onCopy = MockCallback();
    onStart = MockCallback();
  });

  testWidgets('calls onCopyCode when copy button pressed', (tester) async {
    when(() => onCopy()).thenReturn(null);

    await tester.pumpWidget(
      buildTestWidget(
        HostActionsBar(
          partyCode: 'ABC123',
          canStart: true,
          isActionLoading: false,
          onCopyCode: onCopy.call,
          onStartGame: onStart.call,
          minPlayersToStart: 3,
        ),
      ),
    );

    await tester.tap(find.text('ABC123'));
    await tester.pumpAndSettle();

    verify(() => onCopy()).called(1);
  });

  testWidgets('calls onStartGame when start button pressed', (tester) async {
    when(() => onStart()).thenReturn(null);

    await tester.pumpWidget(
      buildTestWidget(
        HostActionsBar(
          partyCode: 'ABC123',
          canStart: true,
          isActionLoading: false,
          onCopyCode: onCopy.call,
          onStartGame: onStart.call,
          minPlayersToStart: 3,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pumpAndSettle();

    verify(() => onStart()).called(1);
  });
}
