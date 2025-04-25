class RegisterModel {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  String? phoneNumber;

  RegisterModel(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.confirmPassword,
      required this.phoneNumber});

  factory RegisterModel.fromJson(json) {
    return RegisterModel(
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password'],
        confirmPassword: json['confirmPassword'],
        phoneNumber: json['phoneNumber']);
  }
}
