// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/buttons/primary_button.dart';
import '/core/widgets/cards/section_card.dart';
import '/core/widgets/feedback/snackbar.dart';

// Feature imports:
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/presentation/bloc/party_bloc.dart';
import '/features/party/presentation/widgets/duration_toggle.dart';
import '/features/party/presentation/widgets/game_summary_banner.dart';
import '/features/party/presentation/widgets/rounds_selector.dart';

/// Form screen where the host configures and creates a new party.
///
/// Collects:
///   • Party name
///   • Round duration (30 s or 60 s)
///   • Total number of rounds
///
/// On success ([PartyBlocStatus.inLobby]), replaces itself with [LobbyScreen]
/// so the back-stack becomes **Home → Lobby** (no dangling Create screen).
class CreatePartyScreen extends StatefulWidget {
  const CreatePartyScreen({super.key});

  @override
  State<CreatePartyScreen> createState() => _CreatePartyScreenState();
}

class _CreatePartyScreenState extends State<CreatePartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partyNameController = TextEditingController();

  int _roundDurationSeconds = 60;
  int _totalRounds = 5;

  @override
  void dispose() {
    _partyNameController.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onDurationChanged(int value) =>
      setState(() => _roundDurationSeconds = value);

  void _onRoundsChanged(int value) => setState(() => _totalRounds = value);

  void _onCreateParty() {
    if (!_formKey.currentState!.validate()) return;

    context.read<PartyBloc>().add(
      CreatePartyEvent(
        partyName: _partyNameController.text.trim(),
        settings: PartySettings(
          roundDurationSeconds: _roundDurationSeconds,
          totalRounds: _totalRounds,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<PartyBloc, PartyState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.actionError != current.actionError,
      listener: _handleStateChange,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.createAParty)),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              // ── Party name ───────────────────────────────────────────────
              SectionCard(
                title: context.l10n.partyName,
                child: _PartyNameField(controller: _partyNameController),
              ),

              const SizedBox(height: 32),

              // ── Round duration ───────────────────────────────────────────
              SectionCard(
                title: context.l10n.roundDuration,
                child: DurationToggle(
                  selected: _roundDurationSeconds,
                  options: FirestoreConstants.durationOptions,
                  labelBuilder: (d) {
                    switch (d) {
                      case 30:
                        return context.l10n.fast;
                      case 60:
                        return context.l10n.standard;
                      default:
                        return '${d}s';
                    }
                  },
                  onChanged: _onDurationChanged,
                ),
              ),

              const SizedBox(height: 32),

              // ── Total rounds ─────────────────────────────────────────────
              SectionCard(
                title: context.l10n.numberOfRounds,
                child: RoundsSelector(
                  selected: _totalRounds,
                  options: FirestoreConstants.roundOptions,
                  onChanged: _onRoundsChanged,
                ),
              ),

              const SizedBox(height: 32),

              // ── Summary ──────────────────────────────────────────────────
              GameSummaryBanner(
                rounds: _totalRounds,
                durationSeconds: _roundDurationSeconds,
              ),

              const SizedBox(height: 28),

              // ── CTA ──────────────────────────────────────────────────────
              BlocBuilder<PartyBloc, PartyState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) {
                  final isLoading = state.status == PartyBlocStatus.loading;
                  return PrimaryButton(
                    text: isLoading
                        ? context.l10n.creatingParty
                        : context.l10n.createParty,
                    leading: const Icon(Icons.celebration_rounded),
                    onPressed: _onCreateParty,
                    isLoading: isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _handleStateChange(BuildContext context, PartyState state) {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    if (state.isInLobby) {
      // context.pushReplacement(AppRoutes.lobbyScreen);
      return;
    }

    if (state.actionError != null) {
      CustomSnackbar.error(context: context, message: state.actionError!);
    }
  }
}

// ─── Private widgets ─────────────────────────────────────────────────────────

class _PartyNameField extends StatelessWidget {
  const _PartyNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      maxLength: 24,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.group_rounded),
        // Hide the default counter; we enforce maxLength silently.
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) return context.l10n.partyNameEmpty;
        if (trimmed.length < 2) return context.l10n.partyNameTooShort;
        return null;
      },
    );
  }
}
