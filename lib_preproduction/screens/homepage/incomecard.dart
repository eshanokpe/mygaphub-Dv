import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';

class Incomecard extends StatefulWidget {
  const Incomecard({super.key});

  @override
  _IncomecardState createState() => _IncomecardState();
}

class _IncomecardState extends State<Incomecard> {
  DialogBox dialogBox = DialogBox();
 
  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    return Container(
      height: 110.h,
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardColor2, width: 2),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/gaphub_bg_dashboard.png',
          ), // Replace with your image path
          fit: BoxFit.cover, // Cover the entire container
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 32.w),
          Text(
            '$currency${context.watch<Providers>().currentPortfolio.toStringAsFixed(2)}'
                .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
            style: TextStyle(
              fontFamily: 'NunitoSans',
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blackColor, // Text color
            ),
          ),
        ],
      ),
    );
  }
}
