part of 'landmarks_bloc.dart';

sealed class LandmarksState extends Equatable {
  const LandmarksState();
}

final class LandmarksInitial extends LandmarksState {
  const LandmarksInitial();

  @override
  List<Object?> get props => [];
}

final class LandmarksLoading extends LandmarksState {
  const LandmarksLoading();

  @override
  List<Object?> get props => [];
}

final class LandmarksLoaded extends LandmarksState {
  const LandmarksLoaded({required this.landmarks});

  final List<LandmarkEntity> landmarks;

  @override
  List<Object?> get props => [landmarks];
}

final class LandmarksFailure extends LandmarksState {
  const LandmarksFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
