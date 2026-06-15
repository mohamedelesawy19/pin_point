// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

class LobbyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LobbyAppBar({
    super.key,
    required this.partyName,
    required this.onLeave,
  });

  final String partyName;
  final VoidCallback onLeave;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(partyName),
      actions: [_LeaveButton(onLeave: onLeave)],
    );
  }
}

// ── Leave button ─────────────────────────────────────────────────────────────

class _LeaveButton extends StatelessWidget {
  const _LeaveButton({required this.onLeave});

  final VoidCallback onLeave;

  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.leaveParty),
        content: Text(context.l10n.leavePartyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.leave,
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    onLeave.call();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app_rounded),
      tooltip: context.l10n.leaveParty,
      onPressed: () => _confirmLeave(context),
    );
  }
}
