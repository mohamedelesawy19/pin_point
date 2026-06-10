import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/auth/presentation/widgets/google_button.dart';

void main() {
  group('GoogleButton', () {
    Widget buildWidget({required VoidCallback onPressed}) => MaterialApp(
      localizationsDelegates: LocalizationConfig.localizationsDelegates,
      supportedLocales: LocalizationConfig.supportedLocales,
      home: Scaffold(body: GoogleButton(onPressed: onPressed)),
    );

    testWidgets('renders button with icon and text', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildWidget(onPressed: () => pressed = true));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('displays google asset image', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, 'assets/icons/google.png');
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 21);
      expect(sizedBox.height, 21);
    });
  });
}
