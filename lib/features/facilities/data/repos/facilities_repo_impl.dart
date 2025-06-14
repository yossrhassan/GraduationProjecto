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
  Future<Either<Failure, List<FacilitiesModel>>> fetchFacilities(
      {int? sportId}) async {
    try {
      String endpoint = 'Facilities?isOwner=false';
      if (sportId != null) {
        endpoint = '$endpoint&sportId=$sportId';
      }
      var body = await apiService.get(endPoint: endpoint);

      List<dynamic> facilitiesData;

      if (body is List) {
        facilitiesData = body;
      } else if (body is Map && body['success'] == true) {
        facilitiesData = body['data'] as List;
      } else if (body is Map && body['data'] != null) {
        facilitiesData = body['data'] as List;
      } else {
        String errorMessage = 'Unexpected response format';
        if (body is Map && body['message'] != null) {
          errorMessage = body['message'];
        }
        return left(ServerFailure(errorMessage));
      }

      List<FacilitiesModel> facilities = facilitiesData
          .map((facilityJson) => FacilitiesModel.fromJson(facilityJson))
          .toList();

      return right(facilities);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<String>>> fetchCities() async {
    try {
      var body = await apiService.get(endPoint: 'Facilities/cities');

      if (body is Map && body['success'] == true && body['data'] is List) {
        List<String> cities = List<String>.from(body['data']);
        return right(cities);
      } else {
        return left(ServerFailure('Failed to fetch cities'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
