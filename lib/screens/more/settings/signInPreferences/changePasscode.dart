import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/customAminatedNumPad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../passcode/enterPasscode.dart';
import 'retryPasscode.dart';

class ChangePasscodeScreen extends StatefulWidget {
  final String source;
  const ChangePasscodeScreen({super.key, required this.source});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasscodeScreenState createState() => _ChangePasscodeScreenState();
}

class _ChangePasscodeScreenState extends State<ChangePasscodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String _currentPin = "";
  static const int _pinLength = 6;
  bool _isNavigating = false; // Add this flag to prevent multiple navigations

  // Shake animation controller
  final ShakeAnimationController _shakeController = ShakeAnimationController();

  @override
  void dispose() {
    _controller.dispose();
    _pinFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Auto-focus the pin field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_pinFocusNode);
      }
    });
    print('🔥 ChangePasscodeScreen called');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [HelpWidget()],
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
      ),
      body: GestureDetector(
        // Add this to handle taps outside the text field
        onTap: () {
          _pinFocusNode.unfocus();
        },
        child: SingleChildScrollView(
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
                // Header Text Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Change your ',
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
                      'Ensure your code is not easy to guess for extra account protection',
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
          });

          if (value.length == _pinLength && !_isNavigating) {
            _navigateToRetryScreen();
          }
        },
      ),
    );
  }

  // Extract navigation logic to a separate method
  void _navigateToRetryScreen() async {
    if (_isNavigating) return;

    _isNavigating = true;

    // Unfocus to hide keyboard before navigation
    _pinFocusNode.unfocus();

    // Small delay to ensure unfocus completes
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RetryPasscodeScreen(
          originalPin: _currentPin,
          source: widget.source,
        ),
      ),
    );

    _isNavigating = false;

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      // Clear the pin if navigation was cancelled or failed
      setState(() {
        _controller.clear();
        _currentPin = "";
      });
      // Refocus after returning
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_pinFocusNode);
        }
      });
    }
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
        onTap: () {
          setState(() {
            _controller.clear();
            _currentPin = "";
          });
        },
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

  void _triggerShake() {
    _shakeController.shake();
  }

  void _onNumberPressed(int number) {
    if (_controller.text.length < _pinLength && !_isNavigating) {
      setState(() {
        _controller.text += number.toString();
        _currentPin = _controller.text;
      });

      if (_controller.text.length == _pinLength) {
        _navigateToRetryScreen();
      }
    }
  }
}
