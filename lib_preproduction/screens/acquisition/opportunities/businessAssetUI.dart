import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessAssetUI extends StatelessWidget {
  const BusinessAssetUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 174.h),
        Center(
          child: Column(
            children: [
              SizedBox(
                height: 104.h,
                child: Image.asset(
                  'assets/icons/sadheart.png',
                  fit: BoxFit.cover,
                  width: 104.w,
                ),
              ),
              Text(
                'No opportunities listed yet',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xff808080),
                ),
              ),
              Text(
                'Check back soon for updates!',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xff808080),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
