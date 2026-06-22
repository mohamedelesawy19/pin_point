import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/usecases/usecase.dart';
import 'package:pin_point/features/game/domain/entities/game_session_entity.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/watch_game_session_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late WatchGameSessionUseCase useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = WatchGameSessionUseCase(mockRepository);
  });

  test('should return game session stream from repository', () async {
    const session = GameSessionEntity(
      partyCode: 'ABC123',
      hostId: 'host_1',
      status: GameStatus.initializing,
      currentRoundIndex: 0,
      totalRounds: 5,
      playerScores: {'player_1': 0, 'player_2': 0},
    );

    final stream = Stream.value(session);

    when(
      () => mockRepository.watchGameSession('ABC123'),
    ).thenAnswer((_) => stream);

    final result = useCase(const SingleParam('ABC123'));

    expect(result, emitsInOrder([session, emitsDone]));

    verify(() => mockRepository.watchGameSession('ABC123')).called(1);

    verifyNoMoreInteractions(mockRepository);
  });
}
