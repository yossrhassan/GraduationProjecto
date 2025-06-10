class RegisterModel {
  String? firstName;
  String? lastName;
  String? userName;
  String? email;
  String? password;
  String? confirmPassword;
  String? phoneNumber;

  RegisterModel(
      {required this.firstName,
      required this.lastName,
      required this.userName,
      required this.email,
      required this.password,
      required this.confirmPassword,
      required this.phoneNumber});

  factory RegisterModel.fromJson(json) {
    return RegisterModel(
        firstName: json['firstName'],
        lastName: json['lastName'],
        userName: json['username'],
        email: json['email'],
        password: json['password'],
        confirmPassword: json['confirmPassword'],
        phoneNumber: json['phoneNumber']);
  }
}
