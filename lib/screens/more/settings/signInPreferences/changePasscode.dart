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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.grayColor,
              ),
            ),
            SizedBox(height: 70.h),
            _buildPinCodeField(),
            Expanded(child: _buildNumPad()),
          ],
        ),
      ),
    );
  }

  Widget _buildPinCodeField() {
    return ShakeAnimation(
      controller: _shakeController,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 100.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildPinDots(),
            Positioned(top: -100, child: _buildHiddenTextField()),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenTextField() {
    return SizedBox(
      width: 1,
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
        onChanged: (value) {
          setState(() {
            _currentPin = value;
          });

          // Navigate when PIN is complete
          if (value.length == _pinLength) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute( 
                  builder: (context) => RetryPasscodeScreen(
                    originalPin: _currentPin,
                    source: widget.source,
                  ),
                ),
              ).then((success) {
                if (success == true) {
                  // Pass back the success result to SignInPreferences
                  Navigator.of(context).pop(true);
                }
              });
            });
          }
        },
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(_pinLength, (index) {
        final bool isFilled = index < _currentPin.length;
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
        double spacing = 20.h;
        double buttonSize = (constraints.maxWidth - spacing * 4) / 3;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberRow([1, 2, 3], buttonSize, spacing),
            SizedBox(height: spacing),
            _buildNumberRow([4, 5, 6], buttonSize, spacing),
            SizedBox(height: spacing),
            _buildNumberRow([7, 8, 9], buttonSize, spacing),
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: buttonSize),
                _buildNumberButton(0, buttonSize),
                _buildClearButton(buttonSize),
              ],
            ),
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

  Widget _buildClearButton(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: TextButton(
        onPressed: () {
          setState(() {
            _controller.clear();
            _currentPin = "";
          });
        },
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

  // Method to trigger the shake animation
  void _triggerShake() {
    _shakeController.shake();
  }

  void _onNumberPressed(int number) {
    if (_controller.text.length < _pinLength) {
      setState(() {
        _controller.text += number.toString();
        _currentPin = _controller.text;
      });

      if (_controller.text.length == _pinLength) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RetryPasscodeScreen(
                originalPin: _currentPin,
                source: widget.source,
              ),
            ),
          ).then((success) {
            if (success == true) {
              // Pass back the success result to SignInPreferences
              Navigator.of(context).pop(true);
            }
          });
        });
      }
    }
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
}