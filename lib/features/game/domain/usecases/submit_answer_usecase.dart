// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/repositories/game_repository.dart';

class SubmitAnswerUseCase implements UseCase<Unit, SubmitAnswerParams> {
  const SubmitAnswerUseCase(this._repository);

  final GameRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SubmitAnswerParams params) =>
      _repository.submitAnswer(
        partyCode: params.partyCode,
        playerId: params.playerId,
        playerName: params.playerName,
        photoUrl: params.photoUrl,
        roundIndex: params.roundIndex,
        latitude: params.latitude,
        longitude: params.longitude,
      );
}

class SubmitAnswerParams extends UseCaseParams {
  const SubmitAnswerParams({
    required this.partyCode,
    required this.playerId,
    required this.playerName,
    this.photoUrl,
    required this.roundIndex,
    required this.latitude,
    required this.longitude,
  });

  final String partyCode;
  final String playerId;
  final String playerName;
  final String? photoUrl;
  final int roundIndex;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [
    partyCode,
    playerId,
    roundIndex,
    latitude,
    longitude,
  ];
}
