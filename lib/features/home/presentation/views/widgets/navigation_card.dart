import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class NavigationCard extends StatelessWidget {
  const NavigationCard(
      {super.key, required this.title, this.imageUrl, required this.onTap});
  final String title;
  final String? imageUrl;
  final VoidCallback onTap;

  Widget _buildImageWidget() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      // Show blank placeholder when no image
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    // Show network image with error handling
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        // Show blank placeholder on error (404, network issues, etc.)
        return Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        );
      },
    );
  }

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
          child: Container(
            height: 120,
            width: double.infinity,
            child: Stack(
              children: [
                // Background image
                _buildImageWidget(),
                // Dark overlay
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final String _baseUrl = 'http://10.0.2.2:8000/';
