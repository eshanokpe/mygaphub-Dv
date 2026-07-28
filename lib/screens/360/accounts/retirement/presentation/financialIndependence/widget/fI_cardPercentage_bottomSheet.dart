import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'buildGradientCircularIndicator.dart';

class FICardPercentageBottomSheet extends StatelessWidget {
  final String title;
  final String current;
  final num currentValue;
  final List<Color> percentGradient;
  final double currentPer;
  final String currency;

  const FICardPercentageBottomSheet({
    super.key,
    required this.title,
    required this.current,
    required this.currentValue,
    required this.percentGradient,
    required this.currentPer,
    required this.currency,
  });

  String _formatNumber(num value) {
    try {
      return value.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return '0.00';
    }
  }

  // Ensures percentage is always valid (0.0 - 1.0)
  double _safePercent(double value) {
    return value.clamp(0.0, 1.0);
  }

  // Ensures gradient always has valid colors
  List<Color> _safeGradient(List<Color> colors) {
    return colors.isNotEmpty ? colors : const [Color(0xFF005E32), Color(0xFF007A45)];
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final retireData = providers.retiredata;
    final width = MediaQuery.of(context).size.width;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final averageSeed = retireData['improve_status']['average_seed'] ?? 0.0;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
        color: Colors.white,
      ),
      // Caps how tall the sheet can ever get...
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            18.w,
            12.h,
            18.w,
            24.h + bottomSafeArea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag Indicator
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 5.h,
                  width: 45.w,
                  decoration: BoxDecoration(
                    color: const Color(0xffcdcdcd),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Title
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              GradientCircularIndicator(
                radius: width * 0.19,
                lineWidth: width * 0.042,
                backgroundColor: Colors.grey.withOpacity(0.25),
                center: currentValue > 1000
                    ? GradientText(
                        text: '999+%',
                        gradientColors: _safeGradient(percentGradient),
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w900,
                      )
                    : GradientText(
                        text: '$current%',
                        gradientColors: _safeGradient(percentGradient),
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                      ),
                percent: _safePercent(currentPer),
                gradientColors: _safeGradient(percentGradient),
              ),
              SizedBox(height: 24.h),

              // Current Balance Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current balance in Freedom',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                   Text.rich(
                    _buildAverageSeedText(currency, currentValue),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF005E32),
                        Color(0xFF005E32),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      '$current%',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // SEED Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Average SEED Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text.rich(
                    _buildAverageSeedText(currency, averageSeed),
                  ),
                  Text(
                    '100%',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Fixed gap instead of Spacer — Spacer needs a bounded
              // flex context, which a min-size Column inside a
              // SingleChildScrollView can't give it.
              SizedBox(height: 32.h),

              // Close Button
              SizedBox(
                width: width * 0.7,
                child: CustomButton(
                  text: 'Close',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white,
                  textColor: AppColors.blackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper
    TextSpan _buildAverageSeedText(String currency, num value) {
      final fixed = value.toStringAsFixed(2);
      final parts = fixed.split('.');
      final whole = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      final decimals = '.${parts[1]}';

      return TextSpan(
        children: [
          TextSpan(
            text: '$currency$whole',
            style: GoogleFonts.nunitoSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: decimals,
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

}