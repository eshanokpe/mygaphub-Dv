import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/utils/colors.dart'; // Adjust import to your project structure

class RecommendedPercentage extends StatelessWidget {
  const RecommendedPercentage({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.80, // Starts at 80% of screen
      minChildSize: 0.4, // Minimum drag height
      maxChildSize: 0.9, // Maximum drag height
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
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
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
                      color: const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  'Recommended Percentages',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 16.h),

                // Disclaimer
                Text(
                  'These figures are intended solely for educational purposes and should not be considered financial advice. Please consult your financial advisor before making any investment decisions.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF272727),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),

                // First Group
                const _PercentageGroup(
                  items: [
                    _PercentageData(label: 'Retirement', value: '20%'),
                    _PercentageData(label: 'Investment', value: '50%'),
                    _PercentageData(label: 'Cash', value: '20%'),
                    _PercentageData(label: 'Equity', value: '10%'),
                  ],
                ),
                SizedBox(height: 16.h),

                // Second Group
                const _PercentageGroup(
                  items: [
                    _PercentageData(label: 'Business Asset', value: '30%'),
                    _PercentageData(label: 'Appreciating Asset', value: '50%'),
                    _PercentageData(label: 'Risk Asset', value: '20%'),
                  ],
                ),
                SizedBox(height: 32.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD0D0D0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
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

// Simple data holder for each row
class _PercentageData {
  final String label;
  final String value;

  const _PercentageData({required this.label, required this.value});
}

// Rounded grey card containing a group of rows separated by thin dividers
class _PercentageGroup extends StatelessWidget {
  final List<_PercentageData> items;

  const _PercentageGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      item.value,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Color(0xFFECECEC),
                ),
            ],
          );
        }),
      ),
    );
  }
}
