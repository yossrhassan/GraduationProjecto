import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;
  Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);
  
  factory ServerFailure.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with ApiServer');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Send TimeOut with ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive TimeOut with ApiServer');
      case DioExceptionType.badCertificate:
        return ServerFailure('Bad Certificate with the server');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response?.statusCode ?? 500, dioError.response?.data);
      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was canceled');
      case DioExceptionType.connectionError:
        return ServerFailure('No Internet connection');
      case DioExceptionType.unknown:
        if (dioError.message?.contains('SocketException') ?? false) {
          return ServerFailure('No Internet connection');
        } else {
          return ServerFailure('Unexpected error occurred');
        }
      default:
        return ServerFailure('Unexpected error occurred');
    }
  }
  
  factory ServerFailure.fromResponse(int statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      // Handle null or unexpected response structures
      if (response == null) {
        return ServerFailure('Authentication error');
      }
      
      try {
        // Try to safely access error message
        if (response is Map && response['error'] is Map) {
          return ServerFailure(response['error']['message']?.toString() ?? 'Authentication error');
        } else if (response is Map && response['message'] != null) {
          return ServerFailure(response['message'].toString());
        } else {
          return ServerFailure('Request failed with status: $statusCode');
        }
      } catch (e) {
        return ServerFailure('Error processing response: $statusCode');
      }
    } else if (statusCode == 404) {
      return ServerFailure('Your Request Not Found, Please Try Later!');
    } else {
      return ServerFailure('Server error with status code: $statusCode');
    }
  }
}