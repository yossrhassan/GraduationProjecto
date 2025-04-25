import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text,this.ontap});
  final String text;
  final VoidCallback? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: kPrimaryColor),
        child: Center(child: Text(text,style: TextStyle(color: Colors.white),)),
      ),
    );
  }
}
