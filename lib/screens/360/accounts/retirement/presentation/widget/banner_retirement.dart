import 'package:GapHub/screens/360/wheel/360WheelScreen.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RetirementBanner extends StatelessWidget {
  final String currency;
  final num pensionAmount;
  final dynamic pensionList;
  const RetirementBanner({
    super.key,
    required this.currency,
    required this.pensionAmount,
    required this.pensionList,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(pensionAmount);
    final parts = formattedAmount.split('.');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          // Use ternary operator instead of if/else
          image: pensionList.isNotEmpty
              ? const AssetImage(
                  'assets/wheel_segments/blur_retirement_data.png',
                )
              : const AssetImage('assets/wheel_segments/blur_retirement.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  return const CustomBottomSheet(
                    title: "Retirement",
                    content:
                        "This captures your pension contributions, both private and employer and state pension",
                  );
                },
              );
            },
            child: Row(
              children: [
                Text(
                  'Pension pot',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'i',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9F29),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
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
                  return const CustomBottomSheet(
                    title: "Retirement",
                    content:
                        "This captures your pension contributions, both private and employer and state pension",
                  );
                },
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency${parts[0]}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '.${parts.length > 1 ? parts[1] : '00'}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () {
              Future.microtask(() => _showWheelBottomSheet(context));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Retirement',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: SizedBox(
                          height: 12.w,
                          child: Icon(Icons.keyboard_arrow_up, size: 16.w),
                        ),
                      ),
                      // Negative margin to pull arrows closer
                      Transform.translate(
                        offset: const Offset(
                          0,
                          -2.5,
                        ), // adjust this value as needed
                        child: SizedBox(
                          height: 14.w,
                          child: Icon(Icons.keyboard_arrow_down, size: 16.w),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWheelBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
      ),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(56.0),
            topRight: Radius.circular(56.0),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 16.sp),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 160),
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xffCDCDCD),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7.sp),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: Colors.black, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Close',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: ThreesSixtyWheelScreen(initialCategory: "Retirement"),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // setState(() {
      //   isDropdownActive = false;
      // });
    });
  }
}
