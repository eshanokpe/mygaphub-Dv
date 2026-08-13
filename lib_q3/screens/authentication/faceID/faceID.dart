import 'dart:async';
import 'dart:io';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/login/forgotPin/forgot_pin.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/calculation/multi_form.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/shakeAnimation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../landing.dart';

class FaceIDScreen extends StatefulWidget {
  const FaceIDScreen({super.key});

  @override
  _FaceIDScreenState createState() => _FaceIDScreenState();
}

class _FaceIDScreenState extends State<FaceIDScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  List<String> enteredDigits = [];
  bool _isProcessing = false;
  final Dio _dio = Dio();
  String? errorMessage;
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
    Future.delayed(const Duration(milliseconds: 100), () {
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
        await _updateSignInPreferences();
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

  Widget _buildFaceIDButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showFaceIDDialog,
        borderRadius: BorderRadius.circular(35.r),
        child: Container(
          width: 70.w,
          height: 70.h,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: Image.asset(
              'assets/settings/faceid.png',
              width: 40.w,
              height: 40.h,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _authenticateWithFaceID() async {
    if (!await _isBiometricAvailable()) {
      _showErrorDialog('Face ID not available on this device.');
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
        await _updateFaceIDPreference();
        await _signInWithStoredToken();
      }
    } on PlatformException catch (e) {
      _showErrorDialog('Face ID authentication failed: ${e.message}');
    } catch (e) {
      _showErrorDialog('Authentication failed. Please use passcode instead.');
    }
  }

  Future<void> _updateFaceIDPreference() async {
    try {
      const String setpasscode = '$baseUrl/mygap/securemobile';
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token != null) {
        final response = await _dio.post(
          setpasscode,
          data: {'preference': 2, 'security': 'prghwedbnshvdvsbnnzskn'},
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          final preference = response.data['profile']?['preference']
              ?.toString();
          if (preference != null) {
            context.read<Providers>().setPref(int.parse(preference));
          }
        }
      }
    } catch (e) {
      print('Error updating Face ID preference: $e');
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
        title: const Text('Error'),
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
                firstName: firstName,
                email: email,
                surName: surName,
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
                    _buildNumberRow(['faceid', '0', 'Clear'], isLastRow: true),
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
        if (value == 'faceid') {
          return _buildFaceIDButton();
        }
        return _buildNumberButton(value);
      }).toList(),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final bool isFilled = index < enteredDigits.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isFilled ? 16.w : 12.w,
          height: isFilled ? 16.w : 12.w,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.black : const Color(0xffe4e4e4),
          ),
        );
      }),
    );
  }
}
