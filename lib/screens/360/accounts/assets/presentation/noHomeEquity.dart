import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/add_protection_popup.dart';

class NoHomeEquity extends StatelessWidget {
  const NoHomeEquity({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Fixed: No MediaQuery during layout - use fixed or relative size
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 80.h),
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: Image.asset(
              'assets/wheel_segments/no_homeEquity.png',
              width: 104.w,
              height: 104.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Oops, Nothing to see here",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xffC7C7C7),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 60.h),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(56.0),
                    topRight: Radius.circular(56.0),
                  ),
                ),
                builder: (BuildContext context) {
                  return const AddAssetsPopup(
                    title: "Add Home Equity",
                    subTitle: "Choose the type of asset you will like to add",
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.primaryColor, size: 22.sp),
                SizedBox(width: 2.w),
                Text(
                  "Add Home Equity",
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
