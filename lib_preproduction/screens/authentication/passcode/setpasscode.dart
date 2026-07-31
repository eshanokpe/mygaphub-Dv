import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'confirmPasscodeScreen.dart';

class SetPasscodeScreen extends StatefulWidget {
  final bool? settings;
  final bool? fromTouchID;
  const SetPasscodeScreen({super.key, this.settings, this.fromTouchID});

  @override
  _SetPasscodeScreenState createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  String _currentPin = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleNumberPressed(int number) {
    if (!mounted) return;

    if (_currentPin.length < 6) {
      setState(() {
        _currentPin += number.toString();
      });

      if (_currentPin.length == 6) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPasscodeScreen(
                  originalPin: _currentPin,
                  settings: widget.settings,
                  fromTouchID: widget.fromTouchID,
                ),
              ),
            );
          }
        });
      }
    }
  }

  void _handleClearPressed() {
    if (!mounted) return;

    setState(() {
      _currentPin = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [HelpWidget()],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight -
              MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Set up your ',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                    ),
                    TextSpan(
                      text: 'GAPhub',
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' passcode',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Subtitle
              Text(
                'Ensure your code is not easy to guess for extra account protection',
                textAlign: TextAlign.left,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grayColor,
                ),
              ),

              SizedBox(height: 100.h),

              // Pin Dots
              _buildPinDots(),

              SizedBox(height: 100.h),

              // Number Pad
              _buildNumPad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final bool isFilled = index < _currentPin.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: isFilled ? 16.w : 12.w,
          height: isFilled ? 16.w : 12.w,
          decoration: BoxDecoration(
            color: isFilled ? Colors.black : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildNumPad() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNumberRow(['1', '2', '3']),
          SizedBox(height: 12.h),
          _buildNumberRow(['4', '5', '6']),
          SizedBox(height: 12.h),
          _buildNumberRow(['7', '8', '9']),
          SizedBox(height: 12.h),
          _buildNumberRow(['', '0', 'Clear'], isLastRow: true),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> values, {bool isLastRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((value) {
        if (value.isEmpty) {
          return SizedBox(width: 70.w, height: 70.h);
        }
        if (value == 'Clear') {
          return _buildClearButton();
        }
        return _buildNumberButton(int.parse(value));
      }).toList(),
    );
  }

  Widget _buildNumberButton(int number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleNumberPressed(number),
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 90.w,
          height: 90.h,

          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.nunitoSans(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleClearPressed,
        borderRadius: BorderRadius.circular(35.r),
        child: Container(
          width: 70.w,
          height: 70.h,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Text(
              'Clear',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
