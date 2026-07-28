import 'dart:async';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/screens/registration/calculation/multi_form.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/shakeAnimation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/landing.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/login/forgotPin/forgot_pin.dart';

class Passcode22 extends StatefulWidget {
  const Passcode22({super.key});

  @override
  _PasscodeState createState() => _PasscodeState();
}

class _PasscodeState extends State<Passcode22> {
  List<String> enteredDigits = [];
  bool _isProcessing = false;
  final dio = Dio();
  final TextEditingController _passcodeController = TextEditingController();
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  String? errorMessage;
  bool _triggerShake = false;

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _triggerShakeAnimation() {
    setState(() {
      _triggerShake = true;
    });

    // Reset the shake animation after it completes
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _triggerShake = false;
        });
      }
    });
  }

  void _onKeyTap(String value) async {
    if (enteredDigits.length < 6 && !_isProcessing) {
      setState(() {
        enteredDigits.add(value);
        errorMessage = null; // Clear error when user starts typing again
      });

      if (enteredDigits.length == 6) {
        setState(() {
          _isProcessing = true;
        });

        try {
          final passcode = enteredDigits.join();
          await _setPasscodeAndPreference(passcode);

          if (mounted) {
            // Navigate back after a brief delay for better UX
            await Future.delayed(const Duration(milliseconds: 800));

            if (mounted) {
              Navigator.of(context).pop(true); // Return success result
            }
          }
        } on DioException catch (e) {
          final message =
              e.response?.data?['message'] ??
              'An error occurred while setting your passcode. Please try again.';

          if (mounted) {
            setState(() {
              errorMessage = message;
            });
            _triggerShakeAnimation(); // Trigger shake on error
            // Clear error after 3 seconds
            Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  errorMessage = null;
                });
              }
            });
          }
        } catch (e) {
          print('Error setting passcode: $e');
          if (mounted) {
            setState(() {
              errorMessage = 'Wrong passcode';
            });
            _triggerShakeAnimation(); // Trigger shake on error
            Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  errorMessage = null;
                });
              }
            });
          }
        } finally {
          if (mounted) {
            setState(() {
              _isProcessing = false;
              enteredDigits.clear();
            });
          }
        }
      }
    }
  }

  void _onBackspace() {
    if (enteredDigits.isNotEmpty) {
      setState(() {
        enteredDigits.removeLast();
        errorMessage = null; // Clear error when user corrects input
      });
    }
  }

  Future<void> _setPasscodeAndPreference(String pin) async {
    const String urlSettings = '$baseUrl/app/settings';
    const String urlPasscode = '$baseUrl/mygap/passcode/confirm';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('tokenDB');

    if (token == null) {
      throw Exception('User token not found. Please login again.');
    }

    Map<String, dynamic> dataPasscode = {'passcode': pin};

    // POST passcode first
    final responsePasscode = await dio.post(
      urlPasscode,
      data: dataPasscode,
      options: Options(
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      ),
    );

    if (responsePasscode.statusCode != 200 ||
        responsePasscode.data['success'] != true) {
      String errorMessage = "Wrong passcode.";
      if (responsePasscode.data != null &&
          responsePasscode.data['message'] != null) {
        errorMessage = responsePasscode.data['message'];
      }
      throw Exception(errorMessage);
    }

    print('Passcode set response: ${responsePasscode.data}');

    // Then GET preferences
    final responsePreference = await dio.get(
      urlSettings,
      options: Options(
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      ),
    );

    if (responsePreference.statusCode != 200 ||
        responsePreference.data['success'] != true) {
      throw Exception('Passcode set, but failed to update preference.');
    }

    final preferences = responsePreference.data['data']?['preferences'];
    if (preferences == null) {
      throw Exception('Failed to retrieve preferences data.');
    }

    final signinPref = preferences['signin_preference'];
    if (signinPref == null) {
      throw Exception('Preference data incomplete.');
    }

    print('Preference updated successfully: $signinPref');
    context.read<Providers>().setPref(int.parse(signinPref.toString()));
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
                  fontWeight: FontWeight.w600,
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
        child: CustomAnimatedNumPad(
          onPressed: onTap,
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
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
    //  details = context.watch<Providers>().loginDetails;
    String imgurl = context.watch<Providers>().details[7];
    String email = context.watch<Providers>().details[6];
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        actions: [
          GestureDetector(
            onTap: () {
              navigateWithSlideTransition(
                context: context,
                destinationScreen: const ForgotPINScreen(),
                transitionDuration: const Duration(milliseconds: 200),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Forgot PIN',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Landing(
                  touch: false,
                  passcode: false,
                  reset: false,
                  fromID: true,
                ),
              ),
            ),
            child: Image.asset(
              'assets/settings/lock.png',
              width: 24.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section - Header (Fixed but flexible)
                  Flexible(
                    flex: 3, // 30% of available space
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Header(
                            width: constraints.maxWidth * 0.9,
                            height: constraints.maxHeight * 0.4,
                            imgurl: imgurl,
                            details: Loginusermodel(),
                            firstName: '',
                            surName: '',
                            email: email,
                          ),
                          SizedBox(height: 10.h),
                          Center(
                            child: Text(
                              'Please enter your passcode',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14.sp,
                                color: AppColors.grayColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                  // Middle Section - Passcode dots and status
                  Flexible(
                    flex: 1, // 20% of available space
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Passcode Dots
                          Center(
                            child: ShakeAnimation(
                              animate: _triggerShake,
                              child: _buildPinDots(),
                            ),
                          ),

                          // Loading Indicator
                          if (_isProcessing) ...[
                            const Center(
                              child: SpinKitCircle(
                                color: Colors.black,
                                size: 50.0,
                              ),
                            ),
                          ],

                          // Error Message
                          if (errorMessage != null) ...[
                            SizedBox(height: 10.h),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ] else if (!_isProcessing) ...[
                            // Reserve space for potential error message
                            SizedBox(height: 20.h),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section - Number Pad
                  Flexible(
                    flex: 5, // 40% of available space
                    child: Container(
                      child: GridView.count(
                        crossAxisCount: 3,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.5,
                        children: [
                          ...List.generate(9, (index) {
                            final number = (index + 1).toString();
                            return _buildKey(
                              number,
                              onTap: () => _onKeyTap(number),
                            );
                          }),
                          _buildKeyForgot('', onTap: null, color: Colors.black),
                          _buildKey('0', onTap: () => _onKeyTap('0')),
                          _buildKeyForgot(
                            'Clear',
                            onTap: () {
                              _onBackspace();
                            },
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 50.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showTimeoutError() {
    Navigator.pop(context);
    dialogBox.information(context, 'Status', 'Service timed out');
  }

  signIn() async {
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await authProvider.signInDetails(context);

      if (context.mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        switch (result['route']) {
          case 'dashboard':
            EasyLoading.dismiss();
            _navigatorKey.currentState!.pop();

            break;
          case 'prequestions':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Prequestions()),
            );
            break;
          case 'precalc':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Precalc()),
            );
            break;
          case 'multiStepForm':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MultiStepForm(
                  initialPage: result['initialPage'],
                  currentPageIndex: result['currentPageIndex'],
                ),
              ),
            );
            break;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Sign-in failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final bool isFilled = index < enteredDigits.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          width: isFilled ? 16.w : 12.w, // Filled dots are 16, inactive are 12
          height: isFilled ? 16.w : 12.w, // Filled dots are 16, inactive are 12
          decoration: BoxDecoration(
            color: isFilled ? Colors.black : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
