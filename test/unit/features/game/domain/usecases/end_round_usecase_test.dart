import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/entities/player_answer_entity.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/calculate_distance_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/calculate_score_usecase.dart';
import 'package:pin_point/features/game/domain/usecases/end_round_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

class MockCalculateDistanceUseCase extends Mock
    implements CalculateDistanceUseCase {}

class MockCalculateScoreUseCase extends Mock implements CalculateScoreUseCase {}

void main() {
  late EndRoundUseCase useCase;
  late MockGameRepository mockRepository;
  late MockCalculateDistanceUseCase mockDistance;
  late MockCalculateScoreUseCase mockScore;
  late EndRoundParams params;

  late PlayerAnswerEntity answer1;
  late PlayerAnswerEntity answer2;

  setUp(() {
    mockRepository = MockGameRepository();
    mockDistance = MockCalculateDistanceUseCase();
    mockScore = MockCalculateScoreUseCase();
    params = const EndRoundParams(
      partyCode: 'party123',
      hostId: 'host123',
      roundIndex: 0,
      landmark: LandmarkEntity(
        id: '1',
        name: 'Pyramids',
        imageUrl: '',
        actualLatitude: 29.9792,
        actualLongitude: 31.1342,
      ),
      currentPlayerScores: {'p1': 100, 'p2': 50},
    );

    answer1 = PlayerAnswerEntity(
      playerId: 'p1',
      playerName: 'Ahmed',
      photoUrl: '',
      roundIndex: 0,
      latitude: 30,
      longitude: 31,
      distanceKm: 0,
      score: 0,
      submittedAt: DateTime.now(),
    );

    answer2 = PlayerAnswerEntity(
      playerId: 'p2',
      playerName: 'Ali',
      photoUrl: '',
      roundIndex: 0,
      latitude: 30.5,
      longitude: 31.5,
      distanceKm: 0,
      score: 0,
      submittedAt: DateTime.now(),
    );
    useCase = EndRoundUseCase(
      repository: mockRepository,
      calculateDistance: mockDistance,
      calculateScore: mockScore,
    );
  });

  test('should return failure when getRoundAnswers fails', () async {
    const failure = ServerFailure(message: 'Server Faliure');

    when(
      () => mockRepository.getRoundAnswers(
        partyCode: any(named: 'partyCode'),
        roundIndex: any(named: 'roundIndex'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase(params);

    expect(result, const Left(failure));

    verify(
      () => mockRepository.getRoundAnswers(
        partyCode: params.partyCode,
        roundIndex: params.roundIndex,
      ),
    ).called(1);

    verifyNever(
      () => mockRepository.endRound(
        partyCode: any(named: 'partyCode'),
        hostId: any(named: 'hostId'),
        roundIndex: any(named: 'roundIndex'),
        processedAnswers: any(named: 'processedAnswers'),
        updatedPlayerScores: any(named: 'updatedPlayerScores'),
      ),
    );
  });

  test(
    'should calculate distances, scores and persist round results',
    () async {
      final rawAnswers = [
        PlayerAnswerEntity(
          playerId: 'p1',
          playerName: 'Ahmed',
          photoUrl: '',
          roundIndex: 0,
          latitude: 30,
          longitude: 31,
          distanceKm: 0,
          score: 0,
          submittedAt: DateTime.now(),
        ),
      ];

      when(
        () => mockRepository.getRoundAnswers(
          partyCode: any(named: 'partyCode'),
          roundIndex: any(named: 'roundIndex'),
        ),
      ).thenAnswer((_) async => Right(rawAnswers));

      when(
        () => mockDistance(
          lat1: any(named: 'lat1'),
          lon1: any(named: 'lon1'),
          lat2: any(named: 'lat2'),
          lon2: any(named: 'lon2'),
        ),
      ).thenReturn(25);

      when(() => mockScore(25)).thenReturn(30);

      when(
        () => mockRepository.endRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          processedAnswers: any(named: 'processedAnswers'),
          updatedPlayerScores: any(named: 'updatedPlayerScores'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(params);

      expect(result, const Right(unit));

      verify(
        () => mockDistance(
          lat1: 30,
          lon1: 31,
          lat2: params.landmark.actualLatitude,
          lon2: params.landmark.actualLongitude,
        ),
      ).called(1);

      verify(() => mockScore(25)).called(1);

      verify(
        () => mockRepository.endRound(
          partyCode: params.partyCode,
          hostId: params.hostId,
          roundIndex: params.roundIndex,
          processedAnswers: any(named: 'processedAnswers'),
          updatedPlayerScores: any(named: 'updatedPlayerScores'),
        ),
      ).called(1);
    },
  );

  test('should accumulate scores correctly', () async {
    final rawAnswers = [answer1, answer2];

    when(
      () => mockRepository.getRoundAnswers(
        partyCode: any(named: 'partyCode'),
        roundIndex: any(named: 'roundIndex'),
      ),
    ).thenAnswer((_) async => Right(rawAnswers));

    when(
      () => mockDistance(
        lat1: any(named: 'lat1'),
        lon1: any(named: 'lon1'),
        lat2: any(named: 'lat2'),
        lon2: any(named: 'lon2'),
      ),
    ).thenReturn(20);

    when(() => mockScore(20)).thenReturn(30);

    Map<String, int>? capturedScores;

    when(
      () => mockRepository.endRound(
        partyCode: any(named: 'partyCode'),
        hostId: any(named: 'hostId'),
        roundIndex: any(named: 'roundIndex'),
        processedAnswers: any(named: 'processedAnswers'),
        updatedPlayerScores: any(named: 'updatedPlayerScores'),
      ),
    ).thenAnswer((invocation) async {
      capturedScores =
          invocation.namedArguments[#updatedPlayerScores] as Map<String, int>;

      return const Right(unit);
    });

    await useCase(params);

    expect(capturedScores, {'p1': 130, 'p2': 80});
  });
}
