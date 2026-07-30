import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/colors.dart';
import 'floorPlanView.dart';

class BuildNeighbourhoodSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildNeighbourhoodSection({
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
        Text('Neighbourhood Highlights',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .045,
            )),
        SizedBox(height: height * .01),
        Text(propertyDetail.neighbourhoodHighlights,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: width * .040,
            )),
        SizedBox(height: height * .01),
        const Divider(
          color: Color(0xffe2e2e2),
          thickness: 0.8,
        ),
        SizedBox(height: height * .01),
        Text('Tours & Floor Plan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .045,
            )),
        Text('Floor Plan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: width * .045,
            )),
        SizedBox(height: height * .01),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: 8.0, // Space between images
              runSpacing: 8.0, // Space between rows
              children: propertyDetail.floorPlanImages.map((feature) {
                return CachedNetworkImage(
                  imageUrl: feature.url,
                  height: height * .18,
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              }).toList(),
            ),
            InkWell(
              onTap: () {
                navigateWithSlideTransition(
                  context: context,
                  destinationScreen: FloorPlanView(
                    floorPlanImages: propertyDetail,
                  ),
                  transitionDuration: const Duration(milliseconds: 200),
                );
              },
              child: Row(
                children: [
                  Text('View',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: width * .035,
                      )),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryColor,
                    size: width * .03,
                  ),
                ],
              ),
            ),
            SizedBox(width: width * .01),
          ],
        ),
        SizedBox(height: height * .01),
        const Divider(
          color: Color(0xffe2e2e2),
          thickness: 0.8,
        ),
        SizedBox(height: height * .01),
      ],
    );
  }
}
