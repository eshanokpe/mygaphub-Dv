import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'buildGradientCircularIndicator.dart';

class FICardTimeBottomSheet extends StatelessWidget {
  final String title;
  final String current;
  final num time360Value;
  final String time360;
  final List<Color> percentGradient;
  final double currentPer;
  final String currency;

  const FICardTimeBottomSheet({
    super.key,
    required this.title,
    required this.current,
    required this.time360Value,
    required this.time360,
    required this.percentGradient,
    required this.currentPer,
    required this.currency,
  }); 

  TextSpan _formatNumber(num value) {
    // Format to 2 decimal places with thousand separators
    final parts = value.toStringAsFixed(2).split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    final decimalPart = parts[1];

    return TextSpan(
      children: [
        TextSpan(text: wholePart),
        TextSpan(
          text: '.$decimalPart',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp, // smaller size
            color: Colors.grey[600], // grey color
          ),
        ),
      ],
    );
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
                padding:  EdgeInsets.symmetric(horizontal: 16.w),
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
                center: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    time360Value > 1000
                        ? GradientText(
                            text: '999+',
                            gradientColors: _safeGradient(percentGradient),
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w900,
                          )
                        : GradientText(
                            text: time360,
                            gradientColors: _safeGradient(percentGradient),
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w900,
                          ),
                    const SizedBox(width: 2),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: _safeGradient(percentGradient),
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/hourglass.svg',
                        width: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                    'Current balance in Alpha',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text.rich(
                    _buildAverageSeedText(currency, time360Value),
                  ),
                 ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: _safeGradient(percentGradient),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    child: Text(
                      '$time360 days',
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
                    '360 days',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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