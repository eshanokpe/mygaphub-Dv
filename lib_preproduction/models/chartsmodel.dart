import 'package:flutter/material.dart';

class Hseed {
  Text hseed;
  double value;
  int colorVal;

  Hseed({required this.hseed, required this.value, required this.colorVal});
}

class Kpi {
  Text kpi;
  double value;
  // int colorVal;
  final List<Color> gradientColors;

  Kpi({required this.kpi, required this.value, required this.gradientColors});
}

class GradientProgressBar extends StatelessWidget {
  final String label;
  final double value; // Percentage value
  final List<Color> gradientColors;

  const GradientProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background Container
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                // Progress Bar
                Container(
                  height: 30,
                  width: (value / 100) * 200, // Adjust width dynamically
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${value.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class Norms {
  String name;
  double value;
  int color;

  Norms({required this.name, required this.value, required this.color});
}

class Homequity {
  String name;
  int value;
  String colorVal;

  Homequity({required this.name, required this.value, required this.colorVal});
}

class Networths {
  String name;
  double value;
  String colorVal;
  Networths({required this.name, required this.value, required this.colorVal});
}

class Lao {
  String name;
  int value;
  String colorVal;

  Lao({required this.name, required this.value, required this.colorVal});
}
