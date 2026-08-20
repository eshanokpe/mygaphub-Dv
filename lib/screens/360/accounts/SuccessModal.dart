import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/retiredash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/utils/colors.dart';

class SuccessModal extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final String imagePath;
  final VoidCallback? onRefresh;

  const SuccessModal({
    super.key,
    required this.message,
    required this.onClose,
    this.imagePath = 'assets/images/thankYou.png',
    this.onRefresh,
  });

  /// Convenience method to show this dialog without manually calling showDialog everywhere.
  static Future<void> show({
    required BuildContext context,
    required String message,
    required VoidCallback onClose,
    String imagePath = 'assets/images/thankYou.png',
    final VoidCallback? onRefresh,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessModal(
          message: message,
          onClose: onClose,
          imagePath: imagePath,
          onRefresh: onRefresh,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 120.w, vertical: 5.w),
              child: Image.asset(
                imagePath,
                height: 100.h,
                width: 100.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
                  final navigator = Navigator.of(context);

                  navigator.pop();
                  await Future<void>.delayed(Duration.zero);
                  if (!navigator.mounted) return;

                  await navigator.push(
                    MaterialPageRoute(builder: (_) => const Retiredash()),
                  );
                  if (navigator.mounted) {
                    onClose();
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    side: BorderSide(
                      color: AppColors.borderColor,
                      width: 0.5.w,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
