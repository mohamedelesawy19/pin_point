// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/usecases/usecase.dart';

// Feature imports:
import '/features/game/domain/entities/landmark_entity.dart';
import '/features/game/domain/usecases/get_landmarks_usecase.dart';

// Part imports:
part 'landmarks_event.dart';
part 'landmarks_state.dart';

class LandmarksBloc extends Bloc<LandmarksEvent, LandmarksState> {
  LandmarksBloc({required this._getLandmarks})
    : super(const LandmarksInitial()) {
    on<GetLandmarksEvent>(_onFetchRequested, transformer: droppable());
  }

  final GetLandmarksUseCase _getLandmarks;

  Future<void> _onFetchRequested(
    GetLandmarksEvent event,
    Emitter<LandmarksState> emit,
  ) async {
    emit(const LandmarksLoading());

    final result = await _getLandmarks(SingleParam(event.count));

    result.fold(
      (failure) => emit(LandmarksFailure(message: failure.message)),
      (landmarks) => emit(LandmarksLoaded(landmarks: landmarks)),
    );
  }
}
