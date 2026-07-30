import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback? onTap;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24.h,
        width: 110.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 5,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedCategory,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5.w),
            Image.asset(
              'assets/wheel_segments/dropdown.png',
              width: 10.w,
              height: 10.w,
            ),
          ],
        ),
      ),
    );
  }
}
