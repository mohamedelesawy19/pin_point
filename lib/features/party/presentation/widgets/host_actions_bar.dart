// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/buttons/primary_button.dart';

class HostActionsBar extends StatelessWidget {
  const HostActionsBar({
    super.key,
    required this.partyCode,
    required this.canStart,
    required this.isActionLoading,
    required this.onCopyCode,
    required this.onStartGame,
    required this.minPlayersToStart,
  });

  final String partyCode;
  final bool canStart;
  final bool isActionLoading;
  final VoidCallback onCopyCode;
  final VoidCallback onStartGame;
  final int minPlayersToStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Waiting hint ─────────────────────────────────────────────
            if (!canStart)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  context.l10n.waitingForPlayers(minPlayersToStart),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            Row(
              children: [
                // ── Copy invite code ─────────────────────────────────────
                Expanded(
                  child: PrimaryButton(
                    text: partyCode,
                    leading: const Icon(Icons.copy_rounded),
                    onPressed: onCopyCode,
                    foregroundColor: context.colorScheme.surface,
                    backgroundColor: context.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(width: 12),

                // ── Start game ───────────────────────────────────────────
                Expanded(
                  child: PrimaryButton(
                    text: isActionLoading
                        ? context.l10n.startingGame
                        : context.l10n.startGame,
                    leading: const Icon(Icons.play_arrow_rounded),
                    onPressed: onStartGame,
                    isLoading: isActionLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
