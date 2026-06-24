import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';

import 'package:pin_point/features/game/domain/entities/landmark_entity.dart';
import 'package:pin_point/features/game/domain/usecases/get_landmarks_usecase.dart';

import 'package:pin_point/features/game/presentation/bloc/landmarks/landmarks_bloc.dart';

class MockGetLandmarksUseCase extends Mock implements GetLandmarksUseCase {}

class FakeSingleParamInt extends Fake implements SingleParam<int> {}

void main() {
  late LandmarksBloc bloc;
  late MockGetLandmarksUseCase mockGetLandmarksUseCase;

  const tCount = 5;

  const tLandmarks = [
    LandmarkEntity(
      id: '1',
      name: 'Eiffel Tower',
      imageUrl: 'image.jpg',
      actualLatitude: 48.8584,
      actualLongitude: 2.2945,
      country: 'France',
      city: 'Paris',
    ),
    LandmarkEntity(
      id: '2',
      name: 'Big Ben',
      imageUrl: 'image2.jpg',
      actualLatitude: 51.5007,
      actualLongitude: -0.1246,
      country: 'UK',
      city: 'London',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeSingleParamInt());
  });

  setUp(() {
    mockGetLandmarksUseCase = MockGetLandmarksUseCase();

    bloc = LandmarksBloc(getLandmarks: mockGetLandmarksUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be LandmarksInitial', () {
    expect(bloc.state, const LandmarksInitial());
  });

  group('GetLandmarksEvent', () {
    blocTest<LandmarksBloc, LandmarksState>(
      'emits [Loading, Loaded] when usecase succeeds',
      build: () {
        when(
          () => mockGetLandmarksUseCase(any()),
        ).thenAnswer((_) async => const Right(tLandmarks));

        return bloc;
      },
      act: (bloc) => bloc.add(const GetLandmarksEvent()),
      expect: () => [
        const LandmarksLoading(),
        const LandmarksLoaded(landmarks: tLandmarks),
      ],
      verify: (_) {
        verify(
          () => mockGetLandmarksUseCase(const SingleParam(tCount)),
        ).called(1);

        verifyNoMoreInteractions(mockGetLandmarksUseCase);
      },
    );

    blocTest<LandmarksBloc, LandmarksState>(
      'emits [Loading, Failure] when usecase fails',
      build: () {
        when(() => mockGetLandmarksUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Failed to load landmarks')),
        );

        return bloc;
      },
      act: (bloc) => bloc.add(const GetLandmarksEvent()),
      expect: () => const [
        LandmarksLoading(),
        LandmarksFailure(message: 'Failed to load landmarks'),
      ],
      verify: (_) {
        verify(
          () => mockGetLandmarksUseCase(const SingleParam(tCount)),
        ).called(1);

        verifyNoMoreInteractions(mockGetLandmarksUseCase);
      },
    );
  });
}
