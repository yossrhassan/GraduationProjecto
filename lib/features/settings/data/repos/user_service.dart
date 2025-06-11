import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';
import 'package:http/http.dart' as apiService show post;
import 'package:dio/dio.dart';

class UserService {
  final ApiService apiService;

  UserService(this.apiService);

  Future<UserModel> getUserProfile(int userId) async {
    try {
      final response = await apiService.get(
        endPoint: 'AdminAuth/GetUserById?id=$userId',
      );
      print('✅ User profile response: $response');
      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Failed to load user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int userId) async {
    try {
      final response = await apiService.post(
        endPoint: 'AdminAuth/DeleteUser?id=$userId',
        data: {},
      );
      print('🗑️ Account deleted: $response');
    } catch (e) {
      print('❌ Failed to delete account: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = AuthManager.authToken;

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please log in again.');
    }

    try {
      final response = await apiService.post(
        endPoint: 'Auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      print('✅ Password changed: $response');
    } catch (e) {
      print('❌ Failed to change password: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String userName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      await apiService.put(
        endPoint: 'Auth/UserProfile',
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "userName": userName,
          "email": email,
          "phoneNumber": phoneNumber,
        },
      );
    } catch (e) {
      print('❌ Failed to update profile: $e');
      rethrow;
    }
  }
}
