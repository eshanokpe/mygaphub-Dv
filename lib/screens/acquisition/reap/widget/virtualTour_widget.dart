import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';

import '../reapResult/viewAll.dart';

class VirtualTourWidget extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double width;
  final double height;

  const VirtualTourWidget({
    super.key,
    required this.propertyDetail,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          "assets/images/acquisition/virtualTour.png",
          height: height * .20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: InkWell(
            onTap: () {
              navigateWithSlideTransition(
                context: context,
                destinationScreen: ViewAll(
                  initialTabIndex: 3,
                  propertyDetail: propertyDetail,
                ),
                transitionDuration: const Duration(milliseconds: 200),
              );
            },
            child: Row(
              children: [
                Text(
                  'View',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: width * .035,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                  size: width * .03,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
