// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/common/image_widget.dart';

// Feature imports:
import '/features/party/domain/entities/player_entity.dart';

class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    required this.isHost,
    required this.canKick,
    required this.onKick,
  });

  final PlayerEntity player;
  final bool isHost;
  final bool canKick;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              _PlayerAvatar(player: player),
              if (isHost)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Name ──────────────────────────────────────────────────────────
          Expanded(
            child: Text(
              player.displayName,
              style: theme.textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Kick button (host only, not self) ─────────────────────────────
          if (canKick)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: theme.colorScheme.error,
              tooltip: context.l10n.kickPlayer,
              onPressed: onKick,
            ),
        ],
      ),
    );
  }
}

// ── Player avatar ────────────────────────────────────────────────────────────

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player});

  final PlayerEntity player;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (player.photoUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: ImageWidget(src: player.photoUrl!, width: 48, height: 48),
        ),
      );
    }

    // Fallback: initials from display name
    final initial = player.displayName.isNotEmpty
        ? player.displayName[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
