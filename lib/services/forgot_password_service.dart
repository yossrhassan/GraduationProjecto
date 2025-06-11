import 'package:graduation_project/core/utils/api.dart';

class ForgotPasswordService {
  Future<void> sendResetEmail({
    required String email,
  }) async {
    final Map<String, String> requestBody = {
      'email': email,
    };

    final dynamic response = await Api().post(
      url: 'http://10.0.2.2:5000/api/Auth/forgot-password',
      body: requestBody,
    );

    print("🔄 Forgot Password Response: $response");

    if (response is Map<String, dynamic>) {
      if (response['success'] == true) {
        print("✅ Password reset email sent successfully");
        return;
      } else {
        throw Exception(response['message'] ?? 'Failed to send reset email');
      }
    }

    throw Exception('Unexpected response format: $response');
  }
}
