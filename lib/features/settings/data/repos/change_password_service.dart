import 'package:graduation_project/core/utils/api.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class ChangePasswordService {
  Future<void> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = AuthManager.authToken;

    if (token == null) {
      throw Exception("Token is missing. Please log in again.");
    }

    final Map<String, dynamic> requestBody = {
      "token": token,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };

    final response = await Api().post(
      url: "http://10.0.2.2:5000/api/Auth/reset-password",
      body: requestBody,
      token: null, // token is sent inside the body, not as a header
    );

    print("🔐 Change password response: $response");

    if (response["success"] == false) {
      throw Exception(response["message"] ?? "Password change failed.");
    }
  }
}
