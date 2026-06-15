// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

// Feature imports:
import '/features/party/domain/entities/player_entity.dart';
import '/features/party/presentation/widgets/player_tile.dart';

class PlayersSection extends StatelessWidget {
  const PlayersSection({
    super.key,
    required this.players,
    required this.hostId,
    required this.isHost,
    required this.onKick,
    required this.maxPlayers,
  });

  final List<PlayerEntity> players;
  final String hostId;
  final bool isHost;
  final void Function(String targetUid) onKick;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _PlayersSectionHeader(
          playerCount: players.length,
          maxPlayers: maxPlayers,
        ),

        const SizedBox(height: 12),

        // ── Player tiles ─────────────────────────────────────────────────────
        ...players.map(
          (player) => PlayerTile(
            key: ValueKey(player.uid),
            player: player,
            isHost: player.uid == hostId,
            canKick: isHost && player.uid != hostId,
            onKick: () => onKick(player.uid),
          ),
        ),

        // ── Empty slots ──────────────────────────────────────────────────────
        ...List.generate(
          (maxPlayers - players.length).clamp(0, maxPlayers),
          (index) => const _EmptySlot(),
        ),
      ],
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────

class _PlayersSectionHeader extends StatelessWidget {
  const _PlayersSectionHeader({
    required this.playerCount,
    required this.maxPlayers,
  });

  final int playerCount;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Text(context.l10n.players, style: theme.textTheme.titleMedium),
        const Spacer(),
        Text(
          '$playerCount / $maxPlayers',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Empty slot ───────────────────────────────────────────────────────────────

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.person_add_rounded,
              size: 18,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '...',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
