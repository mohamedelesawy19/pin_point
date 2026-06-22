// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/repositories/game_repository.dart';

class GetLandmarksUseCase
    implements UseCase<List<LandmarkEntity>, SingleParam<int>> {
  const GetLandmarksUseCase(this._repository);

  final GameRepository _repository;

  @override
  Future<Either<Failure, List<LandmarkEntity>>> call(
    SingleParam<int> params,
  ) async {
    final count = params.value;
    // Fetch a larger pool than needed so shuffling gives more variety.
    final poolSize = (count * 2).clamp(count, 20);

    final result = await _repository.getLandmarks(count: poolSize);

    return result.map((landmarks) {
      final shuffled = List<LandmarkEntity>.from(landmarks)..shuffle();
      return shuffled.take(count).toList();
    });
  }
}
