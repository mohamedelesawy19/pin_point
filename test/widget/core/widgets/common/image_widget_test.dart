import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_point/core/widgets/common/image_widget.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

void main() {
  group('ImageWidget', () {
    testWidgets('renders CachedNetworkImage with provided properties', (
      tester,
    ) async {
      const imageUrl = 'https://example.com/image.png';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageWidget(src: imageUrl, width: 120, height: 80),
          ),
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      expect(cachedImage.imageUrl, imageUrl);
      expect(cachedImage.width, 120);
      expect(cachedImage.height, 80);
      expect(cachedImage.fit, BoxFit.cover);
    });

    testWidgets('placeholder builder returns Shimmer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageWidget(src: 'https://example.com/image.png'),
          ),
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      final placeholder = cachedImage.placeholder!(
        tester.element(find.byType(CachedNetworkImage)),
        '',
      );

      expect(placeholder, isA<Shimmer>());
    });

    testWidgets('errorWidget builder returns image icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageWidget(src: 'https://example.com/image.png'),
          ),
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      final errorWidget = cachedImage.errorWidget!(
        tester.element(find.byType(CachedNetworkImage)),
        '',
        Exception(),
      );

      expect(errorWidget, isA<Icon>());

      final icon = errorWidget as Icon;

      expect(icon.icon, Icons.image);
      expect(icon.size, 18);
    });

    testWidgets('renders correctly when width and height are null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageWidget(src: 'https://example.com/image.png'),
          ),
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      expect(cachedImage.width, isNull);
      expect(cachedImage.height, isNull);
    });
  });
}
