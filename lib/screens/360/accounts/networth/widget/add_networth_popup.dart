import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilities.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../portfolio/assetclasses.dart';
import '../../assets/assets.dart';
import '../../cash/cash.dart';
import '../../cash/cashdetails.dart';
import '../../income/income.dart';
import '../../investment/investdash.dart';
import '../../protection/addProtection/add_protection.dart';
import '../../retirement/presentation/add_pension.dart';
import '../../retirement/presentation/retiredash.dart';
import '../../retirement/presentation/widget/category_of_pensionScreen.dart';

class AddNetworkPopup extends StatelessWidget {
  final String title;
  final String subTitle;

  const AddNetworkPopup({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
        color: Colors.white, // Background color for the bottom sheet
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0.h),
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
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                ),
              ),
              subTitle.isNotEmpty
                  ? Column(
                      children: [
                        Text(
                          subTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    )
                  : Container(),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/income_icon.png',
                title: 'Income',
                subTitle: '',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Income()),
                  );
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/cash_icon.png',
                title: 'Liabilities',
                subTitle: '',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Liabilities(),
                    ),
                  );
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/assets_icon.png',
                title: 'Asset',
                subTitle: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Assets()),
                  );
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/cash_icon.png',
                title: 'Cash',
                subTitle: '',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Income()),
                  );
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/protection_icon.png',
                title: 'Protection',
                subTitle: '',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProtectionScreen(),
                    ),
                  );
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/retirement_icon.png',
                title: 'Retirement ',
                subTitle: '(Pension)',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddPensionScreen(),
                    ),
                  );
                },
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.5.h,
                height: 2.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/mortgage_icon.png',
                title: 'Mortgage',
                subTitle: '',
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const AddHomeEquity(),
                  //   ),
                  // );
                },
              ),
              SizedBox(height: 30.h),
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
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentRow({
    required String assetPath,
    required String title,
    required String subTitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.blue.withOpacity(0.2), // ripple color
      highlightColor: Colors.blue.withOpacity(0.1), // hold-down color
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
              Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
              SizedBox(width: 16.w),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subTitle,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: AppColors.grayColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20.w,
                      color: const Color(0xFFBFBFBF),
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
