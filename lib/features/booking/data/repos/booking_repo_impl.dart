import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/booking/data/models/booking.model.dart';
import 'package:graduation_project/features/booking/data/repos/booking_repo.dart';

class BookingRepoImpl implements BookingRepo {
  final ApiService apiService;

  BookingRepoImpl(this.apiService);

  @override
  Future<Either<Failure, bool>> confirmBookingApi(BookingModel booking) async {
    try {
      print('Token before confirmation request: ${AuthManager.authToken}');

      final response = await apiService.post(
        endPoint: 'Booking',
        data: booking.toJson(),
      );

      print('Booking confirmation response: $response');

      if (response != null) {
        if (response is String &&
            response.toLowerCase().contains('successful')) {
          return right(true);
        } else if (response is Map &&
            (response['status'] == 'success' || response['success'] == true)) {
          return right(true);
        } else {
          String errorMessage = 'Booking failed';
          if (response is Map && response['message'] != null) {
            errorMessage = response['message'];
          }
          return left(ServerFailure(errorMessage));
        }
      } else {
        return left(ServerFailure('Empty response from server'));
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          return left(
              ServerFailure('Authentication required. Please log in again.'));
        }
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookings(
      {int? courtId}) async {
    try {
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final actualCourtId = courtId ?? 1;

      print(
          'Requesting bookings for facility $actualCourtId on date $formattedDate');

      final response = await apiService.get(
          endPoint: 'Booking/$actualCourtId/$formattedDate');

      print('Raw booking response: $response');

      if (response != null) {
        if (response is Map<String, dynamic>) {
          return right(response);
        } else if (response is List) {
          return right({'bookings': response});
        } else {
          print('Unexpected response type: ${response.runtimeType}');
          return left(ServerFailure('Unexpected response format'));
        }
      } else {
        return left(ServerFailure('Empty response from server'));
      }
    } catch (e) {
      print('Exception in getBookings: $e');
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          return left(
              ServerFailure('Authentication required. Please log in again.'));
        }
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
