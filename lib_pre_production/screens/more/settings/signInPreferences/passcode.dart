import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'changePasscode.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  List<String> enteredDigits = [];
  bool _isProcessing = false;

  void _onKeyTap(String value) async {
    if (enteredDigits.length < 6 && !_isProcessing) {
      setState(() {
        enteredDigits.add(value);
        _isProcessing = true;
      });

      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() => _isProcessing = false);

      // Auto-submit when 6 digits entered
      if (enteredDigits.length == 6) {
        _verifyPasscode();
      }
    }
  }

  void _verifyPasscode() async {
    // Your verification logic here
    await Future.delayed(const Duration(milliseconds: 300));
    // On success:
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasscodeScreen(source: 'forgotPin'),
      ),
    );
    // On failure:
    // _onClear();
  }

  void _onClear() {
    setState(() {
      enteredDigits.clear();
    });
  }

  void _onBackspace() {
    if (enteredDigits.isNotEmpty) {
      setState(() {
        enteredDigits.removeLast();
      });
    }
  }

  Widget _buildDot(bool filled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuad,
      margin: EdgeInsets.symmetric(horizontal: 5.5.w),
      width: 14.w,
      height: 14.h,
      decoration: BoxDecoration(
        color: filled ? AppColors.primaryColor : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildKeyForgot(String label, {VoidCallback? onTap, Color? color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(45.r),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label, {VoidCallback? onTap, Color? color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(45.r),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        actions: const [HelpWidget()],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Title with smooth fade-in
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Enter your ',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22.sp,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'GAPhub',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' passcode',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22.sp,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                'Verify that this account belongs to you',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 100.h),

              // Dots with smooth fill animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return _buildDot(index < enteredDigits.length);
                  }),
                ),
              ),

              SizedBox(height: 100.h),

              // Number Pad with ripple effects
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    ...List.generate(9, (index) {
                      final number = (index + 1).toString();
                      return _buildKey(number, onTap: () => _onKeyTap(number));
                    }),

                    _buildKeyForgot(
                      'Forgot?',
                      onTap: () {
                        // Handle forgot passcode
                      },
                      color: AppColors.primaryColor,
                    ),
                    _buildKey('0', onTap: () => _onKeyTap('0')),
                    _buildKey('⌫', onTap: _onBackspace),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
