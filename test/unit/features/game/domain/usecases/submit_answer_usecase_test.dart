import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/submit_answer_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late SubmitAnswerUseCase useCase;
  late MockGameRepository mockRepository;

  const params = SubmitAnswerParams(
    partyCode: 'ABC123',
    playerId: 'player_1',
    playerName: 'Ahmed',
    photoUrl: 'https://example.com/photo.jpg',
    roundIndex: 0,
    latitude: 30.0444,
    longitude: 31.2357,
  );

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = SubmitAnswerUseCase(mockRepository);
  });

  group('SubmitAnswerUseCase', () {
    test('should submit answer successfully', () async {
      when(
        () => mockRepository.submitAnswer(
          partyCode: any(named: 'partyCode'),
          playerId: any(named: 'playerId'),
          playerName: any(named: 'playerName'),
          photoUrl: any(named: 'photoUrl'),
          roundIndex: any(named: 'roundIndex'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(params);

      expect(result, const Right(unit));

      verify(
        () => mockRepository.submitAnswer(
          partyCode: params.partyCode,
          playerId: params.playerId,
          playerName: params.playerName,
          photoUrl: params.photoUrl,
          roundIndex: params.roundIndex,
          latitude: params.latitude,
          longitude: params.longitude,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      const failure = ServerFailure(message: 'Failed to submit answer');

      when(
        () => mockRepository.submitAnswer(
          partyCode: any(named: 'partyCode'),
          playerId: any(named: 'playerId'),
          playerName: any(named: 'playerName'),
          photoUrl: any(named: 'photoUrl'),
          roundIndex: any(named: 'roundIndex'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(params);

      expect(result, const Left(failure));

      verify(
        () => mockRepository.submitAnswer(
          partyCode: params.partyCode,
          playerId: params.playerId,
          playerName: params.playerName,
          photoUrl: params.photoUrl,
          roundIndex: params.roundIndex,
          latitude: params.latitude,
          longitude: params.longitude,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });
  });
}
