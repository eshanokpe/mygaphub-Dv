// ignore_for_file: deprecated_member_use

import 'package:GapHub/screens/authentication/default.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/authentication/passcode/passcode.dart';
import 'package:GapHub/screens/authentication/touchID/touchid.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authentication/passcode/setpasscode.dart';
import '../registration/register/register.dart';
import 'content_model.dart';
import 'widget/header.dart';

class Onboarding extends StatefulWidget {
  final bool eWork;
  const Onboarding(this.eWork, {super.key});

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  PageController? _controller;
  AnimationController? _animationController;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final height = isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              const Header(),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 40,
                        right: 40,
                        bottom: 40,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          // SizedBox(height: 300.h),
                          SvgPicture.asset(contents[i].image, height: 300.h),
                          Text(
                            contents[i].title,
                            style: TextStyle(
                              fontFamily: 'NunitoSans',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Text(
                            contents[i].discription,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF272727),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  contents.length,
                  (index) => buildDot(index, context),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20.w),
                width: double.infinity,
                child: currentIndex == contents.length - 1
                    ? ElevatedButton(
                        onPressed: () async {
                          if (currentIndex == contents.length - 1) {
                            final prefs = await SharedPreferences.getInstance();
                            var token = prefs.getString('tokenDB');
                            var signin = prefs.getString('signin');

                            var passcode = prefs.getString('passcode');

                            if (token != null && widget.eWork == true) {
                              if (signin == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Default(),
                                  ),
                                );
                              } else if (signin == 'passcode' &&
                                  passcode != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Passcode(),
                                  ),
                                );
                              } else if (signin == 'passcode' &&
                                  passcode == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SetPasscodeScreen(),
                                  ),
                                );
                              } else if (signin == 'touchid') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TouchID(),
                                  ),
                                );
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            }
                          }
                          _controller!.nextPage(
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.bounceIn,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(32.w, 16.h, 24.w, 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentIndex == contents.length - 1
                                  ? "Get Started "
                                  : "Next",
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 2.w,
                            ), // Add some space between the text and icon
                            Icon(
                              Icons.arrow_forward_ios, // Forward icon
                              color: Colors.white,
                              size: 15.w,
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: currentIndex == contents.length - 1
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentIndex < contents.length - 1)
                            TextButton(
                              onPressed: () {
                                _controller!.jumpToPage(contents.length - 1);
                              },
                              child: Text(
                                "Skip",
                                style: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 16.sp,
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Container(
                            // margin: EdgeInsets.all(20.w),
                            // width: double.infinity,
                            child: TextButton(
                              onPressed: () async {
                                if (currentIndex == contents.length - 1) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  var token = prefs.getString('tokenDB');
                                  print(token);
                                  var signin = prefs.getString('signin');
                                  print(signin);
                                  var passcode = prefs.getString('passcode');
                                  print(passcode);

                                  if (token != null && widget.eWork == true) {
                                    if (signin == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Default(),
                                        ),
                                      );
                                    } else if (signin == 'passcode' &&
                                        passcode != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Passcode(),
                                        ),
                                      );
                                    } else if (signin == 'passcode' &&
                                        passcode == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SetPasscodeScreen(),
                                        ),
                                      );
                                    } else if (signin == 'touchid') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TouchID(),
                                        ),
                                      );
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ),
                                    );
                                  }
                                }
                                _controller!.nextPage(
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.bounceIn,
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.fromLTRB(
                                  32.w,
                                  16.h,
                                  24.w,
                                  16.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    currentIndex == contents.length - 1
                                        ? "Get Started "
                                        : "Next",
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ), // Add some space between the text and icon
                                  Icon(
                                    Icons.arrow_forward_ios, // Forward icon
                                    color: Colors.white,
                                    size: 15.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 3,
      width: currentIndex == index ? 30 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? Colors.black : Colors.grey,
      ),
    );
  }
}
