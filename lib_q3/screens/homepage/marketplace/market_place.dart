import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/marketOpportunitiesProvider.dart';
import 'package:GapHub/models/marketPlace.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widget/row_view_details.dart';
import 'market_place_list.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  @override
  void initState() {
    super.initState();
    Provider.of<MarketOpportunitiesProvider>(
      context,
      listen: false,
    ).fetchMarketOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final orientation = MediaQuery.of(context).orientation;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardHeight = 160.h;

    return Column(
      children: [
        RowViewDetails(
          arrowTap: false,
          mainText: 'MarketPlace'.toUpperCase(),
          detailText: '',
          onTap: () {
            navigateWithSlideTransition(
              context: context,
              destinationScreen: MarketPlaceList(),
              transitionDuration: const Duration(milliseconds: 200),
            );
          },
        ),
        SizedBox(height: screenHeight * 0.02),
        Consumer<MarketOpportunitiesProvider>(
          builder: (context, provider, _) {
            if (provider.marketOpportunities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.marketOpportunities.length,
                itemBuilder: (context, index) {
                  final opportunity = provider.marketOpportunities[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildOpportunityCard(
                      opportunity,
                      isTablet,
                      cardHeight,
                      screenWidth,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(
    MarketOpportunity opportunity,
    bool isTablet,
    double height,
    double width,
  ) {
    return SizedBox(
      width: width * 0.9,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Background Image with proper containment
            Positioned.fill(
              child: Container(
                color: Colors.white, // Fallback background color
                child: CachedNetworkImage(
                  imageUrl: opportunity.bannerUrl,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
                  fit: isTablet ? BoxFit.cover : BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // Button overlay
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 26.w),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _showOpportunityDialog(context, opportunity),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opportunity.buttonText,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 12.w,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOpportunityDialog(
    BuildContext context,
    MarketOpportunity opportunity,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                width: 311.w,
                height: 160.h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  color: const Color(0xfffbfbfb),
                  borderRadius: BorderRadius.circular(5),
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
                'You will be redirected to our REAP BESPOKE information page. '
                'Here, you will discover how we can facilitate your aspiration '
                'to build your own property in your home country, ensuring a '
                'seamless and stress-free experience. We can\'t wait to assist you!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      fontSize: 14.sp,
                      borderRadius: 10,
                      borderColor: const Color(0xffefefef),
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () =>
                          _launchOpportunityUrl(context, opportunity),
                      color: AppColors.primaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchOpportunityUrl(
    BuildContext context,
    MarketOpportunity opportunity,
  ) async {
    Navigator.pop(context); // Close dialog first
    final url = Uri.parse(opportunity.destinationLink);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
