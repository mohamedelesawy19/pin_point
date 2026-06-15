import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/localization/generated/app_localizations.dart';
import 'package:pin_point/features/party/presentation/widgets/lobby_app_bar.dart';

class MockLeaveCallback extends Mock {
  void call();
}

Widget _buildTestWidget({required LobbyAppBar child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(appBar: child),
  );
}

void main() {
  late MockLeaveCallback mockLeave;

  setUp(() {
    mockLeave = MockLeaveCallback();
  });

  testWidgets('renders LobbyAppBar with correct title', (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(
        child: LobbyAppBar(partyName: 'Test Party', onLeave: mockLeave.call),
      ),
    );

    expect(find.text('Test Party'), findsOneWidget);
    expect(find.byIcon(Icons.exit_to_app_rounded), findsOneWidget);
  });

  testWidgets('shows confirm dialog when leave button is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestWidget(
        child: LobbyAppBar(partyName: 'Party', onLeave: mockLeave.call),
      ),
    );

    await tester.tap(find.byIcon(Icons.exit_to_app_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('calls onLeave when user confirms leaving', (tester) async {
    when(() => mockLeave()).thenReturn(null);

    await tester.pumpWidget(
      _buildTestWidget(
        child: LobbyAppBar(partyName: 'Party', onLeave: mockLeave.call),
      ),
    );

    await tester.tap(find.byIcon(Icons.exit_to_app_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    verify(() => mockLeave()).called(1);
  });

  testWidgets('does NOT call onLeave when user cancels', (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(
        child: LobbyAppBar(partyName: 'Party', onLeave: mockLeave.call),
      ),
    );

    await tester.tap(find.byIcon(Icons.exit_to_app_rounded));
    await tester.pumpAndSettle();

    // Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => mockLeave());
  });
}
