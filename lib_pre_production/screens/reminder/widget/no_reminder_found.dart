import 'package:GapHub/screens/reminder/addreminder.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoReminderFound extends StatelessWidget {
  const NoReminderFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 150.h),
            Image.asset('assets/images/noreminder.png', width: 200.h),

            Align(
              alignment: Alignment.center,
              child: Text(
                'You have set no reminders',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grayColor,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Button
            SizedBox(
              // width: 201.w,
              height: 60.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddReminder(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 32.w,
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
                label: Text(
                  'Set a new reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}
