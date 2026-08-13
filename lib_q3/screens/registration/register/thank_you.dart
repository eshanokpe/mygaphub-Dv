import 'dart:async';

import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/custom_button_outline.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'join_community.dart';

class ThankYou extends StatefulWidget {
  const ThankYou({super.key});

  @override
  _ThankYouState createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  final _formKey = GlobalKey<FormState>();
  DialogBox dialogBox = DialogBox();
  @override
  void initState() {
    super.initState();
    const MethodChannel("com.prismcheck.GapHub.goToLogin").setMethodCallHandler(
      (MethodCall call) async {
        if (call.method == "goToLoginFromVerification") {
          print("receiving from goToLoginFromVerification");
          var routeName = ModalRoute.of(context)!.settings.name;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (routeName == "Verification" && routeName != null) {
              Timer(const Duration(milliseconds: 200), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(fromAppLink: true),
                  ),
                );
              });
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    pop() {
      SystemNavigator.pop();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [HelpWidget()],
      ),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/thankYou.gif',
                          height: 150.h,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Thank you for signing up!!',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 22.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        'Please check your email for instructions to verify your account.',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn’t receive any mail? ",
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w300,
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            "Resend",
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          onTap: () {
                            // Handle Resend tap
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const JoinOurCommunitySection(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primaryColor,
                          side: const BorderSide(
                            color: AppColors.grayColor,
                            width: 0.5,
                          ),
                          textStyle: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white,
                          ),
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
