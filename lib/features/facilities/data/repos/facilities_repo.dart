import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';

abstract class FacilitiesRepo {

Future<Either<Failure,List<FacilitiesModel>>> fetchFacilities();
  
}