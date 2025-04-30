// courts_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/booking/data/models/courts.model.dart';
import 'package:graduation_project/features/booking/data/repos/courts_repo.dart';
class CourtsRepoImpl implements CourtsRepo {
  final ApiService apiService;

  CourtsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<CourtsModel>>> fetchCourtsByFacilityId(int facilityId) async {
    try {
      var data = await apiService.get(endPoint: 'Court/getAll?FacilityId=$facilityId');
      
      if (data is List) {
        List<CourtsModel> courts = data.map((courtJson) => CourtsModel.fromJson(courtJson)).toList();
        return right(courts);
      } else {
        return left(ServerFailure('Unexpected response format'));
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