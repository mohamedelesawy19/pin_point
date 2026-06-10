// Flutter imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, cs.outlineVariant],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            context.l10n.or,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.outline,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.outlineVariant, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
