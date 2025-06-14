import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';
import 'package:graduation_project/features/facilities/data/repos/facilities_repo.dart';
import 'package:meta/meta.dart';

part 'facilities_state.dart';

class FacilitiesCubit extends Cubit<FacilitiesState> {
  FacilitiesCubit(this.facilitiesRepo) : super(FacilitiesInitial());

  final FacilitiesRepo facilitiesRepo;
  List<String> _cities = [];
  String? _selectedCity;
  List<FacilitiesModel> _allFacilities = [];

  List<String> get cities => _cities;
  String? get selectedCity => _selectedCity;

  Future<void> fetchCities() async {
    try {
      var result = await facilitiesRepo.fetchCities();
      result.fold(
        (failure) {},
        (cities) {
          _cities = ['All Cities', ...cities];
        },
      );
    } catch (e) {}
  }

  void selectCity(String? city) {
    _selectedCity = city;
    _filterFacilitiesByCity();
  }

  Future<void> fetchFacilities({int? sportId}) async {
    emit(FacilitiesLoading());

    var result = await facilitiesRepo.fetchFacilities(sportId: sportId);

    result.fold((failure) {
      emit(FacilitiesFailure(failure.errMessage));
    }, (facilities) {
      _allFacilities = facilities;
      _filterFacilitiesByCity();
    });
  }

  void _filterFacilitiesByCity() {
    List<FacilitiesModel> filteredFacilities = _allFacilities;

    if (_selectedCity != null && _selectedCity != 'All Cities') {
      filteredFacilities = _allFacilities
          .where((facility) =>
              facility.address?.city?.toLowerCase() ==
              _selectedCity?.toLowerCase())
          .toList();
    }

    emit(FacilitiesSuccess(filteredFacilities));
  }
}
