import 'dart:async';
import 'dart:convert';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
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

import '../../../../../provider/signin_preferences_provider.dart';

class EnableTouchIdScreen extends StatefulWidget {
  const EnableTouchIdScreen({super.key});

  @override
  _EnableTouchIdScreenState createState() => _EnableTouchIdScreenState();
}

class _EnableTouchIdScreenState extends State<EnableTouchIdScreen> {
  List<String> enteredDigits = [];
  bool _isProcessing = false;
  final dio = Dio();
  final TextEditingController _passcodeController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final signInPrefsProvider = Provider.of<SignInPreferencesProvider>(
      context,
      listen: false,
    );
    signInPrefsProvider.fetchSignInPreferences();
    signInPrefsProvider.fetchPasscodeStatus();
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final bool isFilled = index < enteredDigits.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
          margin: EdgeInsets.symmetric(horizontal: 5.5.w),
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

  void _onKeyTap(String value) async {
    if (enteredDigits.length < 6 && !_isProcessing) {
      setState(() {
        enteredDigits.add(value);
      });

      // Only process when 6 digits are entered
      if (enteredDigits.length == 6) {
        setState(() {
          _isProcessing = true;
        });

        try {
          final passcode = enteredDigits.join();
          await _setPasscodeAndPreference(passcode);
          if (mounted) showFaceIDPermissionDialog();
        } on DioException catch (e) {
          final message =
              e.response?.data?['message'] ??
              e.response?.statusMessage ??
              'An error occurred while setting your passcode. Please try again.';
          // if (mounted) _showErrorBottomSheet(message);
        } catch (e) {
          print('Error setting passcode: $e');
          if (mounted) {
            setState(() {
              errorMessage = 'Wrong passcode';
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
        actions: const [HelpWidget()],
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Enter your ',
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
            ),
            SizedBox(height: 120.h),

            // Dots with smooth fill animation
            // Passcode Dots - Using the new _buildPinDots method
            _buildPinDots(),
            SizedBox(height: 20.h),
            if (_isProcessing)
              const Center(
                child: SpinKitCircle(color: Colors.black, size: 60.0),
              ),
            SizedBox(height: 10.h),
            if (errorMessage != null && errorMessage!.isNotEmpty)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 80.h),

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
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showForgotPasscodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Passcode?'),
          content: const Text('Please contact support to reset your passcode.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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

  // Show the custom pre-permission dialog
  void showFaceIDPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => Container(
        width: 420.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40.r),
          child: CupertinoAlertDialog(
            title: Text(
              'Do you want to allow "GAPhub" to use Touch ID?',
              style: GoogleFonts.nunitoSans(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                "In order to allow for quick and secure login, we need permission to use Touch ID.",
                style: GoogleFonts.nunitoSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                isDefaultAction: false,
                isDestructiveAction: true,
                child: Text(
                  "Don't Allow",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff0f77f0),
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  enableTouchID();
                },
                isDefaultAction: true,
                child: Text(
                  "Allow",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff0f77f0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> enableTouchID() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    if (token != null && token != 'logout') {
      try {
        var url = Uri.parse('$baseUrl/app/settings/preferences');

        var response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({'signin_preference': '1'}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Touch ID enabled successfully')),
          );
          // Return true to indicate successful enabling
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to enable Touch ID')),
          );
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
