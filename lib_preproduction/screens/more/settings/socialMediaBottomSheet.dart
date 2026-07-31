import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaBottomSheet {
  final BuildContext context;

  SocialMediaBottomSheet(this.context);

  void show() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16.0.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffcdcdcd),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Social media',
                textAlign: TextAlign.left,
                style: GoogleFonts.nunitoSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Connect with us on your favorite social media platforms!',
                textAlign: TextAlign.left,
                style: GoogleFonts.nunito(
                  fontSize: 16.sp,
                  color: const Color(0xff393737),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
              _buildSocialMediaRow(
                assetPath: 'assets/settings/facebook.png',
                label: 'Follow us on Facebook',
                onTap: () => _launchUrl('https://www.facebook.com/prismcheck'),
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildSocialMediaRow(
                assetPath: 'assets/settings/instagram.png',
                label: 'Follow us on Instagram',
                onTap: () => _launchUrl('https://www.instagram.com/mygaphub'),
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildSocialMediaRow(
                assetPath: 'assets/settings/x.png',
                label: 'Follow us on X',
                onTap: () => _launchUrl('https://x.com/PrismcheckUK'),
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildSocialMediaRow(
                assetPath: 'assets/settings/threads.png',
                label: 'Follow us on Threads',
                onTap: () => _launchUrl('https://www.threads.net/@mygap_hub'),
              ),
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildSocialMediaRow(
                assetPath: 'assets/settings/youtube.png',
                label: 'Follow us on Youtube',
                onTap: () =>
                    _launchUrl('https://www.youtube.com/@prismcheckuk'),
              ), 
              Divider(
                color: const Color(0xffefefef),
                thickness: 1.h,
                height: 1.h,
                indent: 50.w,
                endIndent: 30.w,
              ),
              _buildSocialMediaRow(
                assetPath: 'assets/settings/linkedin.png',
                label: 'Follow us on LinkedIn',
                onTap: () => _launchUrl(
                  'https://uk.linkedin.com/company/prismcheck-uk-limited',
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialMediaRow({
    required String assetPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(assetPath, width: 32.w, height: 32.h),
            SizedBox(width: 16.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    await canLaunch(url)
        ? launch(url)
        : ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
  }
}
