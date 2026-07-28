import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessModal extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const SuccessModal({super.key, required this.message, this.onClose});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Top Illustration Container
              Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffFBFBFB),
                  borderRadius: BorderRadius.circular(20),
                  border: BoxBorder.all(
                    color: const Color(0xffeeeeeee),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/thankYou.png",
                    height: 120.h,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 30),

              /// Close Button
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: () async {
                    if (onClose != null) {
                      onClose!();
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Close",
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
