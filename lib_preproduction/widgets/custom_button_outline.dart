import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonOutline extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const CustomButtonOutline({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.color = Colors.blue, // Default button color
    this.textColor = Colors.blue, // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          side: const BorderSide(color: AppColors.grayColor, width: 0.5),
          textStyle: TextStyle(fontSize: 18.sp, color: Colors.white),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
