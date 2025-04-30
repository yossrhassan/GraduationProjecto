// booking_history_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking.history.model.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';

class BookingHistoryRepoImpl implements BookingHistoryRepo {
  final ApiService apiService;

  BookingHistoryRepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<BookingHistoryModel>>> getUserBookings() async {
    try {
      final response = await apiService.get(endPoint: 'Booking/user');

      if (response is List) {
        final bookings = response.map((e) => BookingHistoryModel.fromJson(e)).toList();
        return right(bookings);
      } else {
        return left(ServerFailure('Unexpected response format from server'));
      }
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}