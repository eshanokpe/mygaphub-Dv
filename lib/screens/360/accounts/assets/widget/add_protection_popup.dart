import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../portfolio/assetclasses.dart';
import '../../cash/cash.dart';
import '../../cash/cashdetails.dart';
import '../../investment/investdash.dart';
import '../../retirement/presentation/retiredash.dart';
import '../../retirement/presentation/widget/category_of_pensionScreen.dart';
import '../presentation/equitydetails.dart';
import '../presentation/add_homequity.dart';

class AddAssetsPopup extends StatelessWidget {
  final String title;
  final String subTitle;

  const AddAssetsPopup({
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
              Text(
                subTitle,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              _buildContentRow(
                assetPath: 'assets/wheel_segments/investment_icon.png',
                title: 'Investment',
                subTitle: 'Enter your Insurance details manually',
                onTap: () {
                  getAssetClasses(context, () async {
                    context.read<Providers>().addAssetAcquisition(
                      context.read<Providers>().httpData,
                    );
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssetClasses(const ["existing"]),
                      ),
                    );
                  });
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
                subTitle: 'Sync and add Insurance automatically',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Cash()),
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
                title: 'Pension',
                subTitle: 'Sync and add Insurance automatically',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryOfPensionScreen(),
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
                assetPath: 'assets/wheel_segments/home_equity_icon.png',
                title: 'Home Equity',
                subTitle: 'Sync and add Insurance automatically',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHomeEquity(),
                    ),
                  );
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
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }
}
