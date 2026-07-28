import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class FloorPlanWidget extends StatefulWidget {
  final PropertyDetailModel propertyDetail;
  const FloorPlanWidget({super.key, required this.propertyDetail});

  @override
  _FloorPlanWidgetState createState() => _FloorPlanWidgetState();
}

class _FloorPlanWidgetState extends State<FloorPlanWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.20,
        height: MediaQuery.of(context).size.height * 0.06,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            if (widget.propertyDetail.floorPlanImages != null ||
                widget.propertyDetail.floorPlanImages.isNotEmpty)
              Column(
                children: [
                  if (widget
                      .propertyDetail
                      .floorPlanImages
                      .isNotEmpty) // Check if there are images
                    CachedNetworkImage(
                      imageUrl: widget.propertyDetail.floorPlanImages[0].url,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .06,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width:
                              30.0, // Adjust the size of the CircularProgressIndicator
                          height: 30.0,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                ],
              )
            else if (widget.propertyDetail.floorPlanImages != null ||
                widget.propertyDetail.floorPlanImages.isEmpty)
              CachedNetworkImage(
                imageUrl: widget.propertyDetail.propertyFeaturedImage,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .06,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            else
              const Center(child: CircularProgressIndicator()),

            // Overlay with virtual tour icon and count
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.23,
                height: MediaQuery.of(context).size.height * 0.12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // Display virtual tour icon and link length
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/acquisition/floorPlanIcon.png',
                      height: 30,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "1",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
