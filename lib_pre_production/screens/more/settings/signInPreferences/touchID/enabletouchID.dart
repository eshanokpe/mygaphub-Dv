import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/provider/signin_preferences_provider.dart';
import 'package:GapHub/widgets/show_success_modal.dart';
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
          if (mounted) showTouchIDPermissionDialog();
        } on DioException catch (e) {
          final message =
              e.response?.data?['message'] ??
              e.response?.statusMessage ??
              'An error occurred while setting your passcode. Please try again.';
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

  Widget _buildStatusArea() {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return SizedBox(
      height: 40.h,
      child: Center(
        child: _isProcessing
            ? const SpinKitCircle(color: Colors.black, size: 40.0)
            : AnimatedOpacity(
                opacity: hasError ? 1 : 0,
                duration: const Duration(milliseconds: 150),
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
                    hasError ? errorMessage! : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [HelpWidget()],
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  SizedBox(height: 10.h),
                  // Title
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
                  SizedBox(height: 20.h),
                  // Dots
                  _buildPinDots(),

                  _buildStatusArea(),

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
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.white.withOpacity(0.65),
                  child: const Center(
                    child: SpinKitCircle(color: Colors.black, size: 40.0),
                  ),
                ),
              ),
            ),
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
        return _buildNumberButton(value);
      }).toList(),
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

  void showTouchIDPermissionDialog() {
    if (Platform.isIOS) {
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
      return;
    }
    enableTouchID();
  }

  Future<void> enableTouchID() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token == 'logout') {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Session expired')));
        setState(() {
          isLoading = false;
        });
        return;
      }

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

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return SuccessModal(
              message: "Touch ID enabled successfully",
              onClose: () {
                Navigator.of(context).pop();
                Navigator.of(this.context).pop();
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enable Touch ID')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
