import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/utils/colors.dart'; // Import AppColors if needed for specific color
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widget/testimonialCarousel.dart';

class AITradedForex extends StatelessWidget {
  const AITradedForex({super.key});

  final List<_Feature> features = const [
    _Feature(
      image: 'assets/images/acquisition/passIncome.png',
      title: "Passive Income",
      description:
          "Enjoy the potential for high returns without the stress of daily trading.",
    ),
    _Feature(
      image: 'assets/images/acquisition/innovative.png',
      title: "Innovative",
      description:
          "Utilise sophisticated algorithms that adapt to changes in the market landscape.",
    ),
    _Feature(
      image: 'assets/images/acquisition/userFriendly.png',
      title: "User-Friendly",
      description:
          "Simple onboarding, intuitive access, and support to start investing quickly.",
    ),
    _Feature(
      image: 'assets/images/acquisition/transparency.png',
      title: "Transparency",
      description:
          "Real-time updates and performance tracking through the vantage platform.",
    ),
  ];

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
                          'Hands-Free Investing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          'with',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'High-Level Returns ',
                          style: TextStyle(
                            fontFamily: 'NunitoSan',
                            fontWeight: FontWeight.w900,
                            fontSize: 22.sp,
                            color: const Color(0xFFA80733),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/acquisition/high_level_return.png',
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
                    const TextSpan(
                      text:
                          'Welcome to the future of investing! Our AI-traded forex account solution is designed for those who want to grow their wealth effortlessly. With a minimum investment of just ',
                    ),
                    TextSpan(
                      text: '£5,000, ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    const TextSpan(
                      text: 'you can potentially earn returns of up to ',
                    ),
                    TextSpan(
                      text: '60% ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'while our advanced AI technology handles the trading for you.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              GridView.builder(
                itemCount: features.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70.h,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12.w,
                ),
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffE8E8E8),
                          Color(0xffF1F1F1),
                        ], // light grey gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(feature.image, height: 54.h),
                        SizedBox(height: 12.h),
                        Text(
                          feature.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          feature.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // SizedBox(height: 10.h),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10.h),
              Text(
                'This innovative investment opportunity allows you to benefit from automated trading strategies powered by artificial intelligence. Our AI analyses market trends, executes trades, and manages your portfolio, all while you sit back and relax.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 10.h),
              const TestimonialCarousel(),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your future of wealth is One Click Away',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
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
                  'Reserve Your Spot Now',
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

class _Feature {
  final String image;
  final String title;
  final String description;

  const _Feature({
    required this.image,
    required this.title,
    required this.description,
  });
}
