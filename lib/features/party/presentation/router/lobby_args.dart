// Package imports:
import 'package:equatable/equatable.dart';

// Feature imports:
import '/features/party/presentation/screens/lobby_screen.dart';

class LobbyArgs extends Equatable {
  const LobbyArgs({
    required this.currentUserId,
    this.roomCode,
    this.entrySource = LobbyEntrySource.create,
  });

  final String currentUserId;
  final String? roomCode;
  final LobbyEntrySource entrySource;

  @override
  List<Object?> get props => [currentUserId, roomCode, entrySource];
}
