import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editTarget/assetTarget/edit_asset_target.dart';
import 'editTarget/edit_budget_target.dart';
import 'editTarget/edit_income_target.dart';
import 'editTarget/edit_liabilities_target.dart';

class ThreesixtyCategoryBottomSheet {
  final BuildContext context;
  final Map providerData;

  ThreesixtyCategoryBottomSheet(this.context, this.providerData);

  void show() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16.0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffcdcdcd),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Select a category to edit',
                textAlign: TextAlign.left,
                style: GoogleFonts.nunitoSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(height: 20.h),
              _buildCategoryRow(
                assetPath: 'assets/wheel_segments/income_icon.png',
                label: 'Income',
                onTap: () {
                  context.read<Providers>().setSettarget(providerData);
                  context.read<Providers>().settarget;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditIncomeTarget(),
                    ),
                  );
                },
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildCategoryRow(
                assetPath: 'assets/wheel_segments/liabilities_icon.png',
                label: 'Liabilities',
                onTap: () async {
                  context.read<Providers>().setSettarget(providerData);
                  context.read<Providers>().settarget;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditLiabilitiesTarget(),
                    ),
                  );
                },
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildCategoryRow(
                assetPath: 'assets/wheel_segments/assets_icon.png',
                label: 'Asset',
                onTap: () {
                  context.read<Providers>().setSettarget(providerData);
                  context.read<Providers>().settarget;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditAssetTarget(),
                    ),
                  );
                },
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildCategoryRow(
                assetPath: 'assets/wheel_segments/expenditure_icon.png',
                label: 'Budget',
                onTap: () {
                  context.read<Providers>().setSettarget(providerData);
                  context.read<Providers>().settarget;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditBudgetTarget(),
                    ),
                  );
                },
              ),
              SizedBox(height: 40.h),
              CustomButton(
                text: 'Close',
                fontSize: 16,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: 30.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow({
    required String assetPath,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.cardColor2, // Background color
                border: Border.all(
                  color: AppColors.borderColor, // Border color
                  width: 0.5, // Border width
                ),
                borderRadius: BorderRadius.circular(
                  30,
                ), // Optional: rounded corners
              ),
              child: Center(
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    await canLaunch(url)
        ? launch(url)
        : ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
  }
}
