import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String content;
  // final String buttonText;
  // final VoidCallback onButtonPressed;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.content,
    // @required this.buttonText,
    // @required this.onButtonPressed,
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
        color: Colors.white, // Background color for the bottom sheet
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 0),
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
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    color: AppColors.grayColor,
                    fontSize: 14.sp,
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
