// courts_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/booking/data/models/courts/courts.model.dart';
import 'package:graduation_project/features/booking/data/repos/courts_repo.dart';
import 'package:meta/meta.dart';

part 'courts_state.dart';

class CourtsCubit extends Cubit<CourtsState> {
  CourtsCubit(this.courtsRepo) : super(CourtsInitial());

  final CourtsRepo courtsRepo;

  Future<void> fetchCourtsByFacilityId(int facilityId) async {
    emit(CourtsLoading());

    var result = await courtsRepo.fetchCourtsByFacilityId(facilityId);

    result.fold((failure) {
      emit(CourtsFailure(failure.errMessage));
    }, (courts) {
      emit(CourtsSuccess(courts));
    });
  }
}
