import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/custom_appbar_help.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'multi_form.dart';

class Precalc extends StatefulWidget {
  const Precalc({super.key});

  @override
  _PrecalcState createState() => _PrecalcState();
}

class _PrecalcState extends State<Precalc> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _buttonEnabled = false;

  @override
  void initState() {
    super.initState();

    // Add listeners to the controllers
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
      bool validEmail = _emailController.text.contains('@gmail.com');
      _buttonEnabled = allFieldsFilled && validEmail;
    });
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      navigateWithSlideTransition(
        context: context,
        destinationScreen: const Precalc(),
        transitionDuration: const Duration(
          milliseconds: 200,
        ), // Optional: Adjust transition duration
      );
    }
  }

  pop() {
    SystemNavigator.pop();
  }

  DialogBox dialogBox = DialogBox();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBarHelp(),
      body: WillPopScope(
        onWillPop: () {
          return dialogBox.options(
            context,
            'Close',
            'Are you sure you want to exit?',
            pop,
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 32.h),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Welcome ${context.watch<Providers>().loginDetails.firstname} 😊',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        'Are You ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                      Text(
                        'Financially Independent?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Being financially Independent is the ability to substain your livelihood or lifestyle without relying on income from employment or self-employment (e.g wages from jobs).',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16.sp,
                            color: AppColors.blackColor,
                          ),
                          maxLines: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Image.asset(
                  'assets/images/financial_independent.png',
                  width: 250.w,
                  height: 210.h,
                ),
                SizedBox(height: 40.h),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              'Ready to see how close you are to becoming financially independent ',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                        TextSpan(
                          text: '⁉️',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors
                                .primaryColor, // Use AppColors.primaryColor or define it
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButtonCalculateButton(
                  text: 'Calculate Now',
                  borderRadius: 777.r,
                  image: 'assets/arrow.gif',
                  borderColor: Colors.white,
                  fontSize: 16.sp,
                  onPressed: () {
                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: const MultiStepForm(
                        initialPage: 0,
                        currentPageIndex: 0,
                      ),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                  color: AppColors.primaryColor,
                  textColor: Colors.white,
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/info.png',
                      width: 16.w,
                      height: 16.h,
                    ),
                    const SizedBox(width: 1),
                    Text(
                      'Results will be displayed in both Time and Percentage',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: AppColors.grayColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonCalculateButton extends StatelessWidget {
  final String text;
  final String? image;
  final VoidCallback? onPressed;
  final Color textColor;
  final double fontSize;
  final Color iconColor;
  final bool isLoading;
  final double borderRadius;
  final Color? borderColor;
  final Color color;
  final bool borderSide; // Changed from dynamic to bool

  const CustomButtonCalculateButton({
    super.key,
    required this.text,
    this.image,
    this.borderColor,
    this.iconColor = Colors.white,
    required this.onPressed,
    required this.color,
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.isLoading = false,
    this.borderSide = true, // Default value for bool
    this.borderRadius = 777.0, // Default to the specific radius
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = 443.w;
    final double buttonHeight = 50.h;
    final double buttonBorderRadius = borderRadius.r;
    final Color buttonColor = color;
    final double borderWidth = 1.w;
    final EdgeInsets buttonPadding = EdgeInsets.fromLTRB(
      32.w,
      16.h,
      24.w,
      12.h,
    );

    return Container(
      // width: buttonWidth,
      // height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: iconColor,
          // minimumSize: Size(buttonWidth, buttonHeight),
          maximumSize: Size(buttonWidth, buttonHeight),
          fixedSize: Size(buttonWidth, buttonHeight),
          elevation: 0,
          disabledBackgroundColor: buttonColor.withOpacity(0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize.sp, // Use .sp for font size scaling
                color: textColor,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w), // Add some horizontal spacing
            Image.asset(
              image!,
              width: 24, // Set your desired width
              height: 24,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
