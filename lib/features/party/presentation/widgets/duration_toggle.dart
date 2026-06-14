// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/theme/theme_extensions.dart';
import '/core/widgets/chips/selectable_chip.dart';

class DurationToggle extends StatelessWidget {
  const DurationToggle({
    super.key,
    required this.selected,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  final int selected;
  final List<int> options;

  /// Maps each option value to a display label — e.g. `(30) => 'Fast'`.
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          Expanded(
            child: SelectableChip(
              isSelected: selected == options[i],
              onTap: () => onChanged(options[i]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${options[i]}s',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected == options[i]
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    labelBuilder(options[i]),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selected == options[i]
                          ? theme.colorScheme.onPrimary.withAlpha(200)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (i < options.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
