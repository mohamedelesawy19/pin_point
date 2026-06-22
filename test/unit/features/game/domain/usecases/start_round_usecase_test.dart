import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/start_round_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late StartRoundUseCase useCase;
  late MockGameRepository mockRepository;

  const landmark = LandmarkEntity(
    id: 'landmark_1',
    name: 'Pyramids',
    imageUrl: 'pyramids.jpg',
    actualLatitude: 29.9792,
    actualLongitude: 31.1342,
  );

  const params = StartRoundParams(
    partyCode: 'ABC123',
    hostId: 'host_1',
    roundIndex: 0,
    landmark: landmark,
    durationSeconds: 60,
  );

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = StartRoundUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const LandmarkEntity(
        id: 'fake',
        name: 'fake',
        imageUrl: 'fake.jpg',
        actualLatitude: 0,
        actualLongitude: 0,
      ),
    );
  });

  group('StartRoundUseCase', () {
    test('should start round successfully', () async {
      when(
        () => mockRepository.startRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          landmark: any(named: 'landmark'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(params);

      expect(result, const Right(unit));

      verify(
        () => mockRepository.startRound(
          partyCode: params.partyCode,
          hostId: params.hostId,
          roundIndex: params.roundIndex,
          landmark: params.landmark,
          durationSeconds: params.durationSeconds,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      const failure = ServerFailure(message: 'Failed to start round');

      when(
        () => mockRepository.startRound(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
          roundIndex: any(named: 'roundIndex'),
          landmark: any(named: 'landmark'),
          durationSeconds: any(named: 'durationSeconds'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(params);

      expect(result, const Left(failure));

      verify(
        () => mockRepository.startRound(
          partyCode: params.partyCode,
          hostId: params.hostId,
          roundIndex: params.roundIndex,
          landmark: params.landmark,
          durationSeconds: params.durationSeconds,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });
  });
}
