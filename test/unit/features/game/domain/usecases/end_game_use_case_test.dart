import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/end_game_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late EndGameUseCase useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = EndGameUseCase(mockRepository);
  });

  const params = EndGameParams(partyCode: 'ABC123', hostId: 'host_1');

  group('EndGameUseCase', () {
    test('should return Unit when repository ends game successfully', () async {
      // arrange
      when(
        () => mockRepository.endGame(
          partyCode: params.partyCode,
          hostId: params.hostId,
        ),
      ).thenAnswer((_) async => const Right(unit));

      // act
      final result = await useCase(params);

      // assert
      expect(result, const Right(unit));

      verify(
        () => mockRepository.endGame(
          partyCode: params.partyCode,
          hostId: params.hostId,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails to end game', () async {
      // arrange
      const failure = ServerFailure(message: 'Server Failure');

      when(
        () => mockRepository.endGame(
          partyCode: params.partyCode,
          hostId: params.hostId,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(params);

      // assert
      expect(result, const Left(failure));

      verify(
        () => mockRepository.endGame(
          partyCode: params.partyCode,
          hostId: params.hostId,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });
  });
}
