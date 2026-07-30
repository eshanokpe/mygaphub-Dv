import 'dart:ui';

import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppAppearanceSheet {
  final BuildContext context;

  AppAppearanceSheet(this.context);

  void show() {
    const selectedColor = AppColors.primaryColor;
    const disabledColor = AppColors.grayColor;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffcdcdcd),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'App Appearance',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Change the look of your app',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: const Color(0xff393737),
                ),
              ),
              SizedBox(height: 32.h),

              // Light option (selected)
              InkWell(
                onTap: () {
                  // Handle Light option tap
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Text(
                      'Light',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.check, color: selectedColor),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dark option (disabled)
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 1.5,
                  sigmaY: 1.5,
                ), // Increase sigma for stronger blur
                child: Opacity(
                  opacity: 0.6, // Optional: makes it slightly faded as well
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: disabledColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coming soon...',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w300,
                          fontSize: 14.sp,
                          color: disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              // System Settings option (enabled)
              InkWell(
                onTap: () {
                  // Handle System Settings tap
                  Navigator.pop(context);
                },
                child: Text(
                  'System Settings',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}
