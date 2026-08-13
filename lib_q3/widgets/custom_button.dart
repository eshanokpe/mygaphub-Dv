import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color textColor;
  final double fontSize;
  final Color iconColor;
  final bool isLoading;
  final double borderRadius;
  final Color? borderColor;
  final Color color;
  final bool borderSide; // Changed from dynamic to bool

  const CustomButton({ 
    super.key,
    required this.text, 
    this.icon,
    this.borderColor,
    this.iconColor = Colors.white,
    required this.onPressed,
    required this.color,
    this.textColor = Colors.white,
    required this.fontSize,
    this.isLoading = false,
    this.borderSide = true, // Default value for bool
    this.borderRadius = 777.0, // Default to the specific radius
  });

  @override
  Widget build(BuildContext context) {
    // Use ScreenUtil for responsive dimensions
    final double buttonWidth = 343.w; // Use .w for width scaling
    final double buttonHeight = 60.h; // Use .h for height scaling
    // Use .r for radius scaling if you want it responsive, or keep fixed
    final double buttonBorderRadius = borderRadius.r;
    final Color buttonColor = color; // Use the passed color
    final double borderWidth = 1.w; // Use .w or a fixed value if preferred
    // Use ScreenUtil for padding
    final EdgeInsets buttonPadding =
        EdgeInsets.fromLTRB(32.w, 16.h, 24.w, 16.h);

    return Container(
      width: buttonWidth,
      // height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: iconColor,
          padding: buttonPadding,
         
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: borderSide // Use the boolean class member
                ? BorderSide(
                    color: borderColor ??
                        Colors.grey, // Default to grey if borderColor is null
                    width: borderWidth)
                : BorderSide.none, // No border if borderSide is false
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          disabledBackgroundColor: buttonColor.withOpacity(0.6),
        ),
        child: isLoading
            ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, 
                    style: TextStyle(
                        fontSize: fontSize, // Use .sp for font size scaling
                        color: textColor,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 16.sp, // Explicitly size the indicator
                  height: 16.sp, // Make it a square for a perfect circle
                  child: CircularProgressIndicator(
                    strokeWidth:
                        1.5, // Adjust stroke width for a cleaner look
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              ],
            )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: fontSize, // Use .sp for font size scaling
                        color: textColor,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500),
                  ),
                  if (icon != null) SizedBox(width: 4.w), // Scale spacing
                  if (icon != null)
                    Icon(
                      icon,
                      // Scale icon size relative to font size
                      size: 16.sp,
                      color: iconColor,
                    ),
                ],
              ),
      ),
    );
  }
}
