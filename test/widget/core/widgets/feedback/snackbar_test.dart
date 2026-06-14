import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/widgets/feedback/snackbar.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('shows info snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CustomSnackbar.info(context: context, message: 'Info message');
              },
              child: const Text('show'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump(); // show snackbar animation

    expect(find.text('Info message'), findsOneWidget);
  });

  testWidgets('shows success snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CustomSnackbar.success(context: context, message: 'Success!');
              },
              child: const Text('show'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Success!'), findsOneWidget);
  });

  testWidgets('shows snackbar with action button and triggers callback', (
    WidgetTester tester,
  ) async {
    bool actionPressed = false;

    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CustomSnackbar.show(
                  context: context,
                  message: 'With Action',
                  actionLabel: 'UNDO',
                  onActionPressed: () {
                    actionPressed = true;
                  },
                );
              },
              child: const Text('show'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.text('With Action'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(actionPressed, true);
  });

  testWidgets('shows error snackbar with close icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CustomSnackbar.error(
                  context: context,
                  message: 'Error occurred',
                );
              },
              child: const Text('show'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Error occurred'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('hide snackbar works', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CustomSnackbar.info(context: context, message: 'Hide me');

                Future.delayed(const Duration(milliseconds: 100), () {
                  CustomSnackbar.hide(context);
                });
              },
              child: const Text('show'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Hide me'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Hide me'), findsNothing);
  });
}
