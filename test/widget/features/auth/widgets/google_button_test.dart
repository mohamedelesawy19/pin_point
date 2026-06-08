import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_point/core/localization/localization_delegate.dart';
import 'package:pin_point/features/auth/presentation/widgets/google_button.dart';

void main() {
  group('GoogleButton', () {
    Widget buildWidget({required VoidCallback onPressed}) {
      return MaterialApp(
        localizationsDelegates: LocalizationConfig.localizationsDelegates,
        supportedLocales: LocalizationConfig.supportedLocales,
        home: Scaffold(body: GoogleButton(onPressed: onPressed)),
      );
    }

    testWidgets('should render ElevatedButton with google icon and text', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));

      expect(find.byType(GoogleButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildWidget(
          onPressed: () {
            pressed = true;
          },
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('should display correct google asset', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));

      final image = tester.widget<Image>(find.byType(Image));

      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, 'assets/icons/google.png');
    });

    testWidgets('should have correct icon size', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);

      expect(sizedBox.width, 21);
      expect(sizedBox.height, 21);
    });
  });
}
