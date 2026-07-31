import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyNumberProfile extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? dialCode;

  const VerifyNumberProfile({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.dialCode,
  });

  @override
  _VerifyNumberProfileState createState() => _VerifyNumberProfileState();
}

class _VerifyNumberProfileState extends State<VerifyNumberProfile> {
  TextEditingController pinController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  String currentText = "";
  String? phoneNumber;
  String dialCode;
  bool isLoading = false;
  String errorMessage = '';

  _VerifyNumberProfileState() : dialCode = '+44'; // Default value

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phoneNumber;
    dialCode = widget.dialCode ?? '+44'; // Ensure not null
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
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 22.h),
                    // Title
                    Center(
                      child: Text(
                        "Verify your Number",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Subtitle
                    Center(
                      child: Text(
                        "Please enter the 6-digit verification code sent to $dialCode $phoneNumber",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grayColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Error message
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          errorMessage,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Clickable OTP Fields
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
                        fieldHeight: 60.h,
                        fieldWidth: 50.w,
                        activeFillColor: Colors.grey.shade200,
                        selectedFillColor: Colors.grey.shade200,
                        inactiveFillColor: Colors.grey.shade200,
                        inactiveColor: Colors.transparent,
                        selectedColor: Colors.transparent,
                        activeColor: Colors.transparent,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      onChanged: (value) {
                        setState(() {
                          currentText = value;
                          errorMessage = ''; // Clear error when typing
                        });
                      },
                      onCompleted: (value) async {
                        print("Code entered: $value");
                        await _verifyOtpAndProceed(value);
                      },
                    ),
                    const Spacer(),
                    // Countdown
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
                                    onPressed: () {
                                      _resendOtp();
                                    },
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
              // Loading overlay
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
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      bool isVerified = await verifyOtp(otp);

      if (isVerified) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('tokenDB');
        final provider = Provider.of<Providers>(context, listen: false);
        // Format the phone number with dial code
        final formattedPhoneNumber =
            '$dialCode${widget.phoneNumber.replaceAll(' ', '')}';
        provider.updatePhoneNumber(formattedPhoneNumber);
        var url = Uri.parse("$baseUrl/app/editprofile");
        var response = await http.post(
          url,
          body: {
            "phone": formattedPhoneNumber, // Use the formatted phone number
          },
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );

        if (response.statusCode == 200) {
          // Return the formatted phone number to the previous screen
          Navigator.pop(context, formattedPhoneNumber);
          Navigator.pop(context, formattedPhoneNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number updated successfully')),
          );
        } else if (response.statusCode == 429) {
          final body = jsonDecode(response.body);
          print('Error 429: ${body['message']}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${body['message']}')));
        } else {
          final body = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${body['message'] ?? 'Failed to update phone number'}',
              ),
            ),
          );
        }
      } else {
        showErrorBottomSheet(context);
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

    bool success = await sendOtp();
    if (!success) {
      setState(() {
        errorMessage = 'Failed to resend code. Please try again.';
      });
    }
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

  void showErrorBottomSheet(BuildContext context) {
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
              // Small drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.stockColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20.h),
              // Title
              Text(
                "Error",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),

              // Message
              Text(
                "The code you typed in is invalid. Please enter a correct one.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: AppColors.grayColor,
                ),
              ),
              SizedBox(height: 20.h),

              // Retry Button
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
                    Navigator.pop(context); // Close the bottom sheet
                    pinController.clear(); // Clear the OTP field
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

  Future<bool> verifyOtp(String otp) async {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("OTP verification response: $data");

        // Check for successful verification based on your response structure
        return data['status'] == true ||
            data['success'] == true ||
            data['verified'] == true ||
            (data['message'] != null &&
                data['message'].toString().toLowerCase().contains('verified'));
      } else {
        final data = jsonDecode(response.body);
        print("OTP verification failed: ${response.statusCode}, $data");
        return false;
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }
}
