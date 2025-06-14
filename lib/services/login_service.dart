import 'package:graduation_project/core/utils/api.dart';
import 'package:graduation_project/features/login/data/models/login_model.dart';

class LoginService {
  Future<dynamic> loginUser({
    required String email,
    required String password,
  }) async {
    final Map<String, String> requestBody = {
      'email': email,
      'password': password,
    };

    final dynamic response = await Api().post(
      url: 'http://10.0.2.2:5000/api/Auth/login',
      body: requestBody,
    );

    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        var data = response['data'];

        if (data is Map<String, dynamic>) {
          final userModel = LoginModel.fromJson(data);
          return {'user': userModel};
        }
      }
    }

    throw Exception('Unexpected response format: $response');
  }
}
