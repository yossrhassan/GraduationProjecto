part of 'facilities_cubit.dart';

@immutable
sealed class FacilitiesState {}

final class FacilitiesInitial extends FacilitiesState {}

final class FacilitiesLoading extends FacilitiesState {}

final class FacilitiesFailure extends FacilitiesState {
  final String errMessage;

  FacilitiesFailure(this.errMessage);
}

final class FacilitiesSuccess extends FacilitiesState {
  final List<FacilitiesModel> facilities;

  FacilitiesSuccess(this.facilities);
}
