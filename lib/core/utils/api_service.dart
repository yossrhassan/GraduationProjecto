import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/api.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final _baseUrl = 'http://10.0.2.2:5000/api/';
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options = BaseOptions(
      receiveDataWhenStatusError: true,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );

    // Add interceptor to include token in requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Always get latest token from AuthManager
          final currentToken = AuthManager.authToken;

          // Add auth token if available
          if (currentToken != null && currentToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $currentToken';
            print('Adding token to request: $currentToken');
          } else {
            print(
                'WARNING: No auth token available for request to ${options.path}');
          }
          return handler.next(options);
        },
      ),
    );
  }

  // No need for static token methods in ApiService
  // They're now handled exclusively by AuthManager

  Future<dynamic> get({required String endPoint}) async {
    try {
      var response = await _dio.get('$_baseUrl$endPoint');
      return response.data;
    } catch (e) {
      print('Error during GET request: $e');
      _handleAuthError(e);
      rethrow;
    }
  }

  Future<dynamic> post({
    required String endPoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('Making POST request to: $_baseUrl$endPoint');
      print('With data: $data');

      var response = await _dio.post('$_baseUrl$endPoint', data: data);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response.data;
    } catch (e) {
      if (e is DioError) {
        print('Error during POST request: $e');
        print('Response status: ${e.response?.statusCode}');
        print('Response body: ${e.response?.data}');
        _handleAuthError(e);
        throw Exception(
            'Request failed with status: ${e.response?.statusCode}, body: ${e.response?.data}');
      } else {
        print('Unexpected error during POST request: $e');
        throw Exception('Unexpected error: $e');
      }
    }
  }

  void _handleAuthError(dynamic error) {
    if (error is DioError && error.response?.statusCode == 401) {
      // Clear token on auth failures to force re-login
      AuthManager.clearAuthToken();
    }
  }
}
