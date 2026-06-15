import 'package:equatable/equatable.dart';

class LobbyArgs extends Equatable {
  const LobbyArgs({required this.currentUserId});

  final String currentUserId;

  @override
  List<Object?> get props => [currentUserId];
}
