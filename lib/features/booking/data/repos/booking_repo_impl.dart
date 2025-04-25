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
      // Debug token before request
      print('Token before confirmation request: ${AuthManager.authToken}');

      // Make the API request to confirm booking
      final response = await apiService.post(
        endPoint: 'Booking', // Adjust the endpoint as needed
        data: booking.toJson(), // Convert the booking model to JSON
      );

      // Debug response
      print('Booking confirmation response: $response');

      // Parse response according to your API's structure
      if (response != null) {
        // Check if response is a String (like "Booking successful!")
        if (response is String &&
            response.toLowerCase().contains('successful')) {
          return right(true); // Booking was successful
        }
        // Check if response is a Map with status or success keys
        else if (response is Map &&
            (response['status'] == 'success' || response['success'] == true)) {
          return right(true); // Booking was successful
        }
        // If none of the success conditions matched
        else {
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
        // Check if it's an auth error
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
  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookings() async {
    try {
      // Use current date in ISO format (YYYY-MM-DD)
      final today = DateTime.now();
      final formattedDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final response =
          await apiService.get(endPoint: 'Booking/1/$formattedDate');
      print('Bookings response: $response');

      if (response != null && response is Map<String, dynamic>) {
        return right(response);
      } else {
        return left(ServerFailure('Unexpected response format'));
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
