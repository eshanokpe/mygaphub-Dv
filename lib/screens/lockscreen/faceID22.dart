import 'dart:async';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/landing.dart';
import 'package:GapHub/screens/authentication/login/forgotPin/forgot_pin.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/shakeAnimation.dart' show ShakeAnimation;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'landing22.dart';

class FaceID22 extends StatefulWidget {
  const FaceID22({super.key});

  @override
  _FaceID22State createState() => _FaceID22State();
}

class _FaceID22State extends State<FaceID22> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final Dio _dio = Dio();
  List<String> enteredDigits = [];
  bool _isProcessing = false;
  String? _errorMessage;
  Timer? _errorMessageTimer;
  bool _triggerShake = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithFaceID();
    });
  }

  @override
  void dispose() {
    _errorMessageTimer?.cancel();
    super.dispose();
  }

  void _onKeyTap(String value) {
    if (enteredDigits.length < 6 && !_isProcessing) {
      setState(() {
        enteredDigits.add(value);
        _errorMessage = null;
      });

      if (enteredDigits.length == 6) {
        _verifyPasscode(enteredDigits.join());
      }
    }
  }

  Future<void> _verifyPasscode(String passcode) async {
    setState(() => _isProcessing = true);

    try {
      await _authenticateWithPasscode(passcode);
      await _updateSignInPreferences();

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      _handlePasscodeError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          enteredDigits.clear();
        });
      }
    }
  }

  Future<void> _authenticateWithPasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('tokenDB');

    if (token == null) {
      throw Exception('Authentication session expired. Please login again.');
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

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Invalid passcode');
    }
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
          final signinPref = preferences?['signin_preference']?.toString();

          if (signinPref != null) {
            context.read<Providers>().setPref(int.parse(signinPref));
          }
        }
      }
    } catch (e) {
      print('Preference update error: $e');
    }
  }

  void _handlePasscodeError(dynamic error) {
    String message = 'Wrong passcode';

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        message = 'Session expired. Please login again.';
      } else if (statusCode == 400) {
        message = error.response?.data['message'] ?? message;
      }
    }

    setState(() {
      _errorMessage = message;
      _triggerShake = true; // Trigger the animation
    });
    // Reset animation trigger after short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _triggerShake = false;
        });
      }
    });

    _errorMessageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _onBackspace() {
    if (enteredDigits.isNotEmpty && !_isProcessing) {
      setState(() {
        enteredDigits.removeLast();
        _errorMessage = null;
      });
    }
  }

  Widget _buildKey(String label, {VoidCallback? onTap, Widget? icon}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: CustomAnimatedNumPad(
          onPressed: onTap,
          child: Container(
            width: 70.w,
            height: 70.h,

            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child:
                  icon ??
                  Text(
                    label,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaceIDKey() {
    return _buildKey(
      '',
      onTap: _showFaceIDDialog,
      icon: Image.asset(
        'assets/settings/faceid.png',
        width: 40.w,
        height: 40.h,
      ),
    );
  }

  Widget _buildClearKey() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onBackspace,
          borderRadius: BorderRadius.circular(45.r),
          child: Container(
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
      ),
    );
  }

  void _showFaceIDDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Sign in",
            style: GoogleFonts.roboto(
              fontSize: 20.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _authenticateWithFaceID();
                },
                child: Image.asset(
                  'assets/settings/faceid.png',
                  width: 60,
                  height: 60,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Use Face ID to authenticate",
                style: GoogleFonts.roboto(
                  fontSize: 15.sp,
                  color: const Color(0xff757575),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Use Passcode",
                style: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  color: const Color(0xff1A73E8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _authenticateWithFaceID() async {
    if (!await _isBiometricAvailable()) {
      _showErrorDialog('Face ID is not available on this device.');
      return;
    }

    try {
      final isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Verify your identity to continue to GAPhub',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        await _handleSuccessfulFaceIDAuth();
      }
    } on PlatformException catch (e) {
      _showErrorDialog('Face ID authentication failed: ${e.message}');
    } catch (e) {
      _showErrorDialog('Authentication failed. Please use passcode.');
    }
  }

  Future<void> _handleSuccessfulFaceIDAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await _dio.post(
        '$baseUrl/mygap/securemobile',
        data: {'preference': 2, 'security': 'prghwedbnshvdvsbnnzskn'},
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        ),
      );

      final preference = int.parse(
        response.data['profile']['preference'].toString(),
      );
      context.read<Providers>().setPref(preference);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      _showErrorDialog('Failed to update authentication preferences');
    }
  }

  Future<bool> _isBiometricAvailable() async {
    try {
      return await _localAuthentication.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imgurl = context.watch<Providers>().details[7];
    final String email = context.watch<Providers>().details[2];
    final String firstName = context.watch<Providers>().details[0];
    final String surName = context.watch<Providers>().details[1];

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
          onPressed: () => Navigator.push(
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section - Header (Fixed but flexible)
                  Flexible(
                    flex: 4, // 30% of available space
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Header(
                          //   width: constraints.maxWidth * 0.9,
                          //   height: constraints.maxHeight * 0.4,
                          //   imgurl: imgurl,
                          //   firstName: firstName,
                          //   email: email,
                          //   surName: surName,
                          // ),
                          SizedBox(height: 10.h),
                          Center(
                            child: Text(
                              'Please enter your passcode',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
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
                    flex: 2, // 20% of available space
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
                          if (_errorMessage != null) ...[
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
                                  _errorMessage!,
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
                  // Number Pad
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
                          _buildFaceIDKey(),
                          _buildKey('0', onTap: () => _onKeyTap('0')),
                          _buildClearKey(),
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

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(6, (index) {
        // Changed from _pinLength to fixed 6
        final bool isFilled =
            index <
            enteredDigits.length; // Changed from _currentPin to enteredDigits

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isFilled ? 16.w : 12.w, // Filled dots are 16, inactive are 12
          height: isFilled ? 16.w : 12.w, // Filled dots are 16, inactive are 12
          margin: EdgeInsets.symmetric(horizontal: 6.sp),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Colors.black
                : isFilled
                ? Colors
                      .grey
                      .shade400 // Active but not filled yet
                : const Color(0xffe4e4e4), // Inactive grey dot
          ),
        );
      }),
    );
  }
}
