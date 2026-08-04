import 'dart:async';
import 'dart:io';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/landing.dart';
import 'package:GapHub/screens/authentication/login/forgotPin/forgot_pin.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/calculation/multi_form.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/shakeAnimation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Passcode extends StatefulWidget {
  const Passcode({super.key});

  @override
  _PasscodeState createState() => _PasscodeState();
}

class _PasscodeState extends State<Passcode> {
  List<String> enteredDigits = [];
  bool _isProcessing = false;
  final Dio _dio = Dio();
  String? errorMessage;
  Timer? _errorMessageTimer;
  bool _triggerShake = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _errorMessageTimer?.cancel();
    super.dispose();
  }

  void _onKeyTap(String value) async {
    if (enteredDigits.length < 6 && !_isProcessing) {
      setState(() {
        enteredDigits.add(value);
        errorMessage = null;
      });

      if (enteredDigits.length == 6) {
        await _verifyPasscode(enteredDigits.join());
      }
    }
  }

  Future<void> _verifyPasscode(String passcode) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Session expired. Please login again.');
      }

      const String urlPasscode = '$baseUrl/mygap/passcode/confirm';
      final response = await _dio.post(
        urlPasscode,
        data: {'passcode': passcode},
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        await _updateSignInPreferences();
        await _signInWithStoredToken();
      } else {
        throw Exception(response.data['message'] ?? 'Invalid passcode');
      }
    } catch (e) {
      _handlePasscodeError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          enteredDigits.clear();
        });
      }
    }
  }

  void _handlePasscodeError(dynamic error) {
    String message = 'Wrong passcode';

    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        message = 'Session expired. Please login again.';
      } else if (error.response?.statusCode == 400) {
        message = error.response?.data['message'] ?? 'Invalid passcode';
      }
    } else if (error is SocketException) {
      message = 'Network error. Please check your connection.';
    } else if (error is TimeoutException) {
      message = 'Request timeout. Please try again.';
    }

    setState(() {
      errorMessage = message;
      _triggerShake = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _triggerShake = false;
        });
      }
    });

    _errorMessageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  Future<void> _updateSignInPreferences() async {
    try {
      const String urlSettings = '$baseUrl/app/settings';
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token != null) {
        final response = await _dio.get(
          urlSettings,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          final preferences = response.data['data']?['preferences'];
          if (preferences != null) {
            final signinPref = preferences['signin_preference']?.toString();
            if (signinPref != null) {
              context.read<Providers>().setPref(int.parse(signinPref));
            }
          }
        }
      }
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }

  Future<void> _signInWithStoredToken22() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await authProvider.signInDetails(context);

      if (mounted) {
        if (result['success'] == true) {
          _navigateBasedOnResult(result);
        } else {
          final errorMessage = result['error'] ?? 'Unknown error occurred';
          print('result Error: $errorMessage');
          _handleSignInError(result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        _handleSignInError(e.toString());
      }
    }
  }

  Future<void> _signInWithStoredToken() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token == null) {
        _handleSignInError('Session expired. Please login again.');
        return;
      }

      final result = await authProvider.loadEssentialData(token, context);
      print("_signInWithStoredToken:$result");

      if (!mounted) return;

      if (result['success'] == true) {
        _navigateBasedOnResult(result);
      } else if (result['workflowIncomplete'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
          (route) => false,
        );
      } else {
        _handleSignInError(result['error']);
      }
    } catch (e) {
      if (mounted) _handleSignInError(e.toString());
    }
  }

  void _navigateBasedOnResult(Map<String, dynamic> result) {
    if (!mounted) return;

    switch (result['route']) {
      case 'dashboard':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
          (route) => false,
        );
        break;
      case 'prequestions':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Prequestions()),
          (route) => false,
        );
        break;
      case 'precalc':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
          (route) => false,
        );
        break;
      case 'multiStepForm':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(
              initialPage: result['initialPage'] ?? 0,
              currentPageIndex: result['currentPageIndex'] ?? 0,
            ),
          ),
          (route) => false,
        );
        break;
      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
          (route) => false,
        );
    }
  }

  void _handleSignInError(String? error) {
    setState(() {
      errorMessage = error ?? 'Authentication failed. Please try again.';
    });

    _errorMessageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  void _onBackspace() {
    if (enteredDigits.isNotEmpty && !_isProcessing) {
      setState(() {
        enteredDigits.removeLast();
        errorMessage = null;
      });
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

  @override
  Widget build(BuildContext context) {
    String imgurl = context.watch<Providers>().details[7];
    String email = context.watch<Providers>().details[2];
    String firstName = context.watch<Providers>().details[0];
    String surName = context.watch<Providers>().details[1];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/settings/lock.png',
            width: 24.w,
            height: 24.h,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Landing(
                  touch: false,
                  passcode: false,
                  reset: false,
                  fromID: true,
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => navigateWithSlideTransition(
              context: context,
              destinationScreen: const ForgotPINScreen(),
              transitionDuration: const Duration(milliseconds: 200),
            ),
            child: Text(
              'Forgot PIN',
              style: GoogleFonts.nunitoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Header(
                    width: MediaQuery.of(context).size.width * 1.0,
                    height: MediaQuery.of(context).size.height * 0.25,
                    imgurl: imgurl,
                    firstName: '',
                    surName: '',
                    email: email,
                  ),
                  // Top Section - Header
                  SizedBox(height: 5.h),
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
                ],
              ),
              SizedBox(height: 20.h),
              // Dots
              Column(
                children: [
                  ShakeAnimation(
                    animate: _triggerShake,
                    child: _buildPinDots(),
                  ),

                  // Single reserved slot for BOTH spinner and error
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: _isProcessing
                        ? const Center(
                            child: SpinKitCircle(
                              color: Colors.black,
                              size: 40.0,
                            ),
                          )
                        : errorMessage != null
                        ? Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),

              // Number Pad
              Column(
                children: [
                  _buildNumberRow(['1', '2', '3']),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildNumberRow(['4', '5', '6']),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildNumberRow(['7', '8', '9']),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildNumberRow(['', '0', 'Clear'], isLastRow: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> values, {bool isLastRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((value) {
        if (value.isEmpty) {
          return SizedBox(width: 80.w, height: 70.h);
        }
        if (value == 'Clear') {
          return _buildClearButton();
        }
        return _buildNumberButton(value);
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    final size = MediaQuery.of(context).size;
    final buttonSize = size.width * 0.18;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyTap(number),
        borderRadius: BorderRadius.circular(35.r),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.nunitoSans(
                fontSize: 24.sp,
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
        onTap: _onBackspace,
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
