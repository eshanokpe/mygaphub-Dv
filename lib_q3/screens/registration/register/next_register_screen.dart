import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart'; // Add this import

import 'package:GapHub/models/usermodel.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/authentication/login/widget/sign_in_row.dart';
import 'package:GapHub/screens/authentication/privacy/tnc.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/widgets/custom_input_field2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';

import 'thank_you.dart';

// ignore: must_be_immutable
class NextRegisterScreen extends StatefulWidget {
  String firstName, lastName, email, phoneNumber;
  String? dialCode;
  NextRegisterScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.dialCode,
  });

  @override
  _NextRegisterScreenState createState() => _NextRegisterScreenState();
}

class _NextRegisterScreenState extends State<NextRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _buttonEnabled = false;
  bool _isObscured = true;

  bool _isLengthValid = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  bool _acceptedTerms = false;
  String? firstName,
      lastName,
      email,
      phoneNumber,
      dialCode,
      password,
      cPassword;
  bool _loading = false;
  String _registerMessage = '';

  @override
  void initState() {
    super.initState();
    firstName = widget.firstName;
    lastName = widget.lastName;
    email = widget.email;
    phoneNumber = widget.phoneNumber;
    dialCode = widget.dialCode;

    // Add listener to password controller
    _passwordController.addListener(() {
      _validatePassword(_passwordController.text);
    });
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
          _hasSpecialCharacters &&
          _acceptedTerms;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String safePassword = _passwordController.text;
      final String safeCPassword = _passwordController.text;
      await createUser(
        widget.firstName,
        widget.lastName,
        widget.email,
        widget.phoneNumber,
        widget.dialCode!,
        safePassword,
        safeCPassword,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [HelpWidget()],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Create Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomInputField2(
                          labelText: true,
                          label: 'Login Password',
                          controller: _passwordController,
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
                          onGeneratePassword: _generatePassword,
                          onChanged: _validatePassword,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005,
                        ),
                        Row(
                          children: [
                            Text(
                              _registerMessage,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Your password must contain:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset(
                              _isLengthValid
                                  ? 'assets/icons/verify-circle.png'
                                  : 'assets/icons/x-circle.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '8-32 characters long',
                              style: TextStyle(
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
                            Image.asset(
                              _hasLowercase // FIXED: Changed from _isLengthValid to _hasLowercase
                                  ? 'assets/icons/verify-circle.png'
                                  : 'assets/icons/x-circle.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 lowercase character (a-z)',
                              style: TextStyle(
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
                            Image.asset(
                              _hasUppercase
                                  // FIXED: Changed from _isLengthValid to _hasUppercase
                                  ? 'assets/icons/verify-circle.png'
                                  : 'assets/icons/x-circle.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 uppercase character (A-Z)',
                              style: TextStyle(
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
                            Image.asset(
                              _hasDigits // FIXED: Changed from _isLengthValid to _hasDigits
                                  ? 'assets/icons/verify-circle.png'
                                  : 'assets/icons/x-circle.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 number',
                              style: TextStyle(
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
                            Image.asset(
                              _hasSpecialCharacters // FIXED: Changed from _isLengthValid to _hasSpecialCharacters
                                  ? 'assets/icons/verify-circle.png'
                                  : 'assets/icons/x-circle.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '1 special character e.g ! @ \$ %',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: _hasSpecialCharacters
                                    ? AppColors.blackColor
                                    : AppColors.grayColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {},
                          child: CheckboxListTile(
                            title: RichText(
                              text: TextSpan(
                                text: 'I accept the ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Nunito',
                                  color: Colors.black,
                                ), // Regular style
                                children: <TextSpan>[
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Tnc(tnc: true),
                                          ),
                                        );
                                      },
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ), // Bold style
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Tnc(tnc: false),
                                          ),
                                        );
                                      },
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ), // Bold style
                                  ),
                                ],
                              ),
                            ),
                            value: _acceptedTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptedTerms = value!;
                                _buttonEnabled =
                                    _isLengthValid &&
                                    _hasLowercase &&
                                    _hasUppercase && // ADDED: Missing uppercase check
                                    _hasDigits &&
                                    _hasSpecialCharacters &&
                                    _acceptedTerms;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.orangeColor,
                            dense: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          borderColor: Colors.white,
                          text: 'Sign Up',
                          fontSize: 16.sp,
                          borderRadius: 30,
                          isLoading: _loading,
                          onPressed: _buttonEnabled ? _onSubmit : null,
                          color: _buttonEnabled
                              ? AppColors.primaryColor
                              : AppColors.grayColor2,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 50),
                        buildSignInRow(
                          context: context,
                          questionText: "Already have an account? ",
                          signInText: "Sign in",
                          questionColor: AppColors.blackColor,
                          signInColor: AppColors.primaryColor,
                          onTap: () {
                            navigateWithSlideTransition(
                              context: context,
                              destinationScreen: Login(),
                              transitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Usermodel?> createUser(
    String fName,
    String lName,
    String email,
    String phoneNumber,
    String dialCode,
    String password,
    String cPassword,
  ) async {
    try {
      setState(() {
        _registerMessage = '';
        _loading = true;
      });

      var url = Uri.parse("$baseUrl/mygap/newregister");

      var timer = Timer(const Duration(seconds: 40), () {
        if (mounted) {
          setState(() {
            _registerMessage = 'Service timed out';
            _loading = false;
          });
        }
      });
      print("response:$dialCode$phoneNumber");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: {
          "email": email,
          "firstname": fName,
          "surname": lName,
          "phone": "$dialCode$phoneNumber".replaceAll(' ', ''),
          "password": password,
          "password_confirmation": cPassword,
        },
      );

      timer.cancel();

      if (!mounted) return null;

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      setState(() {
        _loading = false;
      });
      print("responseData:$responseData");
      print("response:${response.statusCode}");
      switch (response.statusCode) {
        case 201:
          navigateWithSlideTransition(
            context: context,
            destinationScreen: const ThankYou(),
            transitionDuration: const Duration(milliseconds: 200),
          );
          return Usermodel.fromJson(responseData);

        case 400:
          setState(
            () => _registerMessage = 'This email has already been taken',
          );
          break;

        case 404:
          setState(() => _registerMessage = 'Not found');
          break;

        case 422:
          setState(() => _registerMessage = 'Check your details again');
          break;

        case 500:
          setState(
            () => _registerMessage = 'Server error, please try again later',
          );
          break;

        default:
          setState(() => _registerMessage = 'Unknown error occurred');
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          // _registerMessage = 'Network error, please try again later';
        });
      }
      print('Error: $e');
    }

    return null;
  }

  Future<void> _generatePassword() async {
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';
    const String special = '!@#\$%^&*()_-+=[]{}|;:,.<>?';

    String allChars = lowercase + uppercase + digits + special;
    Random random = Random();

    String password = '';
    password += lowercase[random.nextInt(lowercase.length)];
    password += uppercase[random.nextInt(uppercase.length)];
    password += digits[random.nextInt(digits.length)];
    password += special[random.nextInt(special.length)];

    for (int i = 0; i < 8; i++) {
      password += allChars[random.nextInt(allChars.length)];
    }

    List<String> passwordList = password.split('')..shuffle();
    password = passwordList.join('');

    setState(() {
      _passwordController.text = password;
      _validatePassword(password);
    });

    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: password));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password copied to clipboard')),
      );
    }
  }
}
