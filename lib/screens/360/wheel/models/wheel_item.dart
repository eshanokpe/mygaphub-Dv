import 'package:flutter/material.dart';

class WheelItem {
  final String title;
  final String activeCardPath;
  final String segmentPath;
  final String centerIconPath;
  final String centerWheelIconPath;
  final List<Color> gradienColor;
  final double iconRotation; // ← now used when THIS item is active/selected
  final double childIconRotation; // ← NEW: used when this item is NOT selected

  WheelItem({
    required this.title,
    required this.activeCardPath,
    required this.segmentPath,
    required this.centerIconPath,
    required this.centerWheelIconPath,
    required this.gradienColor,
    this.iconRotation = 0.0,
    this.childIconRotation = 0.0, // ← NEW, defaults to upright
  });
}
