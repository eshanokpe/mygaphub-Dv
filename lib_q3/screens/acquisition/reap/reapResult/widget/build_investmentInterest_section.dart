import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/screens/acquisition/reap/widget/customPhoneNumberField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildInvestmentInterestSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildInvestmentInterestSection({
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
        Text('Investment Interest Area',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            )),
        SizedBox(height: height * .01),
        Text('Mobile Number',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            )),
        SizedBox(height: height * .01),
        CustomPhoneNumberField(propertyDetail: propertyDetail),
        SizedBox(height: height * .02),
        // Text('Related Assets',
        //     style: TextStyle(
        //       fontFamily: 'Nunito',
        //       fontWeight: FontWeight.w700,
        //       fontSize: 14.sp,
        //     )),
      ],
    );
  }
}
