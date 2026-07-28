import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WheelPainter extends CustomPainter {
  final int selectedIndex;

  const WheelPainter({required this.selectedIndex});

  final List<Color> quadrantColors = const [
    Color(0xff256825), // Green
    Color(0xFF6A1B9A), // Purple
    Color(0xFFB71922), // Red
    Color(0xFFE08B1C), // Orange
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tickRadius = size.width / 2 - 25;
    final arcRadius = size.width / 2 - 2;

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const totalTicks = 60;
    const tickAngle = (2 * pi) / totalTicks;

    /// DASHED TICKS
    for (int i = 0; i < totalTicks; i++) {
      final angle = -pi + tickAngle * i;
      int quadrant = i ~/ 15;
      final tickPositionInQuadrant = i % 15;

      final isThickTick = i % 15 == 0;

      // Set color based on tick thickness and position
      if (isThickTick) {
        // This is a thick tick
        if (tickPositionInQuadrant == 0 && quadrant == selectedIndex) {
          // FIRST thick tick of each quadrant (positions 0, 15, 30, 45)
          tickPaint.color = const Color.fromARGB(176, 0, 0, 0).withOpacity(0.8);
        } else {
          // Other thick ticks within the quadrant
          tickPaint.color = selectedIndex == -1
              ? const Color.fromARGB(161, 0, 0, 0).withOpacity(0.8)
              : quadrant == selectedIndex
              ? quadrantColors[quadrant]
              : quadrantColors[quadrant].withOpacity(0.2);
        }
      } else {
        // Thin ticks - keep original color behavior
        tickPaint.color = selectedIndex == -1
            ? quadrantColors[quadrant]
            : quadrant == selectedIndex
            ? quadrantColors[quadrant]
            : quadrantColors[quadrant].withOpacity(0.2);
      }

      tickPaint.strokeWidth = isThickTick ? 6 : 4;

      final start = Offset(
        center.dx + (tickRadius - 8) * cos(angle),
        center.dy + (tickRadius - 8) * sin(angle),
      );

      final end = Offset(
        center.dx + tickRadius * cos(angle),
        center.dy + tickRadius * sin(angle),
      );

      canvas.drawLine(start, end, tickPaint);
    }

    /// OUTER ARCS - Fixed: No scaling units
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.w
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      arcPaint.color = selectedIndex == -1
          ? quadrantColors[i]
          : i == selectedIndex
          ? quadrantColors[i]
          : quadrantColors[i].withOpacity(0.6);

      final startAngle = -pi / 2 + (i * pi / 2) - 0.85;
      const sweep = 0.22;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweep,
        false,
        arcPaint,
      );
    }

    if (selectedIndex == -1) {
      _drawNumber(canvas, center, tickRadius - 30, -pi / 2, "12");
      _drawNumber(canvas, center, tickRadius - 30, 0, "3");
      _drawNumber(canvas, center, tickRadius - 30, pi / 2, "6");
      _drawNumber(canvas, center, tickRadius - 30, pi, "9");
    }
  }

  void _drawNumber(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFFD0D0D0),
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    final offset = Offset(
      center.dx + radius * cos(angle) - painter.width / 2,
      center.dy + radius * sin(angle) - painter.height / 2,
    );

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}
