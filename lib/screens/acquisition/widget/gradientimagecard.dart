import 'package:flutter/material.dart';

class GradientImageCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;
  final double height;
  final double width;

  const GradientImageCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Preload image to improve loading performance
    precacheImage(AssetImage(imagePath), context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: height * .40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay + Content
          Container(
            height: height * .40,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration( 
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: width * .048,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w300,
                    fontSize: width * .038,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Opportunities',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: width * .035,
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
