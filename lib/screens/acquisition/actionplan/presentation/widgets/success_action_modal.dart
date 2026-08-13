import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/utils/colors.dart';

class SuccessActionModal extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final String imagePath;
  final VoidCallback? onRefresh;
  final Duration loadingDuration;

  const SuccessActionModal({
    super.key,
    required this.message,
    required this.onClose,
    this.imagePath = 'assets/images/thankYou.png',
    this.onRefresh,
    this.loadingDuration = const Duration(seconds: 2),
  });

  /// Convenience method to show this dialog without manually calling showDialog everywhere.
  static Future<void> show({
    required BuildContext context,
    required String message,
    required VoidCallback onClose,
    String imagePath = 'assets/images/thankYou.png',
    final VoidCallback? onRefresh,
    Duration loadingDuration = const Duration(seconds: 2),
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessActionModal(
          message: message,
          onClose: onClose,
          imagePath: imagePath,
          onRefresh: onRefresh,
          loadingDuration: loadingDuration,
        );
      },
    );
  }

  @override
  State<SuccessActionModal> createState() => _SuccessActionModalState();
}

class _SuccessActionModalState extends State<SuccessActionModal> {
  bool _showSuccessContent = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.loadingDuration, () {
      if (!mounted) return;
      setState(() => _showSuccessContent = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showSuccessContent
              ? _buildSuccessContent()
              : _buildLoadingContent(),
        ),
      ),
    );
  }

  // Shown first, for `loadingDuration`.
  Widget _buildLoadingContent() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/action_plan/loading_effect.gif',
          height: 200.h,
          width: 200.w,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  // Shown after `loadingDuration` has elapsed.
  Widget _buildSuccessContent() {
    return Column(
      key: const ValueKey('success'),
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
            widget.imagePath,
            height: 100.h,
            width: 100.w,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          widget.message,
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
            onPressed: () {
              // First dismiss the dialog
              Navigator.of(context).pop();
              // Then call optional callbacks
              widget.onRefresh?.call();
              widget.onClose.call();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
                side: BorderSide(color: AppColors.borderColor, width: 0.5.w),
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
    );
  }
}
