import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';
import 'package:graduation_project/features/facilities/data/repos/facilities_repo.dart';

class FacilitiesRepoImpl implements FacilitiesRepo {
  final ApiService apiService;

  FacilitiesRepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<FacilitiesModel>>> fetchFacilities() async {
    try {
      var body = await apiService.get(endPoint: 'Facilities/GetAll');

      // Check if the response indicates success
      if (body['success'] == true) {
        var data = body['data'];
        List<FacilitiesModel> facilities = (data as List)
            .map((facilityJson) => FacilitiesModel.fromJson(facilityJson))
            .toList();

        return right(facilities);
      } else {
        // Handle case where success is false
        String errorMessage = body['message'] ?? 'Failed to fetch facilities';
        return left(ServerFailure(errorMessage));
      }
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
