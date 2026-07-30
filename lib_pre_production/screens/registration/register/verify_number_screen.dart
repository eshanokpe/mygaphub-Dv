import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'next_register_screen.dart';

class VerifyNumberScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? dialCode;

  const VerifyNumberScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.dialCode,
  });

  @override
  _VerifyNumberScreenState createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  TextEditingController pinController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  String currentText = "";
  String? phoneNumber;
  String dialCode;
  bool isLoading = false;
  String errorMessage = '';

  _VerifyNumberScreenState() : dialCode = '+44';

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phoneNumber;
    dialCode = widget.dialCode ?? '+44';
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          actions: const [HelpWidget()],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 22.h),
                    Text(
                      "Verify your Number",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Please enter the 6-digit verification code sent to $dialCode $phoneNumber",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grayColor,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          errorMessage,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    PinCodeTextField(
                      controller: pinController,
                      appContext: context,
                      length: 6,
                      animationType: AnimationType.fade,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12.r),
                        fieldHeight: 50.h,
                        fieldWidth: 40.w,
                        activeFillColor: Colors.grey.shade200,
                        selectedFillColor: Colors.grey.shade200,
                        inactiveFillColor: Colors.grey.shade200,
                        inactiveColor: Colors.transparent,
                        selectedColor: Colors.transparent,
                        activeColor: Colors.black,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      onChanged: (value) {
                        setState(() {
                          currentText = value;
                          errorMessage = '';
                        });
                      },
                      onCompleted: (value) async {
                        print("Code entered: $value");
                        await _verifyOtpAndProceed(value);
                      },
                    ),
                    const Spacer(),
                    Center(
                      child: _secondsRemaining > 0
                          ? Text.rich(
                              TextSpan(
                                text: "You can resend a new code in ",
                                style: GoogleFonts.nunitoSans(fontSize: 16.sp),
                                children: [
                                  TextSpan(
                                    text: "${_secondsRemaining}s",
                                    style: GoogleFonts.nunitoSans(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Text(
                                  "Please request a new code and try again",
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.w,
                                      ),
                                    ),
                                    onPressed: _resendOtp,
                                    child: Text(
                                      "Resend Code",
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: SpinKitCircle(color: Colors.white, size: 60.0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtpAndProceed(String otp) async {
    if (otp.length != 6) {
      setState(() {
        errorMessage = 'Please enter a complete 6-digit code';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final verificationResult = await verifyOtp(otp);

      if (verificationResult['success'] == true) {
        // Navigate to next screen on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NextRegisterScreen(
              firstName: widget.firstName,
              lastName: widget.lastName,
              email: widget.email,
              phoneNumber: widget.phoneNumber,
              dialCode: dialCode,
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage =
              verificationResult['message'] ?? 'Invalid verification code';
        });
        showErrorBottomSheet(context, message: errorMessage);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _secondsRemaining = 60;
      pinController.clear();
      errorMessage = '';
    });

    startTimer();

    try {
      final success = await sendOtp();
      if (!success) {
        setState(() {
          errorMessage = 'Failed to resend code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error resending code. Please try again.';
      });
    }
  }

  void showErrorBottomSheet(BuildContext context, {String? message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.stockColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Error",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                message ??
                    "The code you typed in is invalid. Please enter a correct one.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: AppColors.grayColor,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    pinController.clear();
                  },
                  child: Text(
                    "Retry",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  Future<bool> sendOtp() async {
    try {
      String formattedPhoneNumber = phoneNumber?.replaceAll(' ', '') ?? '';
      print('Sending OTP to: $dialCode$formattedPhoneNumber');

      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: jsonEncode({'phone_number': '$dialCode$formattedPhoneNumber'}),
      );

      print('OTP Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("OTP sent successfully: $data");
        return true;
      } else {
        final data = jsonDecode(response.body);
        print("Failed to send OTP: ${response.statusCode}, $data");
        return false;
      }
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      String formattedPhoneNumber = phoneNumber?.replaceAll(' ', '') ?? '';
      print('Verifying OTP for: $dialCode$formattedPhoneNumber');

      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: jsonEncode({
          'phone_number': '$dialCode$formattedPhoneNumber',
          'otp': otp,
        }),
      );

      print('OTP Verification Response: ${response.statusCode}');
      print('OTP Verification Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Check for success based on your response format
        // Your response: {status: true, message: Phone number verified successfully, ...}
        if (data['status'] == true) {
          return {'success': true, 'message': data['message']};
        }

        // Additional success checks for different response formats
        if (data['success'] == true || data['verified'] == true) {
          return {'success': true, 'message': 'Verification successful'};
        }

        return {
          'success': false,
          'message': data['message'] ?? 'Verification failed',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Verification failed. Please try again.',
        };
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
