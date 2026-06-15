// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/dividers/vertical_divider.dart';

// Feature imports:
import '/features/party/domain/entities/party_settings.dart';

class LobbySettingsCard extends StatelessWidget {
  const LobbySettingsCard({super.key, required this.settings});

  final PartySettings settings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SettingItem(
            icon: Icons.timer_rounded,
            label: context.l10n.roundDuration,
            value: '${settings.roundDurationSeconds}s',
          ),
        ),
        const AppVerticalDivider(),
        Expanded(
          child: _SettingItem(
            icon: Icons.repeat_rounded,
            label: context.l10n.numberOfRounds,
            value: '${settings.totalRounds}',
          ),
        ),
      ],
    );
  }
}

// ── Setting item ─────────────────────────────────────────────────────────────

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
