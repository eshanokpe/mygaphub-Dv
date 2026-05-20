import 'dart:math' as math;
import 'package:GapHub/models/calculatormodel.dart';
import 'package:flutter/material.dart';

class DoughnutWidget extends StatelessWidget {
  final double value;
  final String imagePath;
  final int numberValue;
  final Color foregroundColor;
  final Calculatormodel calculatormodel;

  const DoughnutWidget({
    super.key,
    required this.value,
    required this.imagePath,
    required this.numberValue,
    required this.foregroundColor,
    required this.calculatormodel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: DoughnutPainter(value / 100, foregroundColor),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                numberValue.toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 0, 0),
                        Color.fromARGB(255, 206, 0, 0),
                      ], // Example linear gradient colors
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),
              const SizedBox(width: 5),
              Image.asset(imagePath),
            ],
          ),
        ),
      ),
    );
  }
}

class DoughnutPainter extends CustomPainter {
  final double percentage;
  final Color foregroundColor;

  DoughnutPainter(this.percentage, this.foregroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 20.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Paint foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    double arcAngle = 2 * math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      arcAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
