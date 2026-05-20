import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class DeFiMasteryTrading extends StatelessWidget {
  const DeFiMasteryTrading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        actions: const [AvatarImage()],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 32.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DeFi ',
                          style: TextStyle(
                            fontFamily: 'NunitoSan',
                            fontWeight: FontWeight.w900,
                            fontSize: 22.sp,
                            color: const Color(0xFFA80733),
                          ),
                        ),
                        Text(
                          'Made Simple',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'A guided path to decentralised finance and passive income',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/acquisition/defiMade.png',
                      height: 203.h,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    // Base style for the RichText
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: Colors.black, // Default color
                  ),
                  children: <TextSpan>[
                    const TextSpan(text: 'With as little as '),
                    TextSpan(
                      text: '£500,',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'you can apply to our 8-week mastery program to gain practical DeFi skills and access real investment opportunities. The FIT-powered platform offers up to ',
                    ),
                    TextSpan(
                      text: '20% ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: 'returns, all while you learn. '),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Join Our Free Webinar ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    'and ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFA80733),
                    Color(0xFFCE0001),
                  ], // Example gradient colors, adjust as needed
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Start Your DeFi Journey Today',
                  style: TextStyle(
                    fontFamily: 'NunitoSan',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      // Use a different context name
                      return WebinarDialog(dialogContext);
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/acquisition/buttonWebinar.png',
                        height: 56.h,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'By registering, you consent to joining our information group, where you will receive details about upcoming webinars and periodic updates regarding this investment opportunity. ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 112.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget WebinarDialog(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
              width: 311.w,
              height: 160.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.0),
                color: const Color(0xfffbfbfb),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Image.asset('assets/images/see-you-go.png'),
            ),
            SizedBox(height: 22.h),
            Text(
              'You\'re About to Leave the App',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'You will be redirected to our registration platform to complete the process and book your webinar.',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Makes the 'Cancel' button take up available space
                  child: CustomButton(
                    text: 'Cancel',
                    fontSize: 14.sp,
                    borderRadius: 10,
                    borderColor: const Color(0xffefefef),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                    },
                    color: Colors.white,
                    textColor: Colors.black,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    text: 'Proceed',
                    fontSize: 14.sp,
                    borderRadius: 10,
                    borderColor: const Color(0xffefefef),
                    onPressed: () async {
                      final Uri url = Uri.parse(
                        'https://share.hsforms.com/1rJrUl74TQvKL3qipTZKypQoy0x8',
                      );
                      if (!await launchUrl(url)) {
                        // Optionally handle the error, e.g., show a SnackBar
                        throw Exception('Could not launch $url');
                      }
                    },
                    color: AppColors.primaryColor,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
