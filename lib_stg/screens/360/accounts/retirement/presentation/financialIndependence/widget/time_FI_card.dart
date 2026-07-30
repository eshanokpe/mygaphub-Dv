import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'summary_recommendations_bottomSheet.dart';

class TimeFICard extends StatelessWidget {
  final String timeText;
  final num timeFiniancialValue;
  final num monthlyAsset;
  final num incomeValue;
  final num assetValue;
  final dynamic roceValue;
  final String emoji;
  final String currency;
   
  const TimeFICard({
    super.key,
    this.timeText = 'Time to Financial Independence',
    required this.timeFiniancialValue,
    required this.monthlyAsset,
    required this.incomeValue,
    required this.roceValue,
    required this.assetValue,
    required this.currency,
    this.emoji = '😕',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:  EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(
          strokeAlign: 0.7,
          color: const Color(0xffEEEEEE)
        )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            timeText,
            textAlign: TextAlign.center,
            style:  GoogleFonts.nunitoSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),

          // timeFiniancialValue + Emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${timeFiniancialValue.round()} Years",
                overflow: TextOverflow.ellipsis,
                style:  GoogleFonts.nunitoSans(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                emoji,
                style:  TextStyle(fontSize: 22.sp),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Summary Recommendation
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(56.0),
                        topRight: Radius.circular(56.0),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return  SummaryRecommendationsBottomSheet(
                        title: 'Summary & Recommendations',
                        incomeValue: incomeValue,
                        assetValue: assetValue,
                        percentageValue:roceValue,
                        monthlyValue:monthlyAsset,
                        timeFiniancialValue:timeFiniancialValue,
                        currency:currency
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  padding:  EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(
                      width: 0.5,
                      color: Color(0xffEDEDED)
                    )
                  ),
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 20.w, color: Colors.black54),
                    SizedBox(width: 8.w),
                    Text(
                      'Summary & Recommendations',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}