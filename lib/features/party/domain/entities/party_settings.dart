import 'package:equatable/equatable.dart';

class PartySettings extends Equatable {
  const PartySettings({
    required this.roundDurationSeconds,
    required this.totalRounds,
  });

  final int roundDurationSeconds; // 30 or 60
  final int totalRounds;

  @override
  List<Object?> get props => [roundDurationSeconds, totalRounds];
}
