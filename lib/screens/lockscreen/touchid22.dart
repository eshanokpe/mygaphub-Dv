import 'dart:async';
import 'package:GapHub/screens/authentication/landing.dart';
import 'package:GapHub/screens/authentication/login/forgotPin/forgot_pin.dart';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/shakeAnimation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Touchid22 extends StatefulWidget {
  const Touchid22({super.key, this.settings = false});

  final bool settings;
  @override
  _Touchid22State createState() => _Touchid22State();
}

class _Touchid22State extends State<Touchid22> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
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
    _authenticateUser();
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _onKeyTap(String value) async {
    if (enteredDigits.length < 6 && !_isProcessing) {
      setState(() {
        enteredDigits.add(value);
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
              _triggerShake = true;
            });
            // Reset shake after animation completes
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) {
                setState(() {
                  _triggerShake = false;
                });
              }
            });
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
          if (mounted) {
            setState(() {
              errorMessage = 'Wrong passcode';
              _triggerShake = true;
            });
            // Reset shake after animation completes
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) {
                setState(() {
                  _triggerShake = false;
                });
              }
            });
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
      String errorMessage = "Wrong passcode";
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

  void _onBackspace() {
    if (enteredDigits.isNotEmpty) {
      setState(() {
        enteredDigits.removeLast();
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

  Widget _buildKeyFaceId(String label, {VoidCallback? onTap, Color? color}) {
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
            child: Center(child: Image.asset(label, width: 40.sp)),
          ),
        ),
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
              height: 24.h,
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
                    flex: 4, // 30% of available space
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Header(
                          //   width: constraints.maxWidth * 0.9,
                          //   height: constraints.maxHeight * 0.4,
                          //   imgurl: imgurl,
                          //   details: Loginusermodel(),
                          //   firstName: '',
                          //   surName: '',
                          //   email: email,
                          // ),
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
                          _buildKeyFaceId(
                            'assets/settings/touchID.png',
                            onTap: () {
                              _showForgotTouchid22Dialog();
                            },
                            color: AppColors.primaryColor,
                          ),
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

  void _showForgotTouchid22Dialog() {
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
                onTap: () => _authenticateUser(),
                child: Image.asset(
                  'assets/settings/touchID.png',
                  width: 60,
                  height: 60,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Touch the fingerprint sensor",
                style: GoogleFonts.roboto(
                  fontSize: 15.sp,
                  color: const Color(0xff757575),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // 👈 aligns to the left
              children: [
                TextButton(
                  child: Text(
                    "Use Passcode",
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      color: const Color(0xff1A73E8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showTimeoutError() {
    Navigator.pop(context);
    dialogBox.information(context, 'Status', 'Service timed out');
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = false;

    if (!await _isBiometricAvailable()) {
      if (mounted) {
        dialogBox.information(
          context,
          'Status',
          'This device does not have a biometric system',
        );
      }
      return;
    }

    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Verify your ID to continue to GAPhub',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (_) {
      if (mounted) {
        dialogBox.information(
          context,
          'Error',
          "An error occurred, please sign in with your password instead",
        );
      }
      return;
    }

    if (!mounted) return;

    FocusScope.of(context).requestFocus(FocusNode());

    if (isAuthenticated) {
      await _handleSuccessfulBiometricAuth();
    }
  }

  Future<void> _handleSuccessfulBiometricAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await dio.post(
        '$baseUrl/mygap/securemobile',
        data: {'preference': 2, 'security': 'prghwedbnshvdvsbnnzskn'},
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        ),
      );

      // Update preference in provider
      final preference = int.parse(
        response.data['profile']['preference'].toString(),
      );
      context.read<Providers>().setPref(preference);

      // ✅ Simple navigation back - no signIn() call
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        dialogBox.information(
          context,
          'Error',
          'Failed to update authentication preference',
        );
      }
    }
  }

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;

    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      EasyLoading.dismiss();
      dialogBox.information(context, 'Error', e.toString());
    }

    if (!mounted) return isAvailable;
    return isAvailable;
  }
}
