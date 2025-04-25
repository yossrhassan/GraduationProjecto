import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/show_snack_bar.dart';
import 'package:graduation_project/core/widgets/custom_button.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/register/data/repos/register_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterView extends StatefulWidget {
 const RegisterView({super.key});

  static String id = '/RegisterView';

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  String? phoneNumber;

  bool isloading = false;

  GlobalKey<FormState> formkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isloading,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: formkey,
            child: ListView(children: [
             const SizedBox(
                height: 75,
              ),
              Image.asset('assets/images/sportsbookinglogo.png', height: 100),
             const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Sports',
                        style: TextStyle(
                            fontSize: 35,
                            fontFamily: 'Karla',
                            color: kPrimaryColor),
                      ),
                      Text(
                        'Booking',
                        style: TextStyle(
                            fontSize: 48,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                    ],
                  ),
                ],
              ),
             const SizedBox(
                height: 75,
              ),
             const Row(
                children: [
                  Text(
                    'Register',
                    style: TextStyle(fontSize: 24, color: kPrimaryColor),
                  ),
                ],
              ),
            const  SizedBox(
                height: 20,
              ),
              CustomTextField.CustomformTextField(
                onchanged: (data) {
                  firstName = data;
                },
                hintText: 'First Name',
              ),
             const SizedBox(
                height: 10,
              ),
              CustomTextField.CustomformTextField(
                onchanged: (data) {
                  lastName = data;
                },
                hintText: 'Last Name',
              ),
             const SizedBox(
                height: 10,
              ),
              CustomTextField.CustomformTextField(
                onchanged: (data) {
                  phoneNumber = data;
                },
                hintText: 'Phone Number',
              ),
             const SizedBox(
                height: 10,
              ),
              CustomTextField.CustomformTextField(
                onchanged: (data) {
                  email = data;
                },
                hintText: 'Email',
              ),
             const SizedBox(
                height: 10,
              ),
              CustomTextField.CustomformTextField(
                onchanged: (data) {
                  password = data;
                },
                hintText: 'Password',
              ),
             const SizedBox(
                height: 10,
              ),
              CustomTextField.CustomformTextField(
                onchanged: (data) {
                  confirmPassword = data;
                },
                hintText: 'Confirm Password',
              ),
             const SizedBox(
                height: 20,
              ),
              CustomButton(
                ontap: () async {
                  if (formkey.currentState!.validate()) {
                    if (password != confirmPassword) {
                      showSnackBar(context, 'Passwords do not match');
                      return;
                    }

                    isloading = true;
                    setState(() {});

                    try {
                      await RegisterService().registerUser(
                          firstName: firstName!,
                          lastName: lastName!,
                          phoneNumber: phoneNumber!,
                          email: email!,
                          password: password!,
                          confirmPassword: confirmPassword!);
                      showSnackBar(context, 'Registered successfully');
                      GoRouter.of(context).push(AppRouter.kLoginView);
                    } catch (ex) {
                      showSnackBar(context, 'Error: $ex');
                    }

                    isloading = false;
                    setState(() {});
                  }
                },
                text: 'Register',
              ),
            const  SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const  Text(
                    "already have an account ? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child:const Text(
                        'login',
                        style: TextStyle(color: kPrimaryColor),
                      ))
                ],
              ),
             const SizedBox(
                height: 150,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
