import 'dart:convert';
import 'dart:math' as math;

import 'package:GapHub/widgets/shakeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:GapHub/screens/authentication/login/forgotPin/forgot_pin.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import '../signInPreferences/changePasscode.dart';

class EnterPasscodeScreen extends StatefulWidget {
  final bool? settings;
  const EnterPasscodeScreen({this.settings, super.key});

  @override
  _EnterPasscodeScreenState createState() => _EnterPasscodeScreenState();
}

class _EnterPasscodeScreenState extends State<EnterPasscodeScreen> {
  static const int _pinLength = 6;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String _currentPin = "";
  bool _isLoading = false;
  String _errorMessage = "";

  // Shake animation controller
  final ShakeAnimationController _shakeController = ShakeAnimationController();

  @override
  void dispose() {
    _controller.dispose();
    _pinFocusNode.dispose();
    _shakeController.dispose(); // Dispose the shake controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto-focus the pin field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_pinFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: const [HelpWidget()],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildTitle(),
            SizedBox(height: 10.h),
            _buildSubtitle(),
            SizedBox(height: 70.h),
            _buildPinCodeField(),
            Expanded(child: _buildNumPad()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
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
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Verify that this account belongs to you',
      textAlign: TextAlign.left,
      style: GoogleFonts.nunitoSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.grayColor,
      ),
    );
  }

  Widget _buildPinCodeField() {
    return ShakeAnimation(
      controller: _shakeController,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 100.w),
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildPinDots(),
            // Position the text field outside the visible area
            Positioned(
              top: -100, // Position it far outside the visible area
              child: _buildHiddenTextField(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenTextField() {
    return SizedBox(
      width: 1, // Minimal size
      height: 1,
      child: TextField(
        focusNode: _pinFocusNode,
        controller: _controller,
        keyboardType: TextInputType.number,
        maxLength: _pinLength,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: false,
        showCursor: false,
        style: const TextStyle(fontSize: 0, color: Colors.transparent),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _onPinChanged,
      ),
    );
  }

  void _onNumberPressed(int number) {
    if (_controller.text.length < _pinLength) {
      // Update the controller text directly
      _controller.text = _controller.text + number.toString();

      // Manually trigger the onChanged callback since modifying controller.text directly doesn't trigger it
      _onPinChanged(_controller.text);
    }
  }

  void _clearPin() {
    setState(() {
      _controller.text = "";
      _currentPin = "";
      _errorMessage = "";
    });
  }

  void _onPinChanged(String value) {
    setState(() {
      _currentPin = value;
      _errorMessage = "";
    });

    if (value.length == _pinLength) {
      _verifyPasscode(value);
    }
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(_pinLength, (index) {
        final bool isFilled = index < _currentPin.length;
        // Only show active (bigger) dot when this is the NEXT position to be filled
        final bool isActive =
            index == _currentPin.length && _currentPin.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isFilled ? 16.w : 12.w,
          height: isFilled ? 16.w : 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Colors.black
                : isActive
                ? Colors.grey.shade400
                : const Color(0xffe4e4e4),
          ),
        );
      }),
    );
  }

  Widget _buildNumPad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 20.h;
        final double buttonSize = (constraints.maxWidth - spacing * 4) / 3;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberRow([1, 2, 3], buttonSize, spacing),
            SizedBox(height: spacing),
            _buildNumberRow([4, 5, 6], buttonSize, spacing),
            SizedBox(height: spacing),
            _buildNumberRow([7, 8, 9], buttonSize, spacing),
            SizedBox(height: spacing),
            _buildBottomRow(buttonSize),
          ],
        );
      },
    );
  }

  Widget _buildNumberRow(List<int> numbers, double buttonSize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers
          .map((number) => _buildNumberButton(number, buttonSize))
          .toList(),
    );
  }

  Widget _buildBottomRow(double buttonSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildForgotButton(buttonSize),
        _buildNumberButton(0, buttonSize),
        _buildClearButton(buttonSize),
      ],
    );
  }

  Widget _buildForgotButton(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPINScreen()),
          );
        },
        child: Text(
          'Forgot?',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: TextButton(
        onPressed: _clearPin,
        child: Text(
          'Clear',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomAnimatedNumPad(
        onPressed: () => _onNumberPressed(number),
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

  // Method to trigger the shake animation
  void _triggerShake() {
    _shakeController.shake();
  }

  Future<void> _verifyPasscode(String enteredPin) async {
    if (_isLoading) return;

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

      await _performPasscodeVerification(enteredPin, token);
    } catch (e) {
      _handleVerificationError('An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _performPasscodeVerification(
    String enteredPin,
    String token,
  ) async {
    final Uri verifyUrl = Uri.parse("$baseUrl/mygap/passcode/confirm");

    final http.Response response = await http
        .post(
          verifyUrl,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
          body: {'passcode': enteredPin},
        )
        .timeout(const Duration(seconds: 30));

    _handleVerificationResponse(response, enteredPin);
  }

  void _handleVerificationResponse(http.Response response, String enteredPin) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        _navigateToChangePasscodeScreen();
      } else {
        final String errorMessage =
            responseData['message'] ?? 'Invalid passcode';
        _handleVerificationError(errorMessage);
      }
    } else {
      _handleVerificationError('Failed to verify passcode. Please try again.');
    }
  }

  void _handleSessionExpired() {
    setState(() {
      _errorMessage = 'Session expired. Please login again.';
      _clearPin();
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleVerificationError(String message) {
    if (!mounted) return;

    // Trigger shake animation when there's an error
    _triggerShake();

    setState(() {
      _errorMessage = message;
      _clearPin();
    });
    _showErrorBottomSheet(message);
  }

  void _navigateToChangePasscodeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasscodeScreen(source: 'forgotPin'),
      ),
    ).then((result) {
      if (result == true) {
        // This will trigger when we come back from successful passcode change
        // We'll handle the success in SignInPreferences instead
      }
    });
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
          margin: EdgeInsets.only(top: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 5.w),
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
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }
}

class ShakeAnimationController {
  VoidCallback? _shakeListener;

  void shake() {
    _shakeListener?.call();
  }

  void setListener(VoidCallback listener) {
    _shakeListener = listener;
  }

  void dispose() {
    _shakeListener = null;
  }
}

class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final ShakeAnimationController controller;
  final Duration duration;
  final double shakeDistance;

  const ShakeAnimation({
    super.key,
    required this.child,
    required this.controller,
    this.duration = const Duration(milliseconds: 1600),
    this.shakeDistance = 10,
  });

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Set up the controller listener
    widget.controller.setListener(_triggerShake);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double shakeOffset =
            _animation.value *
            widget.shakeDistance *
            _getShakeCurve(_animation.value);

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  double _getShakeCurve(double value) {
    // This creates a shake effect that goes left and right
    return math.sin(value * math.pi * 8); // 8 oscillations for a nice shake
  }
}
