import 'dart:convert';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email, token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  bool _buttonEnabled = false;
  bool _isObscured = true;
  bool _isObscured2 = true;

  bool _isLengthValid = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  String? otp, email;
  final bool _loading = false;
  final String _registerMessage = '';

  @override
  void initState() {
    super.initState();
    email = widget.email;
    otp = widget.token;
  }

  void _validatePassword(String value) {
    setState(() {
      _isLengthValid = value.length >= 8 && value.length <= 32;
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasDigits = value.contains(RegExp(r'[0-9]'));
      _hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      _buttonEnabled =
          _isLengthValid &&
          _hasLowercase &&
          _hasUppercase &&
          _hasDigits &&
          _hasSpecialCharacters;
    });
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse("$baseUrl/password/reset-with-link"),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
          },
          body: jsonEncode({
            "email": widget.email.trim(),
            "token": widget.token.trim(),
            "password": _passwordController.text.trim(),
            "password_confirmation": _retypePasswordController.text.trim(),
          }),
        );

        if (!mounted) return;

        final responseBody = jsonDecode(response.body);
        print('Response statusCode: ${response.statusCode}');
        print('Response Body: $responseBody');

        if (response.statusCode == 200) {
          String successMessage =
              responseBody['message'] ?? "OTP verified successfully!";
          print(responseBody['message']);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SuccessScreen()),
            (route) => false,
          );
        } else {
          String errorMessage =
              responseBody['message'] ??
              "Failed to verify OTP. Please try again.";

          Fluttertoast.showToast(
            msg: errorMessage,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg: "An unexpected error occurred. Please check your connection.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        debugPrint("Error verifying OTP: $e");
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: const [HelpWidget()],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Text('${widget.token}'),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create new password',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 28.sp,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your new password must be different from your previous used passwords',
                    style: GoogleFonts.nunitoSans(
                      color: AppColors.grayColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomInputField(
                          labelText: true,
                          label: 'New Password',
                          hintText: 'Enter New Password',
                          controller: _passwordController,
                          isPassword: true,
                          type: 'password',
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLengthValid) {
                              return 'Password must be 8-32 characters long';
                            }
                            if (!_hasLowercase) {
                              return 'Password must contain at least one lowercase letter';
                            }
                            if (!_hasUppercase) {
                              return 'Password must contain at least one uppercase letter';
                            }
                            if (!_hasDigits) {
                              return 'Password must contain at least one numbrt';
                            }
                            if (!_hasSpecialCharacters) {
                              return 'Password must contain at least one special character';
                            }
                            return null;
                          },
                          obscureText: _isObscured,
                          onTapVisibilityToggle: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                          onChanged: _validatePassword,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005,
                        ),
                        Row(
                          children: [
                            Text(
                              _registerMessage,
                              style: GoogleFonts.nunitoSans(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 9.h),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Your password must contain:',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Row(
                          children: [
                            Icon(
                              _isLengthValid
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: _isLengthValid
                                  ? AppColors.greenColor
                                  : AppColors.primaryColor,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              '8-32 characters long',
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _isLengthValid
                                    ? AppColors.blackColor
                                    : AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              _hasLowercase
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: _hasLowercase
                                  ? AppColors.greenColor
                                  : AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 lowercase character (a-z)',
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _hasLowercase
                                    ? AppColors.blackColor
                                    : AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              _hasUppercase
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: _hasUppercase
                                  ? AppColors.greenColor
                                  : AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 uppercase character (A-Z)',
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _hasUppercase
                                    ? AppColors.blackColor
                                    : AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              _hasDigits
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: _hasDigits
                                  ? AppColors.greenColor
                                  : AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 number',
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _hasDigits
                                    ? AppColors.blackColor
                                    : AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              _hasSpecialCharacters
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: _hasSpecialCharacters
                                  ? AppColors.greenColor
                                  : AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 special character e.g ! @ \$ %',
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _hasSpecialCharacters
                                    ? AppColors.blackColor
                                    : AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 22.h),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            CustomInputField(
                              labelText: true,
                              label: 'Retype password',
                              hintText: 'Retype New Password',
                              controller: _retypePasswordController,
                              isPassword: true,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },

                              obscureText: _isObscured2,
                              suffixIcon:
                                  _retypePasswordController.text.isNotEmpty &&
                                      _retypePasswordController.text ==
                                          _passwordController.text
                                  ? Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.greenColor,
                                      size: 24.sp,
                                    )
                                  : Icon(
                                      _isObscured2
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grayColor,
                                    ),
                              onTapVisibilityToggle:
                                  _retypePasswordController.text.isNotEmpty &&
                                      _retypePasswordController.text ==
                                          _passwordController.text
                                  ? null
                                  : () {
                                      setState(() {
                                        _isObscured2 = !_isObscured2;
                                      });
                                    },
                              onChanged: (value) {
                                setState(
                                  () {},
                                ); // To trigger UI update for check icon
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Both password must match ',
                            style: GoogleFonts.nunitoSans(
                              color: AppColors.grayColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        SizedBox(
                          width: double.infinity,
                          height: 60.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : _buttonEnabled
                                ? _onSubmit
                                : null,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Reset Password",
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        GestureDetector(
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
                              style: GoogleFonts.nunitoSans(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign in",
                                  style: GoogleFonts.nunitoSans(
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final height = isPortrait ? size.height : size.width;
    final width = isPortrait ? size.width : size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(20),
                //   border: Border.all(color: AppColors.cardColor2, width: 2.5),
                // ),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.02),
                      Container(
                        // decoration: BoxDecoration(
                        //   color: AppColors.cardColor,
                        //   borderRadius: BorderRadius.circular(16),
                        // ),
                        padding: EdgeInsets.symmetric(horizontal: 80.w),
                        child: Image.asset(
                          "assets/settings/verified.gif",
                          width: 80.w,
                        ),
                      ),

                      SizedBox(height: 20.h),
                      _buildHelpDescription(width),
                      SizedBox(height: 20.h),
                      _buildSendMessageButton(context),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetHandle(double width, context) {
    return Center(
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Divider(
          color: const Color(0xffcdcdcd),
          height: 20,
          thickness: 5,
          indent: width * 0.38,
          endIndent: width * 0.38,
        ),
      ),
    );
  }

  Widget _buildHelpDescription(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      child: Column(
        children: [
          Text(
            'Password Changed',
            textAlign: TextAlign.left,
            style: GoogleFonts.nunitoSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Your password has been changed successfully.',
            textAlign: TextAlign.left,
            style: GoogleFonts.nunitoSans(
              color: AppColors.grayColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendMessageButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () => navigateWithSlideTransition(
          context: context,
          destinationScreen: Login(),
          transitionDuration: const Duration(milliseconds: 200),
        ),
        child: Text(
          "Back to Login",
          style: GoogleFonts.nunitoSans(fontSize: 16.sp, color: Colors.white),
        ),
      ),
    );
  }
}
