import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_pension_popup.dart';

class NoPension extends StatelessWidget {
  final bool showDOBFlow;
  final VoidCallback onOpenDOBSheet;

  const NoPension({
    super.key,
    required this.showDOBFlow,
    required this.onOpenDOBSheet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          Image.asset(
            'assets/wheel_segments/no_pension.png',
            width: 160.w,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 40.h),
          InkWell(
            onTap: () {
              if (showDOBFlow) {
                onOpenDOBSheet();
              } else {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(56.0),
                      topRight: Radius.circular(56.0),
                    ),
                  ),
                  builder: (context) =>
                      const AddPensionPopup(title: "Pick your option"),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.primaryColor, size: 22.sp),
                SizedBox(width: 2.w),
                Text(
                  "Add Pension Account",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
