import 'dart:async';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountThankYou extends StatefulWidget {
  const DeleteAccountThankYou({super.key});

  @override
  _DeleteAccountThankYouState createState() => _DeleteAccountThankYouState();
}

class _DeleteAccountThankYouState extends State<DeleteAccountThankYou> {
  final DialogBox dialogBox = DialogBox();

  Future<void> _exitApp() async {
    SystemNavigator.pop();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () {
          return dialogBox.options(
            context,
            'Close',
            'Are you sure you want to exit?',
            _exitApp,
          );
        },
        child: Center(
          // ✅ Center the entire content
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ Shrink-wrap the column
              children: [
                // Thank you image
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/settings/thankYou.png',
                    height: 120.h,
                  ),
                ),

                SizedBox(height: 16.h),

                // Subtext
                Text(
                  'Your account is now deactivated',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: AppColors.grayColor,
                  ),
                ),

                SizedBox(height: 32.h),

                // Sign in button
                // SizedBox(
                //   width: double.infinity,
                //   height: 48.h,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       navigateWithSlideTransition(
                //         context: context,
                //         destinationScreen: Login(),
                //         transitionDuration: const Duration(milliseconds: 200),
                //       );
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.primaryColor,
                //       minimumSize: const Size(double.infinity, 48),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(32),
                //       ),
                //     ),
                //     child: Text(
                //       "Sign In",
                //       style: GoogleFonts.nunitoSans(
                //         color: Colors.white,
                //         fontSize: 16.sp,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 150.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
