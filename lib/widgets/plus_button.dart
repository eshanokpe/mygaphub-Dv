import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlusButton extends StatelessWidget {
  final String text;
  final bool isButtonEnabled;
  final Color textColor;
  final VoidCallback onPressed;
  final IconData icons;
  final Color iconsColor;
  final Color color;
  final double? fontSize; // Optional custom font size
  final double? iconSize; // Optional custom icon size
  final double? maxFontSize; // Maximum font size for larger screens
  final double? minFontSize; // Minimum font size for smaller screens

  const PlusButton({
    super.key,
    this.isButtonEnabled = false,
    required this.icons,
    required this.iconsColor,
    required this.color,
    required this.text,
    required this.textColor,
    required this.onPressed,
    this.fontSize,
    this.iconSize,
    this.maxFontSize,
    this.minFontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Calculate responsive font size based on screen width
    double getResponsiveFontSize() {
      // Base font size calculation using screen width
      double baseSize = size.width * 0.035; // 3.5% of screen width

      // Cap the font size based on orientation and screen size
      if (isPortrait) {
        baseSize = baseSize.clamp(12.0, 16.0); // Portrait: between 12 and 16
      } else {
        baseSize = baseSize.clamp(10.0, 14.0); // Landscape: between 10 and 14
      }

      // Apply custom min/max if provided
      if (minFontSize != null)
        baseSize = baseSize.clamp(minFontSize!, double.infinity);
      if (maxFontSize != null) baseSize = baseSize.clamp(0, maxFontSize!);

      return baseSize;
    }

    // Calculate responsive icon size
    double getResponsiveIconSize() {
      double baseSize = size.width * 0.045; // 4.5% of screen width

      if (isPortrait) {
        baseSize = baseSize.clamp(16.0, 22.0);
      } else {
        baseSize = baseSize.clamp(14.0, 20.0);
      }

      return baseSize;
    }

    // Define dynamic sizes for padding
    final horizontalPadding = size.width * 0.03;
    final verticalPadding = size.height * 0.012;
    final iconTextGap = size.width * 0.015;

    return ElevatedButton(
      onPressed: isButtonEnabled ? null : onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[300]!; // Color for disabled state
          }
          return color; // Default button color
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xffD0D5DD),
              width: 0.5, // Border width
            ),
          ),
        ),
        minimumSize: WidgetStateProperty.all(
          Size(
            size.width * 0.15,
            size.height * 0.045,
          ), // Responsive minimum size
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons,
              color: iconsColor,
              size: iconSize ?? getResponsiveIconSize(),
            ),
            SizedBox(width: iconTextGap),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Changed to 1 for better responsiveness
                  style: TextStyle(
                    fontSize: fontSize ?? getResponsiveFontSize(),
                    color: isButtonEnabled ? Colors.grey : textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
