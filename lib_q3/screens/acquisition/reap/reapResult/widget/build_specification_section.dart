import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';

import '../../widget/specification_infor.dart';

class BuildSpecificationSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildSpecificationSection({
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
        Text('Specification',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .043,
            )),
        SizedBox(height: height * .02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpecificationInfo(
              iconPath: "assets/icons/house_icon.png",
              propertyType: "Property Type",
              propertyName: "Semi-Duplex",
              width: width,
              height: height,
            ),
            SpecificationInfo(
              iconPath: "assets/icons/square_red.png",
              propertyType: "Square Footage",
              propertyName: propertyDetail.propertyArea,
              width: width,
              height: height,
            ),
          ],
        ),
        SizedBox(height: height * .02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpecificationInfo(
              iconPath: "assets/icons/bathroom_icon.png",
              propertyType: "Bathrooms",
              propertyName: propertyDetail.noOfBathroom.toString(),
              width: width,
              height: height,
            ),
            SpecificationInfo(
              iconPath: "assets/icons/bedroom_red.png",
              propertyType: "Bedrooms          ",
              propertyName: propertyDetail.noOfBedroom.toString(),
              width: width,
              height: height,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .04),
          child: const Divider(
            color: Color(0xffe2e2e2),
            thickness: 0.8,
          ),
        ),
        SizedBox(height: height * .01),
      ],
    );
  }
}
