// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/theme/theme_extensions.dart';
import '/core/widgets/chips/selectable_chip.dart';

class RoundsSelector extends StatelessWidget {
  const RoundsSelector({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final int selected;
  final List<int> options;
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
              child: Text(
                '${options[i]}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected == options[i]
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (i < options.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
