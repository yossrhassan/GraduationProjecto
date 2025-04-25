import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/data/models/booking.model.dart';

abstract class BookingRepo {
  Future<Either<Failure, bool>> confirmBookingApi(BookingModel booking);
  Future<Either<Failure, Map<String, dynamic>>> getBookings();
}
