import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';

import '../../widget/factFeatures_infor.dart';

class BuildFactFeaturesSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildFactFeaturesSection({
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
        Text('Fact & Features',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .045,
            )),
        SizedBox(height: height * .01),
        FactFeaturesInfor(
            propertyDetail: propertyDetail, width: width, height: height),
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
