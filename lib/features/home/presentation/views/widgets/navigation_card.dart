import 'package:flutter/material.dart';

class NavigationCard extends StatelessWidget {
  const NavigationCard(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.onTap});
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Image.asset(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}