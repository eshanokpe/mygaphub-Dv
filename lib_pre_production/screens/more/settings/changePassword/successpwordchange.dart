import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessPasswordChanged extends StatelessWidget {
  const SuccessPasswordChanged({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Icon
            Image.asset(
              'assets/settings/verified.gif', // Replace with your GIF path
              height: 100,
            ),

            SizedBox(height: 40.h),

            // Title
            Text(
              'Password Changed',
              style: GoogleFonts.nunitoSans(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10.h),

            // Subtitle
            Text(
              'Your password has been changed successfully',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                color: AppColors.grayColor,
              ),
              textAlign: TextAlign.center,
              softWrap: false, // Prevents text from wrapping to next line
              overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
            ),

            const Spacer(),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: const StadiumBorder(),
                  minimumSize: Size(double.infinity, 60.sp),
                ), 
                child: Text(
                  'Back to Settings',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18.sp,
                    color: Colors.white,
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