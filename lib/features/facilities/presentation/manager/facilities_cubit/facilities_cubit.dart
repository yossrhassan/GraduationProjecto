import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';
import 'package:graduation_project/features/facilities/data/repos/facilities_repo.dart';
import 'package:meta/meta.dart';

part 'facilities_state.dart';

class FacilitiesCubit extends Cubit<FacilitiesState> {
  FacilitiesCubit(this.facilitiesRepo) : super(FacilitiesInitial());

  final FacilitiesRepo facilitiesRepo;

  Future<void> fetchFacilities() async {
    emit(FacilitiesLoading());

    var result = await facilitiesRepo.fetchFacilities();

    result.fold((faliure) {
      emit(FacilitiesFailure(faliure.errMessage));
    }, (facilities) {
      emit(FacilitiesSuccess(facilities));
    });
  }
}
