import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';
import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/repositories/game_repository.dart';
import 'package:pin_point/features/game/domain/usecases/get_landmarks_usecase.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late GetLandmarksUseCase useCase;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    useCase = GetLandmarksUseCase(mockRepository);
  });

  group('GetLandmarksUseCase', () {
    test(
      'should call repo with doubled pool size and return requested count',
      () async {
        final landmarks = List.generate(
          10,
          (index) => LandmarkEntity(
            id: '$index',
            name: 'Landmark $index',
            imageUrl: 'image_$index.jpg',
            actualLatitude: 30.0 + index,
            actualLongitude: 31.0 + index,
          ),
        );

        when(
          () => mockRepository.getLandmarks(count: 10),
        ).thenAnswer((_) async => Right(landmarks));

        final result = await useCase(const SingleParam(5));

        expect(result.isRight(), true);

        result.fold(
          (_) => fail('Expected Right'),
          (data) => expect(data.length, 5),
        );

        verify(() => mockRepository.getLandmarks(count: 10)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should clamp pool size to 20 when requested count is large',
      () async {
        final landmarks = List.generate(
          20,
          (index) => LandmarkEntity(
            id: '$index',
            name: 'Landmark $index',
            imageUrl: 'image_$index.jpg',
            actualLatitude: 30.0,
            actualLongitude: 31.0,
          ),
        );

        when(
          () => mockRepository.getLandmarks(count: 20),
        ).thenAnswer((_) async => Right(landmarks));

        await useCase(const SingleParam(15));

        verify(() => mockRepository.getLandmarks(count: 20)).called(1);
      },
    );

    test('should return failure when repository fails', () async {
      const failure = ServerFailure(message: 'Server Failure');

      when(
        () => mockRepository.getLandmarks(count: 10),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const SingleParam(5));

      expect(result, const Left(failure));

      verify(() => mockRepository.getLandmarks(count: 10)).called(1);
    });

    test('should return all available landmarks when repo '
        'returns less than requested', () async {
      final landmarks = List.generate(
        3,
        (index) => LandmarkEntity(
          id: '$index',
          name: 'Landmark $index',
          imageUrl: 'image_$index.jpg',
          actualLatitude: 30.0,
          actualLongitude: 31.0,
        ),
      );

      when(
        () => mockRepository.getLandmarks(count: 10),
      ).thenAnswer((_) async => Right(landmarks));

      final result = await useCase(const SingleParam(5));

      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data.length, 3),
      );

      verify(() => mockRepository.getLandmarks(count: 10)).called(1);
    });
  });
}
