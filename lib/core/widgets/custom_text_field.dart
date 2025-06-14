import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField.CustomformTextField(
      {super.key,
      this.hintText,
      this.onchanged,
      this.obsecureText = false,
      this.prefixicon,
      this.suffexicon,
      this.height});

  final String? hintText;
  final Function(String)? onchanged;
  final Icon? prefixicon;
  final Icon? suffexicon;
  final double? height;
  final bool? obsecureText;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (height ?? 50) + 20,
      child: TextFormField(
        style: const TextStyle(color: kPrimaryColor),
        obscureText: obsecureText!,
        validator: (data) {
          if (data!.isEmpty) return 'field is required';
        },
        onChanged: onchanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xff7E807B)),
          suffixIcon: suffexicon,
          prefixIcon: prefixicon,
          border: buildBorder(),
          enabledBorder: buildBorder(),
          focusedBorder: buildBorder(kPrimaryColor),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            height: 1,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder([color]) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color ?? Colors.white));
  }
}
