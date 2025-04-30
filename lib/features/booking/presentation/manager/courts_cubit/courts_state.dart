// courts_state.dart
part of 'courts_cubit.dart';

@immutable
abstract class CourtsState {}

class CourtsInitial extends CourtsState {}

class CourtsLoading extends CourtsState {}

class CourtsFailure extends CourtsState {
  final String errMessage;

  CourtsFailure(this.errMessage);
}

class CourtsSuccess extends CourtsState {
  final List<CourtsModel> courts;

  CourtsSuccess(this.courts);
}
