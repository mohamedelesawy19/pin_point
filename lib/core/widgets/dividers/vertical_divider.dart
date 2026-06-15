// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/theme/theme_extensions.dart';

class AppVerticalDivider extends StatelessWidget {
  const AppVerticalDivider({super.key, this.height = 48, this.width = 32});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        width: width,
        color: context.theme.colorScheme.outlineVariant,
      ),
    );
  }
}
