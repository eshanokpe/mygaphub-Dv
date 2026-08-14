import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/utils/colors.dart'; // Adjust import to your project structure

class InvestmentInfoBottomSheet extends StatelessWidget {
  const InvestmentInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.72,
      maxChildSize: 0.72,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  'The Power of Investment',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 24.h),

                // List Items
                const _InfoItem(
                  img: 'assets/action_plan/wealth.png',
                  title: 'Wealth Growth Over Time',
                  description:
                      'Investing allows your money to grow over time through compound interest and capital appreciation, building wealth for the future.',
                ),
                SizedBox(height: 20.h),

                const _InfoItem(
                  img: 'assets/action_plan/target2.png',
                  title: 'Achieving Financial Goals',
                  description:
                      'Investing provides a pathway to achieve long-term goals, such as retirement or buying a house, by growing capital.',
                ),
                SizedBox(height: 20.h),

                const _InfoItem(
                  img: 'assets/action_plan/umbralle.png',
                  title: 'Protection Against Inflation',
                  description:
                      'Investments can offer higher returns than savings accounts and help protect your money from being eroded by inflation.',
                ),

                SizedBox(height: 32.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper Widget for each list item
class _InfoItem extends StatelessWidget {
  final String img;
  final String title;
  final String description;

  const _InfoItem({
    required this.img,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Circle
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5), // Light grey background
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              img,
              width: 28.w,
              height: 28.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: 16.w),

        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                description,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF272727), // Dark grey for body text
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
