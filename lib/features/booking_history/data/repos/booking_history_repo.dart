import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/data/models/booking.model.dart';

abstract class BookingHistoryRepo {
  Future<Either<Failure, List<BookingModel>>> getUserBookings();
}
