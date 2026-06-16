// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/localization/localization_helpers.dart';
import '/core/router/app_routes.dart';
import '/core/theme/theme_extensions.dart';
import '/core/widgets/feedback/snackbar.dart';

// Features imports:
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/presentation/bloc/party_bloc.dart';
import '/features/party/presentation/widgets/host_actions_bar.dart';
import '/features/party/presentation/widgets/lobby_app_bar.dart';
import '/features/party/presentation/widgets/lobby_settings_card.dart';
import '/features/party/presentation/widgets/players_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Smart Widget — own BLoC integration, side-effects, and navigation
// ─────────────────────────────────────────────────────────────────────────────

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key, required this.currentUserId, this.roomCode});

  final String currentUserId;
  final String? roomCode;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  // ── Events ─────────────────────────────────────────────────────────────────

  void _onLeave(BuildContext context, String partyCode) {
    context.read<PartyBloc>().add(LeavePartyEvent(partyCode: partyCode));
  }

  void _onKick(BuildContext context, String partyCode, String targetUid) {
    context.read<PartyBloc>().add(
      KickPlayerEvent(partyCode: partyCode, targetUid: targetUid),
    );
  }

  void _onStartGame(
    BuildContext context, {
    required String partyCode,
    required bool canStart,
  }) {
    if (!canStart) {
      CustomSnackbar.error(
        context: context,
        message: context.l10n.waitingForPlayers(
          FirestoreConstants.minPlayersToStart,
        ),
      );
      return;
    }
    context.read<PartyBloc>().add(StartGameEvent(partyCode: partyCode));
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onCopyCode(BuildContext context, String partyCode) async {
    await Clipboard.setData(ClipboardData(text: partyCode));
    if (!context.mounted) return;
    CustomSnackbar.success(context: context, message: context.l10n.partyCopied);
  }

  // ── State Listeners ────────────────────────────────────────────────────────

  bool _listenWhen(PartyState previous, PartyState current) {
    final statusChanged = previous.status != current.status;
    final errorChanged = previous.actionError != current.actionError;

    return statusChanged || errorChanged;
  }

  void _listener(BuildContext context, PartyState state) {
    if (state.actionError != null) {
      CustomSnackbar.error(context: context, message: state.actionError!);
    }

    if (state.hasLeft) {
      context.go(AppRoutes.main);
      return;
    }

    if (state.party?.status == PartyStatus.playing) {
      // context.go(AppRoutes.game);
      return;
    }
  }

  bool _buildWhen(PartyState previous, PartyState current) {
    final partyChanged = previous.party != current.party;

    return partyChanged;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.roomCode != null) {
      context.read<PartyBloc>().add(
        JoinPartyEvent(partyCode: widget.roomCode!),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PartyBloc, PartyState>(
      listenWhen: _listenWhen,
      listener: _listener,
      buildWhen: _buildWhen,
      builder: (context, state) {
        final party = state.party;

        // Guard: should never be null when inLobby, but stay safe.
        if (party == null) return const _LobbyLoadingView();

        final isHost = party.hostId == widget.currentUserId;

        final canStart =
            party.players.length >= FirestoreConstants.minPlayersToStart;

        return Scaffold(
          appBar: LobbyAppBar(
            partyName: party.partyName,
            onLeave: () => _onLeave(context, party.partyCode),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    children: [
                      LobbySettingsCard(settings: party.settings),
                      const SizedBox(height: 24),
                      PlayersSection(
                        players: party.players,
                        hostId: party.hostId,
                        isHost: isHost,
                        onKick: (targetUid) =>
                            _onKick(context, party.partyCode, targetUid),
                        maxPlayers: FirestoreConstants.maxPlayersPerParty,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isHost
              ? BlocBuilder<PartyBloc, PartyState>(
                  buildWhen: (p, c) => p.isActionLoading != c.isActionLoading,
                  builder: (context, state) => HostActionsBar(
                    partyCode: party.partyCode,
                    canStart: canStart,
                    isActionLoading: state.isActionLoading,
                    onCopyCode: () => _onCopyCode(context, party.partyCode),
                    onStartGame: () => _onStartGame(
                      context,
                      partyCode: party.partyCode,
                      canStart: canStart,
                    ),
                    minPlayersToStart: FirestoreConstants.minPlayersToStart,
                  ),
                )
              : null,
        );
      },
    );
  }
}

// ─── Fallback while party stream hasn't emitted yet ──────────────────────────

class _LobbyLoadingView extends StatelessWidget {
  const _LobbyLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 16),
            Text(
              context.l10n.connectingToLobby,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
