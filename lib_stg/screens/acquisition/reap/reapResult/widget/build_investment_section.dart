import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';

import '../../widget/investment_infor.dart';

class BuildInvestmentSection extends StatelessWidget {
  final PropertyDetailModel propertyDetail;
  final double height;
  final double width;
  final String currency;

  const BuildInvestmentSection({
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
        Text('Investment Numbers',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: width * .043,
            )),
        SizedBox(height: height * .01),
        Row(
          children: [
            InvestmentInfor(
              title: 'Rental Value',
              subtitle: '$currency${propertyDetail.netRentalIncome}',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Net Rental Value',
              subtitle: '$currency${propertyDetail.netRentalIncome}',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Management Fee',
              subtitle: '$currency${propertyDetail.managementFee}',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Property Tax Fee',
              subtitle: '$currency${propertyDetail.propertyCouncilTax}',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Misc. & Associated Fee',
              subtitle: '$currency${propertyDetail.miscAndOtherFees}',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Gross ROI',
              subtitle: '${propertyDetail.grossRoi}%',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Net ROI',
              subtitle: '${propertyDetail.netRoi}%',
              width: width,
              height: height,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .04),
          child: Divider(
            color: const Color(0xffe2e2e2),
            thickness: 0.8,
            endIndent: width * .60,
          ),
        ),
        SizedBox(height: height * .01),
        Row(
          children: [
            InvestmentInfor(
              title: 'Total Deductions',
              subtitle: '$currency${propertyDetail.totalDeductions}',
              width: width,
              height: height,
            ),
          ],
        ),
        Row(
          children: [
            InvestmentInfor(
              title: 'Monthly Income',
              subtitle: '$currency${propertyDetail.monthlyIncome}',
              width: width,
              height: height,
            ),
          ],
        ),
        const Divider(
          color: Color(0xffe2e2e2),
          thickness: 0.8,
        ),
        SizedBox(height: height * .01),
      ],
    );
  }
}
