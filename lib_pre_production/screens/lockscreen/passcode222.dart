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
        errorMessage = null;
      });

      if (enteredDigits.length == 6) {
        setState(() {
          _isProcessing = true;
        });

        try {
          final passcode = enteredDigits.join();
          await _setPasscodeAndPreference(passcode);

          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 800));

            if (mounted) {
              Navigator.of(context).pop(true);
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
            _triggerShakeAnimation();
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
            _triggerShakeAnimation();
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
        errorMessage = null;
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

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyTap(number),
        borderRadius: BorderRadius.circular(35.r),
        child: Container(
          width: 70.w,
          height: 70.h,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
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

  @override
  Widget build(BuildContext context) {
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
        elevation: 0,
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
              // Header
              Header(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.25,
                imgurl: imgurl,
                details: Loginusermodel(),
                firstName: '',
                surName: '',
                email: email,
              ),

              Text(
                'Please enter your passcode',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: AppColors.grayColor,
                ),
              ),

              // Dots
              ShakeAnimation(animate: _triggerShake, child: _buildPinDots()),

              if (_isProcessing)
                const SpinKitCircle(color: Colors.black, size: 40.0),

              if (errorMessage != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),

              // Number Pad
              SizedBox(
                width: double.infinity,
                child: Column(
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
          return SizedBox(width: 70.w, height: 70.h);
        }
        if (value == 'Clear') {
          return _buildClearButton();
        }
        return _buildNumberButton(value);
      }).toList(),
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
}
