// class LoginModel {
//   final int? id;
//   final String? name;
//   final String? email;
//   final String? token;
//   final String? role;
//   final String? message;

//   LoginModel({
//     this.id,
//     this.name,
//     this.email,
//     this.token,
//     this.role,
//     this.message,
//   });

//   factory LoginModel.fromJson(Map<String, dynamic> json) {
//     print("Parsing LoginModel from JSON: $json");
//     return LoginModel(
//       id: json['data']['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
//       name: json['data']['name']?.toString(),
//       email: json['data']['email']?.toString(),
//       token: json['data']['token']?.toString(),
//       role: json['data']['role']?.toString(),
//       message: json['data']['message']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'token': token,
//       'role': role,
//       'message': message,
//     };
//   }
// }
class LoginModel {
  final int? id;
  final String? name;
  final String? email;
  final String? token;
  final String? role;
  final String? message;

  LoginModel({
    this.id,
    this.name,
    this.email,
    this.token,
    this.role,
    this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    print("🧪 Parsing LoginModel from JSON: $json");
    print("🧪 JSON Keys: ${json.keys.toList()}");

    // Handle both direct and nested id fields
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return LoginModel(
      id: parseId(json['id'] ?? json['userId']),
      name: json['name']?.toString() ?? json['userName']?.toString(),
      email: json['email']?.toString(),
      token: json['token']?.toString(),
      role: json['role']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
      'message': message,
    };
  }
}
