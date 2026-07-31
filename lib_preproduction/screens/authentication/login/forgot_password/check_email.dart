import 'dart:convert';
import 'dart:io';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen>
    with WidgetsBindingObserver {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("DidChangeDependencies");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        null;
        break;
      case AppLifecycleState.resumed:
        null;
        break;
      case AppLifecycleState.paused:
        null;

        break;
      case AppLifecycleState.detached:
        null;
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  void _resendEmail() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/password/send-reset-link"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: jsonEncode({"email": widget.email.trim()}),
      );

      if (!mounted) return;

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String successMessage =
            responseBody['message'] ?? "Reset email sent successfully!";

        navigateWithSlideTransition(
          context: context,
          destinationScreen: CheckEmailScreen(email: widget.email.trim()),
          transitionDuration: const Duration(milliseconds: 200),
        );
      } else {
        String errorMessage =
            responseBody['message'] ??
            "Failed to send reset email. Please try again.";
        if (responseBody['errors'] != null && responseBody['errors'] is Map) {
          errorMessage = responseBody['errors'].values.first.join(' ');
        }
        Fluttertoast.showToast(
          gravity: ToastGravity.TOP,
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        gravity: ToastGravity.TOP,
        msg: "An unexpected error occurred. Please check your connection.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      debugPrint("Error sending reset email: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 15.sp,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [HelpWidget()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 100.h),
                Image.asset(
                  'assets/images/check_email.png',
                  width: width * 0.18,
                ),
                SizedBox(height: height * 0.03),
                Text(
                  "Check your Email",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),
                buildEmailInfoText(context),
                SizedBox(height: height * 0.05),
                buildOpenEmailAppButton(),
                SizedBox(height: 230.h),
                // Resend Email Text
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't receive email? ",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                      children: [
                        TextSpan(
                          text: "Resend Email",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryColor,
                            fontSize: 16.sp,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _resendEmail,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                // Back to Login Text
                Center(
                  child: GestureDetector(
                    onTap: () => navigateWithSlideTransition(
                      context: context,
                      destinationScreen: Login(),
                      transitionDuration: const Duration(milliseconds: 200),
                    ),
                    child: Text(
                      "Back to Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailInfoText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "We have sent instructions on how to reset your password ",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.grayColor,
          fontSize: 14.sp,
        ),
        children: [
          TextSpan(
            text: widget.email,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOpenEmailAppButton() {
    return SizedBox(
      width: 0.4.sw,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        onPressed: _openEmailApp,
        child: Text(
          "Open Email App",
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
      ),
    );
  }

  void _openEmailApp() async {
    try {
      String emailDomain = widget.email.split('@').last.toLowerCase();

      // Define app URIs for different email providers
      Map<String, Map<String, String>> emailApps = {
        'gmail.com': {
          'android':
              'intent://#Intent;package=com.google.android.gm;scheme=mailto;end',
          'ios': 'googlegmail://',
        },
        'yahoo.com': {
          'android':
              'intent://#Intent;package=com.yahoo.mobile.client.android.mail;scheme=mailto;end',
          'ios': 'ymail://',
        },
        'outlook.com': {
          'android':
              'intent://#Intent;package=com.microsoft.office.outlook;scheme=mailto;end',
          'ios': 'ms-outlook://',
        },
        'hotmail.com': {
          'android':
              'intent://#Intent;package=com.microsoft.office.outlook;scheme=mailto;end',
          'ios': 'ms-outlook://',
        },
        'icloud.com': {
          'android':
              'intent://#Intent;package=com.apple.android.mail;scheme=mailto;end',
          'ios': 'message://',
        },
        'aol.com': {
          'android':
              'intent://#Intent;package=com.aol.mobile.aolapp;scheme=mailto;end',
          'ios': 'aolmail://',
        },
        'protonmail.com': {
          'android':
              'intent://#Intent;package=ch.protonmail.android;scheme=mailto;end',
          'ios': 'protonmail://',
        },
      };

      // Default to generic mailto if provider not found
      String appUri;
      if (emailApps.containsKey(emailDomain)) {
        if (Platform.isAndroid) {
          appUri = emailApps[emailDomain]!['android']!;
        } else if (Platform.isIOS) {
          appUri = emailApps[emailDomain]!['ios']!;
        } else {
          appUri = 'mailto:'; // Fallback for other platforms
        }
      } else {
        appUri = 'mailto:'; // Generic mailto for unknown providers
      }

      if (await canLaunchUrl(Uri.parse(appUri))) {
        await launchUrl(Uri.parse(appUri));
        Fluttertoast.showToast(msg: "Opening email app...");
      } else {
        // Fallback to generic mail app
        if (await canLaunchUrl(Uri.parse('mailto:'))) {
          await launchUrl(Uri.parse('mailto:'));
        } else {
          Fluttertoast.showToast(
            msg: "No email app found",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        gravity: ToastGravity.TOP,
        msg: "Could not open email app: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      debugPrint("Error opening email app: $e");
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
