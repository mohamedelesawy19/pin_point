import 'package:equatable/equatable.dart';

class LobbyArgs extends Equatable {
  const LobbyArgs({required this.currentUserId, this.roomCode});

  final String currentUserId;
  final String? roomCode;

  @override
  List<Object?> get props => [currentUserId, roomCode];
}
