import 'dart:async';
import 'dart:io';
import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/screens/authentication/login/forgot_password/forgotpword.dart';
import 'package:GapHub/screens/registration/register/register.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/widgets/custom_input_field2.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'widget/sign_in_row.dart';
 
class Login extends StatefulWidget {
  final fromAppLink;

  const Login({super.key, this.fromAppLink = false});

  @override
  _LoginState createState() => _LoginState(fromAppLink: fromAppLink);
}

class _LoginState extends State<Login> {
  final fromAppLink;
  _LoginState({this.fromAppLink});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginMessage = '';
  bool _buttonEnabled = false;
  bool _isObscured = true;
  bool _loading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      bool allFieldsFilled =
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
      bool validEmail = _emailController.text.contains('@');
      _buttonEnabled = allFieldsFilled && validEmail;
    });
  }

  void _onNext() async {
    if (_formKey.currentState!.validate()) {
      if (_loading) return;

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      FocusScope.of(context).requestFocus(FocusNode());

      try {
        await signIn(email, password);
      } catch (e) {
        setState(() {
          _loginMessage = 'Login failed. Please try again.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    pop() {
      SystemNavigator.pop();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
            onPressed: () {
              // ignore: void_checks
              return dialogBox.options(
                context,
                'Exit',
                'Are you sure you want to exit?',
                pop,
              );
            },
          ),
          actions: const [HelpWidget()],
        ),
        body: WillPopScope(
          onWillPop: () async {
            return dialogBox.options(
              context,
              'Exit',
              'Are you sure you want to exit?',
              pop,
            );
          },
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 1.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 28.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Text(
                              'Put in your account details to ',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                                color: AppColors.grayColor,
                              ),
                            ),
                            Text(
                              'get started',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            CustomInputField(
                              labelText: true,
                              label: 'Email address',
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
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
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _loginMessage,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      overflow: TextOverflow.ellipsis,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            CustomInputField2(
                              labelText: true,
                              label: 'Password',
                              controller: _passwordController,
                              keyboardType: TextInputType.text,
                              hasError: hasError,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              obscureText: _isObscured,
                              onTapVisibilityToggle: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                              onChanged: null,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  onTap: () {
                                    navigateWithSlideTransition(
                                      context: context,
                                      destinationScreen: const Forgotpword(),
                                      transitionDuration: const Duration(
                                        milliseconds: 200,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  CustomButton(
                    text: 'Sign In',
                    fontSize: 16.sp,
                    isLoading: _loading,
                    borderRadius: 30,
                    borderColor: Colors.white,
                    onPressed: _buttonEnabled ? _onNext : null,
                    color: _buttonEnabled
                        ? AppColors.primaryColor
                        : AppColors.grayColor2,
                    textColor: _buttonEnabled ? Colors.white : Colors.white,
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                  // SizedBox(height: 154.h),
                  buildSignInRow(
                    context: context,
                    questionText: "Don't have an account? ",
                    signInText: "Sign Up",
                    questionColor: AppColors.blackColor,
                    signInColor: AppColors.primaryColor,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      navigateWithSlideTransition(
                        context: context,
                        destinationScreen: const Register(),
                        transitionDuration: const Duration(milliseconds: 200),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signIn(String email, String password) async {
    setState(() {
      _loginMessage = '';
      _loading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signIn(email, password, context);

      if (success) {
        // Successfully signed in - navigation is handled by AuthProvider
        setState(() {
          _loading = false;
        });

        // Fetch additional data for dashboard
        // await _loadDashboardData();
      } else {
        setState(() {
          _loginMessage = authProvider.errorMessage.toString().replaceFirst(
            'Exception: ',
            '',
          );
          _loading = false;
          hasError = true;
        });
        print("_loginMessage:$_loginMessage");
      }
    } on TimeoutException catch (_) {
      setState(() {
        _loginMessage = 'Connection took too long. \nWant to retry?';
        _loading = false;
      });
    } on SocketException catch (_) {
      setState(() {
        _loginMessage = 'Please check your internet connection';
        _loading = false;
      });
    } catch (error) {
      print('Login error: $error');
      setState(() {
        _loginMessage = 'These credentials do not match our records.';
        _loading = false;
      });
    }
  }
}

class Token {
  String token;
  Token(this.token);

  factory Token.fromJSON(dynamic json) {
    return Token(json['data']['access_token'] as String);
  }

  @override
  String toString() {
    return ' { ${token} } ';
  }
}
