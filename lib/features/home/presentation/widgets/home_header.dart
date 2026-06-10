// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on_rounded,
          color: context.colorScheme.primary,
          size: 36,
        ), // Red Pin
        const SizedBox(width: 8),
        Text(
          context.l10n.appName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
