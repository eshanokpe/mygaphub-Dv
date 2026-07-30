import 'package:GapHub/models/FinancialHubModel.dart';
import 'package:GapHub/provider/marketOpportunitiesProvider.dart';
import 'package:GapHub/screens/homepage/financial_intelligence_hub/financial_intelligenceHub.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_display_page.dart';

class FinancialIntelligenceHubSlider extends StatefulWidget {
  const FinancialIntelligenceHubSlider({super.key});

  @override
  State<FinancialIntelligenceHubSlider> createState() =>
      _FinancialIntelligenceHubSliderState();
}

class _FinancialIntelligenceHubSliderState
    extends State<FinancialIntelligenceHubSlider> {
  @override
  void initState() {
    super.initState();
    Provider.of<MarketOpportunitiesProvider>(
      context,
      listen: false,
    ).fetchFinancialIntelligenceHub();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final height = orientation == Orientation.portrait
        ? size.height
        : size.width;
    final width = orientation == Orientation.portrait
        ? size.width
        : size.height;

    double cardHeight = 230.h;

    return Column(
      children: [
        RowViewDetails(
          mainText: 'Financial Intelligence Hub',
          detailText: 'View All',
          arrowTap: true, 
          onTap: () {
            navigateWithSlideTransition(
              context: context,
              destinationScreen: const FinancialIntelligenceHub(),
              transitionDuration: const Duration(milliseconds: 200),
            );
          },
        ),
        SizedBox(height: height * 0.02),
        Consumer<MarketOpportunitiesProvider>(
          builder: (context, provider, _) {
            if (provider.financialHubModel.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.financialHubModel.length,
                itemBuilder: (context, index) {
                  final financialHub = provider.financialHubModel[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: _buildCard(context, financialHub, cardHeight, width),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    FinancialHubModel financialHub,
    double itemHeight, // This is the cardHeight (e.g., 220.h)
    double screenWidth, // Original 'width' param, screen's width
  ) {
    // Calculate the width for individual cards based on the screen width
    double cardItemWidth = screenWidth * 0.7;

    return GestureDetector(
      onTap: () {
        print('video Link:${financialHub.videoLink}');
        Navigator.push( 
          context,
          MaterialPageRoute(
            builder: (context) => 
                VideoDisplayPage( videoUrl: financialHub.videoLink),
          ),
        );
      },
      child: SizedBox(
        width: cardItemWidth,
        height: itemHeight, // Constrain the height of the entire card item
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(bottom: 6.h),
              child: Stack(
                // Stack to overlay play button on image
                alignment: Alignment.center, // To center the play button
                children: [
                  ClipRRect(
                    // Ensure image itself is clipped if Card's clipBehavior isn't enough
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ), // Match Card's shape
                    child: CachedNetworkImage(
                      imageUrl: financialHub.bannerUrl,
                      height: 160.h, // Fixed height for the image part
                      width: double.infinity, // Take full width of the Card
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 150.h, // Match image height
                        width: double.infinity,
                        color: Colors.grey.shade200,
                      ),
                      errorWidget: (context, url, error) => SizedBox(
                        height: 150.h, // Match image height
                        width: double.infinity,
                        child: const Icon(Icons.error, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Play button centered on the image
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.85),
                      radius: 20.r,
                      child: Icon(
                        Icons.play_arrow,
                        size: 20.r,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.w,
              ), // Padding for text content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize
                    .min, // Important for this Column to take minimal vertical space
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          financialHub.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp, // Slightly adjusted for better fit
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h), // Adjusted spacing
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          financialHub.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14.sp, // Slightly adjusted for better fit
                          ), 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
