// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/buttons/primary_button.dart';
import '/core/widgets/cards/gradient_card.dart';
import '/core/widgets/dividers/or_divider.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.roomCodeController,
    required this.onJoinParty,
    required this.onCreateParty,
  });

  final TextEditingController roomCodeController;
  final VoidCallback onJoinParty;
  final VoidCallback onCreateParty;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.joinAParty,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),

          _RoomCodeInput(controller: roomCodeController, onSubmit: onJoinParty),
          const SizedBox(height: 16),

          PrimaryButton(
            text: context.l10n.joinAParty,
            leading: const Icon(Icons.play_arrow, size: 18),
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            onPressed: onJoinParty,
          ),

          const SizedBox(height: 24),

          const OrDivider(),

          const SizedBox(height: 24),
          PrimaryButton(
            text: context.l10n.createAParty,
            leading: const Icon(Icons.add_rounded, size: 18),
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            onPressed: onCreateParty,
          ),
        ],
      ),
    );
  }
}

class _RoomCodeInput extends StatelessWidget {
  const _RoomCodeInput({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmit(),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 6,
        color: context.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: '000000',
        hintStyle: TextStyle(color: context.colorScheme.onSurfaceVariant),
        counterText: '',
        filled: true,
        fillColor: context.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colorScheme.primary, width: 3),
        ),
      ),
    );
  }
}
