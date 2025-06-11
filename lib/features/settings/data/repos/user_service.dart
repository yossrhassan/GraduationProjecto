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
      print('🌐 UserService: Making API call for userId: $userId');
      final response = await apiService.get(
        endPoint: 'AdminAuth/GetUserById?id=$userId',
      );
      print('✅ UserService: Raw API response: $response');
      print('✅ UserService: Response type: ${response.runtimeType}');

      // Extract the 'data' field from the response
      Map<String, dynamic> userData;
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        userData = response['data'] as Map<String, dynamic>;
        print('✅ UserService: Extracted data field: $userData');
      } else {
        // Fallback if response doesn't have nested structure
        userData = response as Map<String, dynamic>;
        print('✅ UserService: Using response directly: $userData');
      }

      final userModel = UserModel.fromJson(userData);
      print(
          '✅ UserService: Parsed UserModel - firstName: ${userModel.firstName}, lastName: ${userModel.lastName}, email: ${userModel.email}');
      return userModel;
    } catch (e) {
      print('❌ UserService: Failed to load user profile: $e');
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
      print('🔄 UserService: Updating user profile...');
      print('🔄 UserService: Current userId: ${AuthManager.userId}');
      print(
          '🔄 UserService: Data to send: {firstName: $firstName, lastName: $lastName, userName: $userName, email: $email, phoneNumber: $phoneNumber}');

      final response = await apiService.put(
        endPoint: 'Auth/UserProfile',
        data: {
          "id": AuthManager.userId,
          "firstName": firstName,
          "lastName": lastName,
          "userName": userName,
          "email": email,
          "phoneNumber": phoneNumber,
        },
      );

      print('✅ UserService: Profile update response: $response');
    } catch (e) {
      print('❌ UserService: Failed to update profile: $e');
      rethrow;
    }
  }
}
