import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildDescriptionSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildDescriptionSection({
    super.key,
    required this.propertyDetail,
    required this.height,
    required this.width,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height * .01),
        IntrinsicHeight(
          child: Row(
            children: [
              // Icon with fixed width
              SizedBox(
                width: 24.w,
                child: Image.asset('assets/images/acquisition/location22.png'),
              ),
              SizedBox(width: width * 0.01),
              // Address text that takes remaining space
              Expanded(
                child: Text(
                  propertyDetail.propertyAddress ?? 'Address not available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff272727),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              // View button with minimum spacing
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () => _launchBrochure(context, propertyDetail),
                  child: Text(
                    'View',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                      fontSize: width * 0.038,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height * .01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          child: const Divider(color: Color(0xffe2e2e2), thickness: 0.5),
        ),
        SizedBox(height: height * .02),
        Text(
          'Asset Description',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: width * .043,
          ),
        ),
        SizedBox(height: height * .02),
        Text(
          propertyDetail.propertyContent,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w300,
            fontSize: width * .040,
          ),
        ),
        SizedBox(height: height * .01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          child: const Divider(color: Color(0xffe2e2e2), thickness: 0.5),
        ),
        SizedBox(height: height * .02),
      ],
    );
  }

  Future<void> _launchBrochure(
    BuildContext context,
    PropertyDetailModel propertyDetail,
  ) async {
    // Check if brochure is available
    if (propertyDetail.brochure.isEmpty) {
      _showToast('No brochure document available');
      return;
    }

    // Validate URL format
    final brochureUrl = propertyDetail.brochure;
    if (!brochureUrl.startsWith('http://') &&
        !brochureUrl.startsWith('https://')) {
      _showToast('Invalid brochure URL format');
      return;
    }

    Uri? url;
    try {
      url = Uri.parse(brochureUrl);
    } catch (e) {
      _showToast('Invalid brochure URL');
      return;
    }

    // Show loading indicator
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );

    try {
      // Check URL launch capability
      final canLaunch = await canLaunchUrl(url);
      if (!canLaunch) {
        await loadingDialog;
        _showToast('Cannot open brochure');
        return;
      }

      // Launch URL with error handling
      final launched =
          await launchUrl(url, mode: LaunchMode.externalApplication).catchError(
            (e) {
              debugPrint('Error launching URL: $e');
              return false;
            },
          );

      if (!launched) {
        _showToast('Failed to open brochure');
      }
    } finally {
      // Dismiss loading dialog if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // Helper method for showing toast messages
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      textColor: Colors.white,
    );
  }
}
