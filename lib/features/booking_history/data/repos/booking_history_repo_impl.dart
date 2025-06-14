// booking_history_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/booking_history/data/models/booking/booking_history_model.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';

class BookingHistoryRepoImpl implements BookingHistoryRepo {
  final ApiService apiService;

  BookingHistoryRepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<BookingHistoryModel>>> getUserBookings() async {
    try {
      final response = await apiService.get(endPoint: 'Booking/user');

      if (response is List) {
        final bookings =
            response.map((e) => BookingHistoryModel.fromJson(e)).toList();
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

  @override
  Future<Either<Failure, String>> cancelBooking(int bookingId) async {
    try {
      final response = await apiService.put(
        endPoint: 'Booking/cancel/$bookingId',
        data: {},
      );

      if (response is String) {
        return right(response);
      } else if (response is Map<String, dynamic>) {
        final message = response['message'] ??
            response['messege'] ??
            'Booking cancelled successfully';
        return right(message.toString());
      } else {
        return right('Booking cancelled successfully');
      }
    } catch (e) {
      String errorMessage = e.toString();

      if (e is DioError) {
        if (e.response?.statusCode == 400 && e.response?.data != null) {
          errorMessage = e.response!.data.toString();
        } else {
          return left(ServerFailure.fromDioError(e));
        }
      } else {
        String errorString = e.toString();

        if (errorString.contains('body: ')) {
          int bodyIndex = errorString.indexOf('body: ') + 6;
          errorMessage = errorString.substring(bodyIndex).trim();
        } else {
          errorMessage = errorString;
        }
      }

      return left(ServerFailure(errorMessage));
    }
  }
}
