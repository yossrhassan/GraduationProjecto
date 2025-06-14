import 'package:graduation_project/core/utils/api.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/login/data/models/login_model.dart';

class LoginService {
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final Map<String, String> requestBody = {
      'email': email,
      'password': password,
    };

    final response = await Api().post(
      url: 'http://10.0.2.2:5000/api/Auth/login',
      body: requestBody,
      token: null,
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      var data = response['data'];

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        data = data['data'];
      }

      if (data is Map<String, dynamic>) {
        final userModel = LoginModel.fromJson(data);

        if (userModel.token == null || userModel.token!.isEmpty) {
          throw Exception(
              "Login failed: Token is null or empty. Parsed data: $data");
        }

        await AuthManager.setAuthToken(userModel.token!);
        return {'user': userModel};
      } else {
        throw Exception("Data field is not a valid JSON object: $data");
      }
    } else {
      throw Exception("Unexpected response format: $response");
    }
  }
}
