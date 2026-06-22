import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/initialize_game_session_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late InitializeGameSessionUseCase useCase;
  late MockGameRepository mockRepository;

  const params = InitializeGameSessionParams(
    partyCode: 'ABC123',
    hostId: 'host_1',
    totalRounds: 5,
    initialPlayerScores: {'player1': 0, 'player2': 0},
  );

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = InitializeGameSessionUseCase(mockRepository);
  });

  group('InitializeGameSessionUseCase', () {
    test('should initialize game session successfully', () async {
      when(
        () => mockRepository.initializeGameSession(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          totalRounds: any(named: 'totalRounds'),
          initialPlayerScores: any(named: 'initialPlayerScores'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(params);

      expect(result, const Right(unit));

      verify(
        () => mockRepository.initializeGameSession(
          partyCode: params.partyCode,
          hostId: params.hostId,
          totalRounds: params.totalRounds,
          initialPlayerScores: params.initialPlayerScores,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      const failure = ServerFailure(
        message: 'Failed to initialize game session',
      );

      when(
        () => mockRepository.initializeGameSession(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          totalRounds: any(named: 'totalRounds'),
          initialPlayerScores: any(named: 'initialPlayerScores'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(params);

      expect(result, const Left(failure));

      verify(
        () => mockRepository.initializeGameSession(
          partyCode: params.partyCode,
          hostId: params.hostId,
          totalRounds: params.totalRounds,
          initialPlayerScores: params.initialPlayerScores,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });
  });
}
