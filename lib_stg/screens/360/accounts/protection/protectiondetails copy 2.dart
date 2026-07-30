import 'package:flutter/material.dart';


class Protectiondetails extends StatelessWidget {
  const Protectiondetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Gradient Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE85D3A), // Deep orange
                  Color(0xFFF0806A), // Lighter orange/pink
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                // Top Navigation Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                    Row(
                      children: const [
                        Icon(Icons.add, color: Colors.white, size: 26),
                        SizedBox(width: 20),
                        Icon(Icons.info_outline, color: Colors.white, size: 26),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Balance Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      "£0.00",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "PM",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Protection Dropdown Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Protection",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF666666)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Empty State Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shield Icon
                  const Icon(
                    Icons.shield,
                    size: 80,
                    color: Color(0xFFE0E0E0),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Oops, Nothing to see here",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Add Protection Account Button
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Color(0xFFD32F2F), size: 18),
                    label: const Text(
                      "Add Protection Account",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}