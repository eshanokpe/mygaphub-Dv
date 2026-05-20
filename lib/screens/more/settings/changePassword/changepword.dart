import 'package:GapHub/screens/authentication/login/forgot_password/forgotpword.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'dart:async';

import 'successpwordchange.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _previousPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  String? password;
  bool _showPasswordRules = false;
  bool _showSubmitButton = false;
  bool _obscurePreviousPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRetypePassword = true;
  bool _hasPasswordError = false;

  @override
  void initState() {
    super.initState();
    _retypePasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _retypePasswordController.removeListener(_checkPasswordMatch);
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      _showSubmitButton =
          _newPasswordController.text.isNotEmpty &&
          _retypePasswordController.text.isNotEmpty &&
          _newPasswordController.text == _retypePasswordController.text;
    });
  }

  Future<void> updatePassword() async {
    // Frontend validation: Check if new password is same as previous password
    if (_newPasswordController.text == _previousPasswordController.text) {
      setState(() {
        _hasPasswordError = true;
      });
      showErrorBottomSheet(
        context,
        'Your new password is the same as your previously used password',
      );
      return;
    }

    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var url = Uri.parse("$baseUrl/mygap/update/password");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map body = {
      "current_password": _previousPasswordController.text.toString(),
      "new_password": _newPasswordController.text.toString(),
      "new_password_confirmation": _retypePasswordController.text.toString(),
    };

    var timer = Timer(const Duration(milliseconds: 31000), () {
      EasyLoading.dismiss();
      return;
    });

    try {
      var response = await http.post(
        url,
        body: body,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );
      var res = jsonDecode(response.body);
      print('response:$res');
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        var res = jsonDecode(response.body);
        var succ = ![null, ""].contains(res["success"]) ? true : false;
        var err = res["error"] ?? false;

        if (succ) {
          // final prefs = await SharedPreferences.getInstance();
          // await prefs.setString('tokenDB', 'logout');
          Fluttertoast.showToast(msg: 'Successfully reset password');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SuccessPasswordChanged(),
            ),
          );
        } else {
          EasyLoading.dismiss();
          setState(() {
            _hasPasswordError = true;
          });
          showErrorBottomSheet(context, err);
          // Fluttertoast.showToast(
          //   toastLength: Toast.LENGTH_LONG,
          //   msg: "$err",
          //   backgroundColor: Theme.of(context).primaryColor,
          // );
        }
      } else {
        setState(() {
          _hasPasswordError = true;
        });
        print('Error:$response');
        handleErrorResponse(response);
      }
    } catch (e) {
      print('Error:$e');
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: "Network error occurred",
        backgroundColor: Theme.of(context).primaryColor,
      );
    } finally {
      timer.cancel();
    }
  }

  void showErrorBottomSheet(BuildContext context, String error) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.stockColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20.h),
              // Title
              Text(
                "Error",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),

              // Message
              Text(
                error == "Current Password  does not match"
                    ? 'Your previous password is wrong'
                    : error,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  color: AppColors.grayColor,
                ),
              ),
              SizedBox(height: 20.h),

              // Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  child: Text(
                    "Go Back",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
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

  void handleErrorResponse(http.Response response) {
    EasyLoading.dismiss();
    var res = jsonDecode(response.body)["message"];

    switch (response.statusCode) {
      case 400:
        var currP = jsonDecode(res)["current_password"] ?? false;
        var newP = jsonDecode(res)["new_password"] ?? false;
        var pConf = jsonDecode(res)["new_password_confirmation"] ?? false;

        if (pConf) {
          showToast(pConf[0]);
        } else if (newP) {
          showToast(newP[0]);
        } else {
          showToast(currP[0]);
        }
        break;
      case 401:
        Fluttertoast.showToast(
          msg: "Error: Unauthorised, please login again",
          backgroundColor: Theme.of(context).primaryColor,
        );
        break;
      case 422:
        Fluttertoast.showToast(
          msg: "Error: 422, please try again later",
          backgroundColor: Theme.of(context).primaryColor,
        );
        break;
      case 500:
        Fluttertoast.showToast(
          msg: "Error: Server Error",
          backgroundColor: Theme.of(context).primaryColor,
        );
        break;
      default:
        Fluttertoast.showToast(
          msg: "An error occurred",
          backgroundColor: Theme.of(context).primaryColor,
        );
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      toastLength: Toast.LENGTH_LONG,
      msg: message,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white, // Match status bar to app bar color
          statusBarIconBrightness: Brightness.dark, // For dark icons
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      'Change password',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your new password must be different from your previous used passwords',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16.sp,
                        color: AppColors.grayColor,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Previous Password
                    Text(
                      'Previous password',
                      style: GoogleFonts.nunitoSans(fontSize: 18),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _previousPasswordController,
                      obscureText: _obscurePreviousPassword,
                      onChanged: (value) {
                        _resetErrorState();
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter Previous Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Change border color based on error state
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _hasPasswordError
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _hasPasswordError
                                ? Colors.red
                                : Colors.black,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePreviousPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grayColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePreviousPassword =
                                  !_obscurePreviousPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    // Forgotten password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                        ), // Removes top margin if there was any
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, // Removes default padding
                            minimumSize: const Size(
                              0,
                              0,
                            ), // Allows it to shrink to fit
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // Removes extra touch padding
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Forgotpword(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgotten your password?',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // New Password
                    SizedBox(height: 8.h),
                    Text(
                      'New password',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      onChanged: (value) {
                        _resetErrorState();
                        setState(() {
                          password = value;
                          if (value.isNotEmpty) {
                            _showPasswordRules = true;
                          } else {
                            _showPasswordRules = false;
                          }
                        });
                        _checkPasswordMatch();
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Change border color based on error state
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _hasPasswordError
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _hasPasswordError
                                ? Colors.red
                                : Colors.black,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grayColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Text(
                      'Password must contain at least:',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ..._buildPasswordRules(password ?? ''),

                    // Retype Password
                    SizedBox(height: 24.h),
                    Text(
                      'Retype password',
                      style: GoogleFonts.nunitoSans(fontSize: 18),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _retypePasswordController,
                      obscureText: _obscureRetypePassword,
                      onChanged: (value) {
                        _resetErrorState();
                        _checkPasswordMatch();
                      },
                      decoration: InputDecoration(
                        hintText: 'Retype New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        // Change border color based on error state
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _hasPasswordError
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: _hasPasswordError
                                ? Colors.red
                                : Colors.black,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureRetypePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grayColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureRetypePassword = !_obscureRetypePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    // Add this directly after the TextFormField
                    if (_retypePasswordController.text.isNotEmpty &&
                        _newPasswordController.text !=
                            _retypePasswordController.text)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          'Passwords do not match',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Submit Button (shown only when passwords match)
                    if (_showSubmitButton) ...[
                      SizedBox(height: 50.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: updatePassword,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: Text(
                            "Change Password",
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPasswordRules(String password) {
    final List<PasswordRule> rules = [
      PasswordRule(
        text: '8–32 characters',
        isValid: password.length >= 8 && password.length <= 32,
      ),
      PasswordRule(
        text: '1 lowercase character (a–z)',
        isValid: RegExp(r'[a-z]').hasMatch(password),
      ),
      PasswordRule(
        text: '1 uppercase character (A–Z)',
        isValid: RegExp(r'[A-Z]').hasMatch(password),
      ),
      PasswordRule(
        text: '1 number (0–9)',
        isValid: RegExp(r'[0-9]').hasMatch(password),
      ),
      PasswordRule(
        text: '1 special character (!@#\$%^&* etc.)',
        isValid: RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(password),
      ),
    ];

    return rules
        .map(
          (rule) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                Image.asset(
                  rule.isValid
                      // FIXED: Changed from _isLengthValid to _hasUppercase
                      ? 'assets/icons/verify-circle.png'
                      : 'assets/icons/x-circle.png',
                  width: 22.w,
                  height: 22.h,
                ),
                SizedBox(width: 8.w),
                Text(
                  rule.text,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    color: AppColors.grayColor,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _resetErrorState() {
    if (_hasPasswordError) {
      setState(() {
        _hasPasswordError = false;
      });
    }
  }
}

class PasswordRule {
  final String text;
  final bool isValid;

  PasswordRule({required this.text, required this.isValid});
}
