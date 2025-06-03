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

    print("🧪 Full Login Response: $response");
    print("🧪 Response Type: ${response.runtimeType}");

    if (response is Map<String, dynamic>) {
      print("🧪 Response Keys: ${response.keys.toList()}");

      if (response.containsKey('data')) {
        var data = response['data'];
        print("🧪 Data Type: ${data.runtimeType}");
        print("🧪 Data Content: $data");

        if (data is Map<String, dynamic>) {
          print("🧪 Data Keys: ${data.keys.toList()}");

          // Create LoginModel directly from the data
          final userModel = LoginModel.fromJson(data);
          print(
              "🧪 Created LoginModel: id=${userModel.id}, token=${userModel.token}, email=${userModel.email}");
          return {'user': userModel};
        }
      }
    }

    throw Exception('Unexpected response format: $response');
  }
}
