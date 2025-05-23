import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/data/models/booking.model.dart';

abstract class BookingRepo {
  Future<Either<Failure, bool>> confirmBookingApi(BookingModel booking);
  // Updated to include facilityId parameter
  Future<Either<Failure, Map<String, dynamic>>> getBookings({int? courtId});
}