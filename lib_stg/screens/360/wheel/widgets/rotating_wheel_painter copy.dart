import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../models/wheel_item.dart';

class RotatingWheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final double rotation;
  final int selectedIndex;
  final List<ui.Image> segmentImages;
  final List<ui.Image> _centerIcons;

  RotatingWheelPainter(
    this.items,
    this.rotation,
    this.selectedIndex,
    this.segmentImages,
    this._centerIcons,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Fill the entire canvas with white first
    canvas.drawColor(Colors.white, BlendMode.srcOver);

    final radius = size.width / 2.0;
    final center = Offset(radius, radius);
    final sweep = 2 * pi / items.length;

    // Draw the outer ring segments
    for (int i = 0; i < items.length; i++) {
      final startAngle = sweep * i + rotation;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startAngle, sweep, false)
        ..close();

      // Draw segment with image if available, otherwise show placeholder
      if (i < segmentImages.length && segmentImages.isNotEmpty) {
        canvas.save();
        canvas.clipPath(path);

        final image = segmentImages[i];
        final double scale = (2 * radius) / min(image.width, image.height);
        final double scaledWidth = image.width * scale;
        final double scaledHeight = image.height * scale;

        final double left = center.dx - scaledWidth / 2;
        final double top = center.dy - scaledHeight / 2;

        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(startAngle + sweep / 2);
        canvas.translate(-center.dx, -center.dy);

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(left, top, scaledWidth, scaledHeight),
          Paint(),
        );

        canvas.restore();
        canvas.restore();
      } else {
        // Placeholder while images load
        final placeholderPaint = Paint()
          ..color = Colors.grey.shade200
          ..style = PaintingStyle.fill;

        canvas.drawPath(path, placeholderPaint);

        // Add subtle border
        final borderPaint = Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawPath(path, borderPaint);
      }
    }

    // Draw white center circle
    final whiteCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double whiteCenterRadius = radius * 0.48;
    canvas.drawCircle(center, whiteCenterRadius, whiteCenterPaint);

    // Add border around white center
    final centerBorderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, whiteCenterRadius, centerBorderPaint);

    // Draw center icons if available
    for (int i = 0; i < items.length; i++) {
      if (i < _centerIcons.length && _centerIcons.isNotEmpty) {
        canvas.save();

        final startAngle = sweep * i + rotation;
        final iconRadius = radius * 0.75;
        const positionInSegment = 0.50;
        final iconAngle = startAngle + (sweep * positionInSegment);

        final iconX = center.dx + iconRadius * cos(iconAngle);
        final iconY = center.dy + iconRadius * sin(iconAngle);
        final iconOffset = Offset(iconX, iconY);

        final icon = _centerIcons[i];

        final double iconSize = radius * 0.18;
        final double iconScale = iconSize / max(icon.width, icon.height);
        final double iconWidth = icon.width * iconScale;
        final double iconHeight = icon.height * iconScale;
        final double circleSize = max(iconWidth, iconHeight) * 1.4;

        // Draw circle background
        final circlePaint = Paint()
          ..color = const Color(0x57FFFFFF)
          ..style = PaintingStyle.fill;

        final circleBorderPaint = Paint()
          ..color = const Color(0x24E4E4E4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7;

        canvas.drawCircle(iconOffset, circleSize / 2, circlePaint);
        canvas.drawCircle(iconOffset, circleSize / 2, circleBorderPaint);

        // Draw icon
        canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(
            iconX - iconWidth / 2,
            iconY - iconHeight / 2,
            iconWidth,
            iconHeight,
          ),
          Paint(),
        );

        canvas.restore();
      }
    }

    // Draw outer circle border
    final outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, outerBorderPaint);

    // Outer circle with inner shadow
    final outerInnerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 4.229)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    canvas.drawCircle(center, radius, outerInnerShadowPaint);
  }

  @override
  bool shouldRepaint(covariant RotatingWheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.segmentImages != segmentImages ||
        oldDelegate._centerIcons != _centerIcons;
  }
}
