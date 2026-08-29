import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/screens/360/accounts/assets/provider/equity_provider.dart';

class SuccessModalAssets extends ConsumerWidget {
  final String message;
  final VoidCallback onClose;
  final String imagePath;
  // We keep this, but we'll use it smarter to avoid double-refreshing
  final VoidCallback? onRefresh;

  const SuccessModalAssets({
    super.key,
    required this.message,
    required this.onClose,
    this.imagePath = 'assets/images/thankYou.png',
    this.onRefresh,
  });

  static Future<void> show({
    required BuildContext context,
    required String message,
    required VoidCallback onClose,
    String imagePath = 'assets/images/thankYou.png',
    VoidCallback? onRefresh,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessModalAssets(
          message: message,
          onClose: onClose,
          imagePath: imagePath,
          onRefresh: onRefresh,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              // Note: 120.w horizontal padding might be too wide on small screens.
              // Consider using a fixed width or less padding if it overflows.
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
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
            _LoadingButton(
              onPressed: () async {
                // 1. Refresh the data
                final ok = await ref
                    .read(equityProvider.notifier)
                    .refreshEquity();

                if (ok) {
                  // 2. Call onRefresh ONLY if it does something OTHER than refreshing equity
                  // (See explanation below)
                  onRefresh?.call();

                  // 3. Close the Modal
                  Navigator.pop(context);

                  // 4. Close the Equitydetails form screen (returning to dashboard)
                  // ⚠️ Ensure this double-pop is your intended behavior!
                  Navigator.pop(context);
                } else {
                  // Fetch failed — surface it instead of silently closing
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ref.read(equityProvider).error ??
                              'Failed to refresh equity.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed; // ✅ Changed to return Future<void>

  const _LoadingButton({required this.onPressed});

  @override
  State<_LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<_LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
            side: BorderSide(color: AppColors.borderColor, width: 0.5.w),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          backgroundColor: _isLoading ? Colors.grey[300] : Colors.white,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Text(
                'Close',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ CRITICAL FIX: Added 'await' here!
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
