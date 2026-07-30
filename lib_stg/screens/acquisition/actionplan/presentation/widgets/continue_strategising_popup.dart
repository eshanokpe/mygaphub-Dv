import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/investment_form_controller.dart';
import '../action_plan_strategy.dart';

class ContinueStrategisingPopup extends ConsumerWidget {
  final String title;
  const ContinueStrategisingPopup({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(investmentFormControllerProvider.notifier);

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
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Your progress will be saved and can be easily accessed on the strategy page',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.blackColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 30.h),
                CustomButton(
                  color: AppColors.primaryColor,
                  text: 'Continue Strategy',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () => Navigator.pop(context),
                  textColor: AppColors.contentColorWhite,
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: 'Save for Later',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () async {
                    final saved = await controller.saveAndContinueLater(
                      context,
                    );
                    if (!context.mounted) return;

                    if (saved) {
                      Navigator.pop(context); // ✅ close the bottom sheet first
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActionPlanStrategy(),
                        ),
                      );
                    }
                    // if not saved, the sheet stays open and the error banner shows on the form screen behind it
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
