// widgets/rotating_wheel_painter.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../models/wheel_item.dart';

class RotatingWheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final double rotation;
  final int selectedIndex;
  final List<ui.Image> centerIcons;
  final List<List<Color>> gradientColors;
  final List<List<double?>> childWheelRotations;

  RotatingWheelPainter(
    this.items,
    this.rotation,
    this.selectedIndex,
    this.centerIcons,
    this.gradientColors,
    this.childWheelRotations,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final radius = size.width / 2.0;
    final center = Offset(radius, radius);
    final sweep = 2 * pi / items.length;

    // ── Gradient segments ───────────────────────────────────────────────────
    for (int i = 0; i < items.length; i++) {
      final startAngle = sweep * i + rotation;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startAngle, sweep, false)
        ..close();

      final colors =
          (i < gradientColors.length && gradientColors[i].length >= 2)
          ? gradientColors[i]
          : [Colors.grey.shade200, Colors.grey.shade400];

      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.sweep(center, colors)
          ..style = PaintingStyle.fill,
      );
    }

    // ── White center circle ─────────────────────────────────────────────────
    final double whiteCenterRadius = radius * 0.48;
    canvas.drawCircle(
      center,
      whiteCenterRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      whiteCenterRadius,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0,
    );

    // ── Center icons ────────────────────────────────────────────────────────
    for (int i = 0; i < items.length; i++) {
      if (i >= centerIcons.length) continue;

      final startAngle = sweep * i + rotation;
      final iconAngle = startAngle + sweep * 0.50; // midpoint of segment

      final double iconRadius = radius * 0.75;
      final iconX = center.dx + iconRadius * cos(iconAngle);
      final iconY = center.dy + iconRadius * sin(iconAngle);
      final iconOffset = Offset(iconX, iconY);

      final icon = centerIcons[i];
      final double iconSize = radius * 0.18;
      final double iconScale = iconSize / max(icon.width, icon.height);
      final double iconWidth = icon.width * iconScale;
      final double iconHeight = icon.height * iconScale;
      final double circleSize = max(iconWidth, iconHeight) * 1.4;

      // Background circle
      canvas.drawCircle(
        iconOffset,
        circleSize / 2,
        Paint()
          ..color = const Color(0x57FFFFFF)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        iconOffset,
        circleSize / 2,
        Paint()
          ..color = const Color(0x24E4E4E4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );

      canvas.save();
      canvas.translate(iconX, iconY);

      // ── Dynamic rotation ─────────────────────────────────────────────────
      canvas.rotate(items[i].centerIconRotation);
      final bool isActive = i == selectedIndex;
      final childRotation = childWheelRotations[selectedIndex][i];
      final double tilt = isActive
          ? items[i].iconRotation
          : (childRotation ?? items[i].childIconRotation);
      canvas.rotate(-rotation + tilt);

      canvas.drawImageRect(
        icon,
        Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
        Rect.fromLTWH(-iconWidth / 2, -iconHeight / 2, iconWidth, iconHeight),
        Paint(),
      );

      canvas.restore();
    }

    // ── Outer border + inner shadow ─────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black.withOpacity(0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 4.229)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
  }

  @override
  bool shouldRepaint(covariant RotatingWheelPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.rotation != rotation ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.centerIcons != centerIcons ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.childWheelRotations != childWheelRotations;
  }
}
