import 'package:GapHub/screens/registration/financial_health/multichoice.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Prequestions extends StatefulWidget {
  const Prequestions({key});

  @override
  State<Prequestions> createState() => _PrequestionsState();
}

class _PrequestionsState extends State<Prequestions> {
  @override
  Widget build(BuildContext context) {
    DialogBox dialogBox = DialogBox();

    pop() {
      SystemNavigator.pop();
    }

    return WillPopScope(
      onWillPop: () async {
        return dialogBox.options(
          context,
          'Close',
          'Are you sure you want to exit? ',
          pop,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 48.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/logo.png', width: 30.w),
                        const SizedBox(width: 5),
                        Image.asset('assets/gaaphub.png', width: 82.w),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    const Text(
                      'We’re excited you have decided to open a GAP Account 😊',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          const Text(
                            'Before you jump into the app and start enjoying the great features, we would like you to take this quick financial health check so you can maximise your experience with myGAPhub.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                    const SizedBox(height: 0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomButton(
                  text: 'Start',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: Icons.arrow_forward_ios,
                  iconColor: Colors.white,
                  borderColor: Colors.white,
                  onPressed: () {
                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: Multichoice(),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                  color: AppColors.primaryColor,
                  textColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
