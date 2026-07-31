import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/more/viewProfile/edit_dateofbirth_profile.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RetirementDOBBottomSheet extends StatelessWidget {
  final String title;
  final VoidCallback? onDobUpdated;

  const RetirementDOBBottomSheet({
    super.key,
    required this.title,
    this.onDobUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Providers>();
    final dobRaw = provider.details[4];

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
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Please add your date of birth as it is essential for adding a pension account and improving calculation accuracy.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                  ),
                ),
                SizedBox(height: 30.h),
                CustomButton(
                  text: '+ Add Date of Birth',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () async {
                    // 1. Close the bottom sheet
                    Navigator.pop(context);

                    // 2. Navigate to Edit Screen and WAIT for it to finish
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDateOfBirthScreen(
                          initialDate: dobRaw ?? '',
                          details: provider.details,
                          sourcePage: 'retirement',
                        ),
                      ),
                    );

                    // 3. Once user returns (pops), refresh the retirement data
                    // This ensures the API data matches the new DOB if needed
                    onDobUpdated?.call();
                  },
                  color: AppColors.primaryColor,
                  textColor: AppColors.contentColorWhite,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
