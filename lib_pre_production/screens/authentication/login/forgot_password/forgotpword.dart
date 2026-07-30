import 'dart:convert';
import 'dart:io';
import 'package:GapHub/screens/helpWidget/widget/custom_input_field.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../widgets/navigateWithSlideTransition.dart';
import '../login.dart';
import 'check_email.dart';
 
class Forgotpword extends StatefulWidget {
  const Forgotpword({super.key});

  @override
  State<Forgotpword> createState() => _ForgotpwordState();
}
 
class _ForgotpwordState extends State<Forgotpword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _attemptMessage = "";
  int _remainingAttempts = 3;
  bool hasError = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadRemainingAttempts();
  }

  Future<void> _loadRemainingAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    setState(() {
      _isLoggedIn = token != null && token != 'logout' && token.isNotEmpty;
      _remainingAttempts = prefs.getInt('forgotPasswordAttempts') ?? 3;
      _attemptMessage = "$_remainingAttempts attempts left";
    });
  }

  Future<void> _saveRemainingAttempts(int attempts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('forgotPasswordAttempts', attempts);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _updateLoadingState(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenDB', 'logout');
    // Reset attempts on logout
    await _saveRemainingAttempts(3);
    _confirmLogout(context);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            'You\'ve been logged out',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Please log back in; you were logged out for security reasons.',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false,
                );
              },
              child: Text(
                'Log In',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0F77F0),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'You\'ve been logged out',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Please log back in; you were logged out for security reasons.',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false,
                );
              },
              child: Text(
                'Log in',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0F77F0),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
  if (!_formKey.currentState!.validate()) return;

  _updateLoadingState(true);
  FocusScope.of(context).unfocus();

  try {
    final checkEmailUrl = Uri.parse(
      "$baseUrl/mygap/check/email?email=${Uri.encodeComponent(_emailController.text.trim())}",
    );

    final checkEmailResponse = await http.get(
      checkEmailUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
      },
    );

    if (checkEmailResponse.statusCode != 200) {
      _updateLoadingState(false);
      Fluttertoast.showToast(
        msg: 'Error checking email. Please try again.',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final emailData = jsonDecode(checkEmailResponse.body);

    // status: false = email is registered (not available to register)
    final emailIsRegistered = emailData['status'] == false;

    if (!emailIsRegistered) {
      _updateLoadingState(false);
      setState(() {
        hasError = true;
        _attemptMessage = "This email is not registered";
      });
      return;
    }

    // Email exists — now send reset link
    final emailResetResponse = await http.post(
      Uri.parse("$baseUrl/password/send-reset-link"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
      },
      body: jsonEncode({"email": _emailController.text.trim()}),
    );

    _updateLoadingState(false);

    if (emailResetResponse.statusCode == 200) {
      await _saveRemainingAttempts(3);
      navigateWithSlideTransition(
        context: context,
        destinationScreen: CheckEmailScreen(email: _emailController.text.trim()),
        transitionDuration: const Duration(milliseconds: 200),
      );
    } else if (emailResetResponse.statusCode == 404) {
      final errorData = jsonDecode(emailResetResponse.body);
      final fullMessage = errorData['message'] as String;

      final match = RegExp(r'(\d+) attempts remaining').firstMatch(fullMessage);
      if (match != null) {
        final newAttempts = int.parse(match.group(1)!);
        setState(() {
          hasError = true;
          _remainingAttempts = newAttempts;
          _attemptMessage = "$newAttempts attempts left";
        });
        await _saveRemainingAttempts(newAttempts);
      }
      _showErrorBottomSheet(fullMessage);
    } else if (emailResetResponse.statusCode == 403 ||
               emailResetResponse.statusCode == 429) {
      _logout(context);
    } else {
      Fluttertoast.showToast(
        msg: 'Error: ${emailResetResponse.statusCode}',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (e) {
    _updateLoadingState(false);
    Fluttertoast.showToast(
      msg: 'Connection error. Please try again.',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: AppColors.blackColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [HelpWidget()],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 28.sp,
                      ),
                    ),
                    SizedBox(height: screenHeight * .01),
                    Text(
                      "Please enter the email address you used to create your account, and we'll send you instructions to reset your password.",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: AppColors.grayColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * .03),
                    CustomInputFieldHelpUI(
                      labelText: true,
                      label: 'Email ',
                      hintText: 'Enter Email address',
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      onChanged: (value) {
                        if (hasError) {
                          setState(() {
                            hasError = false;
                            _attemptMessage = _isLoggedIn ? "$_remainingAttempts attempts left" : "";
                          });
                        }
                      },
                      showValidationIcon: true,
                      hasError: hasError,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                   if (_isLoggedIn || hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _attemptMessage.isNotEmpty
                                ? _attemptMessage
                                : "$_remainingAttempts attempts left",
                            style: TextStyle(
                              color: hasError ? const Color(0xff272727) : const Color(0xff272727),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * .12),
                    CustomButton(
                      text: 'Send Email',
                      fontSize: 16.sp,
                      isLoading: _isLoading,
                      borderRadius: 30,
                      borderColor: Colors.white,
                      onPressed: _isLoading ? null : () => _sendEmail(context),
                      color: AppColors.primaryColor,
                      textColor: Colors.white,
                    ),
  
                    SizedBox(height: 300.h),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          navigateWithSlideTransition(
                            context: context,
                            destinationScreen: Login(),
                            transitionDuration: const Duration(
                              milliseconds: 200,
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Remember Password? ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 16.sp,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.primaryColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * .03),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 10.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Error',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 15.h),
              Text.rich(
                TextSpan(
                  text: 'This email address is not registered. You have ',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: "$_remainingAttempts attempts",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        color: AppColors.grayColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' remaining before you will be automatically logged out.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        color: AppColors.grayColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  "Go back",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 16.sp,
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
}
