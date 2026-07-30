import 'package:GapHub/screens/portfolio/charts/dashmaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalViewContent extends StatelessWidget {
  Map data;
  GlobalViewContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),
        Image.asset(
          'assets/images/mapss.png',
          width: 300.w,
          height: 300.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
