import 'package:flutter/material.dart';

class WheelItem {
  final String title;
  final String activeCardPath;
  final String segmentPath;
  final String centerIconPath;
  final String centerWheelIconPath;
  final List<Color> gradienColor;
  final double iconRotation;

  WheelItem({
    required this.title,
    required this.activeCardPath,
    required this.segmentPath,
    required this.centerIconPath,
    required this.centerWheelIconPath,
    required this.gradienColor,
    this.iconRotation = 0.0,
  });
}
