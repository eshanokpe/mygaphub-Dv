import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessModal extends StatefulWidget {
  final String message;

  const SuccessModal({super.key, required this.message});

  @override
  State<SuccessModal> createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal> {
 

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Top Illustration
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffFBFBFB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xffeeeeee),
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
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
    
            const SizedBox(height: 30),
    
            /// Close Button — shows spinner while loading
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(
                    color:  Colors.grey.shade300
                  ),
                ),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                          key: const ValueKey('label'),
                          "Close",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
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
