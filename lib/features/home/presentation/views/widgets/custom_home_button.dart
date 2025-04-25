import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class CustomHomeButton extends StatelessWidget {
  const CustomHomeButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed,
      required this.filled});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  @override
  Widget build(BuildContext context) {
    return filled
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
  }
}