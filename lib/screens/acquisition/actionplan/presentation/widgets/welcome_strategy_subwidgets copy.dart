import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: 30.w,
      height: 30.h,
      fit: BoxFit.cover,
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.nunitoSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            children: const [
              TextSpan(text: 'Welcome to ', style: TextStyle(color: AppColors.blackColor),),
              TextSpan(
                text: 'Strategy ',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
        Image.asset("assets/action_plan/arrow_pin.png", width: 18.w,),
      ],
    );
  }
}

class Subtitle extends StatelessWidget {
  const Subtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Build an action plan to guide your strategy, actions, '
      'and accountability across every part of your financial life',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.sp,
        height: 1.4,
      ),
    );
  }
}

class IllustrationBlock extends StatelessWidget {
  const IllustrationBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/action_plan/Interest_loan.png'),
          
        ],
      ),
    );
  }
}