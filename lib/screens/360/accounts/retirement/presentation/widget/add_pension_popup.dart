import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_of_pensionScreen.dart'; // Ensure this import is correct

class AddPensionPopup extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh; // ✅ 1. Add this parameter

  const AddPensionPopup({
    super.key,
    required this.title,
    this.onRefresh, // ✅ 2. Initialize it
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
            padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
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
                _buildContentRow(
                  assetPath: 'assets/images/manual.png',
                  title: 'Manual',
                  subTitle: 'Enter your Pension details manually',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryOfPensionScreen(
                          onRefresh: onRefresh, // ✅ 3. Pass it down
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 5.h),
                Divider(
                  color: AppColors.dividerColor,
                  thickness: 1.h,
                  height: 1.h,
                  indent: 50.w,
                  endIndent: 30.w,
                ),
                SizedBox(height: 5.h),
                _buildContentRow(
                  assetPath: 'assets/images/automatic.png',
                  title: 'Automatic',
                  subTitle: 'Sync and add Pension account automatically',
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: 30.h),
                CustomButton(
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
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRow({
    required String assetPath,
    required String title,
    required String subTitle,
    required VoidCallback onTap,
  }) {
    // ... [Your existing _buildContentRow code remains the same] ...
    return InkWell(
      splashColor: Colors.blue.withOpacity(0.2),
      highlightColor: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 32.w, height: 32.h),
              SizedBox(width: 16.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subTitle,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w300,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
