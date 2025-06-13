// booking_history_repo.dart
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking_history_model.dart';

abstract class BookingHistoryRepo {
  Future<Either<Failure, List<BookingHistoryModel>>> getUserBookings();
}
