// courts_repo.dart
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/data/models/courts/courts.model.dart';

abstract class CourtsRepo {
  Future<Either<Failure, List<CourtsModel>>> fetchCourtsByFacilityId(
      int facilityId);
}
