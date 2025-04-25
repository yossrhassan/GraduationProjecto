import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField.CustomformTextField(
      {super.key,
      this.hintText,
      this.onchanged,
      this.obsecureText = false,
      this.prefixicon,
      this.suffexicon, this.height});

  final String? hintText;
  final Function(String)? onchanged;
  final Icon? prefixicon;
  final Icon? suffexicon;
  final double? height;
  final bool? obsecureText;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height?? 50,
      child: TextFormField(
        style: const TextStyle(color:kPrimaryColor ),
        obscureText: obsecureText!,
        validator: (data) {
          if (data!.isEmpty) return 'field is required';
        },
        onChanged: onchanged,
         textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
            // filled: true, 
            // fillColor: Color(0xff48444E),
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xff7E807B)),
            suffixIcon: suffexicon,
            prefixIcon: prefixicon,
            border: buildBorder(),
            enabledBorder: buildBorder(),
            focusedBorder: buildBorder(kPrimaryColor)),
      ),
    );
  }

  OutlineInputBorder buildBorder([color]) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color ?? Colors.white));
  }
}
