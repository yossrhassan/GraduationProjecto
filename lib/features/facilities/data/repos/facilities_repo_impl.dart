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
      print('🔍 FACILITIES: Fetching facilities...');
      var body = await apiService.get(endPoint: 'Facilities?isOwner=false');

      print('🔍 FACILITIES: Response type: ${body.runtimeType}');
      print('🔍 FACILITIES: Response: $body');

      // Handle different response formats
      List<dynamic> facilitiesData;
      
      if (body is List) {
        // Direct array response
        facilitiesData = body;
        print('🔍 FACILITIES: Direct array response with ${facilitiesData.length} items');
      } else if (body is Map && body['success'] == true) {
        // Wrapped response with success flag
        facilitiesData = body['data'] as List;
        print('🔍 FACILITIES: Wrapped response with ${facilitiesData.length} items');
      } else if (body is Map && body['data'] != null) {
        // Response with data field but no success flag
        facilitiesData = body['data'] as List;
        print('🔍 FACILITIES: Data field response with ${facilitiesData.length} items');
      } else {
        // Unexpected format
        print('🔍 FACILITIES: Unexpected response format');
        String errorMessage = 'Unexpected response format';
        if (body is Map && body['message'] != null) {
          errorMessage = body['message'];
        }
        return left(ServerFailure(errorMessage));
      }

      List<FacilitiesModel> facilities = facilitiesData
          .map((facilityJson) {
            print('🔍 FACILITIES: Processing facility: $facilityJson');
            return FacilitiesModel.fromJson(facilityJson);
          })
          .toList();

      print('🔍 FACILITIES: Successfully parsed ${facilities.length} facilities');
      return right(facilities);
      
    } catch (e) {
      print('🔍 FACILITIES: Error occurred: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
