import 'dart:async';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinOurCommunitySection extends StatefulWidget {
  const JoinOurCommunitySection({super.key});

  @override
  State<JoinOurCommunitySection> createState() =>
      _JoinOurCommunitySectionState();
}

class _JoinOurCommunitySectionState extends State<JoinOurCommunitySection> {
  int _currentImageIndex = 0;
  late Timer _timer;

  final String whatsappLink =
      'https://chat.whatsapp.com/JPeN2zvI4OI4V1aAwNQuYv?mode=ems_copy_t';

  Future<void> _launchWhatsAppLink() async {
    final Uri url = Uri.parse(whatsappLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp group');
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _currentImageIndex = _currentImageIndex == 0 ? 1 : 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16.0), child: HelpWidget()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Join our Thriving Community",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Join the community of people who are passionate about financial independence and creating lasting wealth.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grayColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            SizedBox(height: 40.h),

            // Alternating Images
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: Image.asset(
                  _currentImageIndex == 0
                      ? 'assets/images/community/join1.png'
                      : 'assets/images/community/join2.png',
                  key: ValueKey<int>(_currentImageIndex),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),

            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.borderColor2,
                        width: 1.5,
                      ),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _launchWhatsAppLink,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Join us now!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
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