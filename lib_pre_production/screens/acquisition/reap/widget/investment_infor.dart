import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';

class InvestmentInfor extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;
  final double height;

  const InvestmentInfor({
    super.key,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            color: AppColors.grayColor,
            fontWeight: FontWeight.w600,
            fontSize: width * .043,
          ),
        ),
        subtitle: Text(
          subtitle.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          ),
          style: TextStyle(
            fontFamily: 'Nunito',
            color: const Color(0xff272727),
            fontWeight: FontWeight.w600,
            fontSize: width * .043,
          ),
        ),
      ),
    );
  }
}
