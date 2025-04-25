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
    print("Parsing LoginModel from JSON: $json");
    return LoginModel(
      id: json['data']['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['data']['name']?.toString(),
      email: json['data']['email']?.toString(),
      token: json['data']['token']?.toString(),
      role: json['data']['role']?.toString(),
      message: json['data']['message']?.toString(),
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