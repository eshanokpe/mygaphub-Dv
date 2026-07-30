import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SummaryRecommendationsBottomSheet extends StatelessWidget {
  final String title;
  final num incomeValue;
  final num assetValue;
  final dynamic percentageValue;
  final num monthlyValue;
  final num timeFiniancialValue;
  final String currency;

  const SummaryRecommendationsBottomSheet({
    super.key,
    required this.title,
    required this.incomeValue,
    required this.assetValue,
    required this.percentageValue,
    required this.monthlyValue,
    required this.timeFiniancialValue,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      height: 5.h,
                      width: 45.w,
                      decoration: BoxDecoration(
                        color: const Color(0xffcdcdcd),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                
                // ✅ Updated Text with bold variables using RichText
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                      color: AppColors.grayColor,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'You are currently financially independent with an income of ',
                      ),
                      TextSpan(
                        text: '$currency${NumberFormat('#,##0.00').format(incomeValue)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                      ),
                      const TextSpan(
                        text: ' from your asset portfolio. To reach full financial independence, you need to acquire ',
                      ),
                      TextSpan(
                        text: '$currency${ NumberFormat('#,##0.00').format(assetValue.round())}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                      ),
                      const TextSpan(
                        text: ' in assets that generate a ',
                      ),
                      TextSpan(
                        text: '$percentageValue%',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                      ),
                      const TextSpan(
                        text: ' return on capital employed (ROCE). By investing ',
                      ),
                      TextSpan(
                        text: '$currency${NumberFormat('#,##0.00').format(monthlyValue)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                      ),
                      const TextSpan(
                        text: ' monthly, you can achieve this in ',
                      ),
                      TextSpan(
                        text: '${timeFiniancialValue.round()} years',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                      ),
                      const TextSpan(
                        text: '. Explore the opportunities from our partners in your GAPhub account and explore the acquisition section to start building a profitable global asset portfolio with myGAPhub.',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),
                CustomButton(
                  text: 'Close',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                  textColor: AppColors.blackColor,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}