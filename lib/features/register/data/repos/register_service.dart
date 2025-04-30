
import 'package:graduation_project/core/utils/api.dart';

class RegisterService {
  Future<dynamic> registerUser(
      {required String firstName,
      required String lastName ,
      required String email,
      required String password,
      required String confirmPassword,
      required String phoneNumber,
      String? token
      }) async {
  dynamic data =
        await Api().post(url: 'http://10.0.2.2:5000/api/Auth/register', body: {
          
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      "confirmedPassword": confirmPassword,
      'phoneNumber':phoneNumber,
    },token: token);

 if (data is Map<String, dynamic>) {
      return data;
    } else {
      return {'message': data}; // Wrap plain string responses in a map
    }  }
}
