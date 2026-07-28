import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'essential_video_screen.dart';
import 'widgets/welcome_strategy_subwidgets.dart';

class StrategyEmptyScreen extends StatelessWidget {
  const StrategyEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 48.h),

            // Title
            const TitleText(),

            SizedBox(height: 16.h),

            // Subtitle
            const Subtitle(),

            const Spacer(),

            // Illustration container
            const Align(
              alignment: Alignment.center,
              child: IllustrationBlock(),
            ),

            const Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 64.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                onPressed: () {
                  // Add your navigation logic here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EssentialVideoScreen(
                        videoUrl:
                            'https://youtu.be/a02tWufmsos?is=lFcOxU5DhS7x6PtD',
                        thumbnailAssetPath: 'assets/action_plan/video_img.png',
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_ios, size: 18.w),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
