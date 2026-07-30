import 'dart:async';
import 'dart:convert';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../passcode/enterPasscode.dart';

class RetryPasscodeScreen extends StatefulWidget {
  final String originalPin;
  final String source;
  const RetryPasscodeScreen({
    required this.originalPin,
    required this.source,
    super.key,
  });

  @override
  _RetryPasscodeScreenState createState() => _RetryPasscodeScreenState();
}

class _RetryPasscodeScreenState extends State<RetryPasscodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String _currentPin = "";
  bool _isLoading = false;
  String _errorMessage = "";
  final dio = Dio();
  static const int _pinLength = 6;

  final ShakeAnimationController _shakeController = ShakeAnimationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pinFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
        ),
        actions: const [HelpWidget()],
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
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Re-type your ',
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
                  SizedBox(height: 10.h),
                  Text(
                    'Let\'s make sure it\'s correct',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grayColor,
                    ),
                  ),
                ],
              ),

              // Pin Dots
              ShakeAnimation(
                controller: _shakeController,
                child: _buildPinDots(),
              ),

              // Hidden TextField
              _buildHiddenTextField(),

              // Loading Indicator
              if (_isLoading) ...[
                const SpinKitCircle(color: Colors.black, size: 40.0),
              ],

              // Number Pad
              SizedBox(
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double spacing = 20.h;
                    final double buttonSize =
                        (constraints.maxWidth - spacing * 4) / 3;
                    return Column(
                      children: [
                        _buildNumberRow(['1', '2', '3'], buttonSize, spacing),
                        SizedBox(height: spacing),
                        _buildNumberRow(['4', '5', '6'], buttonSize, spacing),
                        SizedBox(height: spacing),
                        _buildNumberRow(['7', '8', '9'], buttonSize, spacing),
                        SizedBox(height: spacing),
                        _buildNumberRow(
                          ['', '0', 'Clear'],
                          buttonSize,
                          spacing,
                          isLastRow: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final bool isFilled = index < _currentPin.length;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          width: isFilled ? 16.w : 12.w,
          height: isFilled ? 16.w : 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.black : const Color(0xffe4e4e4),
          ),
        );
      }),
    );
  }

  Widget _buildHiddenTextField() {
    return SizedBox(
      width: 1,
      height: 1,
      child: TextField(
        focusNode: _pinFocusNode,
        controller: _controller,
        keyboardType: TextInputType.none,
        maxLength: _pinLength,
        readOnly: true,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: false,
        showCursor: false,
        enableInteractiveSelection: false,
        style: const TextStyle(color: Colors.transparent),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {
            _currentPin = value;
            _errorMessage = "";
          });

          if (value.length == _pinLength) {
            _validateAndSavePasscode(value);
          }
        },
      ),
    );
  }

  Widget _buildNumberRow(
    List<String> values,
    double buttonSize,
    double spacing, {
    bool isLastRow = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((value) {
        if (value.isEmpty) {
          return SizedBox(width: buttonSize, height: buttonSize);
        }
        if (value == 'Clear') {
          return _buildClearButton();
        }
        return _buildNumberButton(value, buttonSize);
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomAnimatedNumPad(
        onPressed: () => _onNumberPressed(int.parse(number)),
        child: Text(
          number.toString(),
          style: GoogleFonts.nunitoSans(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _clearPin,
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

  void _onNumberPressed(int number) {
    if (_controller.text.length < _pinLength) {
      setState(() {
        _controller.text += number.toString();
        _currentPin = _controller.text;
      });

      if (_controller.text.length == _pinLength) {
        _validateAndSavePasscode(_controller.text);
      }
    }
  }

  void _triggerShake() {
    _shakeController.shake();
  }

  void _clearPin() {
    setState(() {
      _controller.clear();
      _currentPin = "";
      _errorMessage = "";
    });
  }

  Future<void> _performPasscodeSaving(String retypedPin, String token) async {
    final Uri passcodeUrl = Uri.parse("$baseUrl/mygap/biometric/passcode");

    final http.Response response = await http
        .post(
          passcodeUrl,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({'passcode': retypedPin}),
        )
        .timeout(const Duration(seconds: 30));

    _handleSaveResponse(response);
  }

  void _handleSaveResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        if (mounted) {
          Navigator.of(context).pop(true);
          Navigator.of(context).pop(true);
        }
      } else {
        final String errorMessage =
            responseData['message'] ?? 'Failed to save passcode';
        _handleSaveError(errorMessage);
      }
    } else {
      _handleSaveError('Failed to save passcode. Please try again.');
    }
  }

  void _validateAndSavePasscode(String retypedPin) async {
    if (_isLoading) return;

    if (widget.originalPin != retypedPin) {
      setState(() {
        _errorMessage = "Passcodes don't match. Please try again.";
        _controller.clear();
        _currentPin = "";
      });
      _triggerShake();
      _showErrorBottomSheet('Passcodes do not match. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenDB');

      if (token == null || token == 'logout') {
        _handleSessionExpired();
        return;
      }

      await _performPasscodeSaving(retypedPin, token);
    } catch (e) {
      _handleSaveError('An error occurred. Please try again.');
    }
  }

  void _handleSessionExpired() {
    setState(() {
      _errorMessage = 'Session expired. Please login again.';
      _clearPin();
      _isLoading = false;
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleSaveError(String message) {
    if (!mounted) return;

    _triggerShake();

    setState(() {
      _errorMessage = message;
      _clearPin();
      _isLoading = false;
    });
    _showErrorBottomSheet(message);
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  color: AppColors.grayColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
