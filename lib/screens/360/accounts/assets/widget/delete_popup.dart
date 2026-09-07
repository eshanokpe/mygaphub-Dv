import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeletePopup extends StatefulWidget {
  final String title;
  final Future<void> Function() onConfirm;

  const DeletePopup({super.key, required this.title, required this.onConfirm});

  @override
  State<DeletePopup> createState() => _DeletePopupState();
}

class _DeletePopupState extends State<DeletePopup> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
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
                Center(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'This asset will be permanently deleted. This action cannot be reversed once the account has been deleted.',
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
                  text: 'Go Back',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: AppColors.primaryColor,
                  onPressed: () => Navigator.pop(context),
                  textColor: AppColors.contentColorWhite,
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: 'Delete Asset',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  isLoading: _isDeleting,
                  onPressed: _isDeleting
                      ? null
                      : () async {
                          setState(() => _isDeleting = true);
                          await widget.onConfirm();
                          if (mounted) setState(() => _isDeleting = false);
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
