import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({super.key, required this.label, required this.value, required this.icon, required this.onTap});
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF06845A),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: value == 'Choose' || value.contains('Optional')
                        ? Colors.white54
                        : Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  icon,
                  color: Colors.white54,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
