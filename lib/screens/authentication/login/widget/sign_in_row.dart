import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildSignInRow({
  BuildContext? context,
  String? questionText,
  String? signInText,
  Color? questionColor,
  Color? signInColor,
  VoidCallback? onTap,
}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            questionText!,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: questionColor,
            ),
          ),
          const SizedBox(width: 5), // Adjust spacing between texts if needed
          InkWell(
            onTap: onTap,
            child: Text(
              signInText!,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: signInColor,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.h),
    ],
  );
}
