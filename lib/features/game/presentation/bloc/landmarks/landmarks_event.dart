part of 'landmarks_bloc.dart';

sealed class LandmarksEvent extends Equatable {
  const LandmarksEvent();
}

final class GetLandmarksEvent extends LandmarksEvent {
  const GetLandmarksEvent({this.count = 5});

  final int count;

  @override
  List<Object?> get props => [count];
}
