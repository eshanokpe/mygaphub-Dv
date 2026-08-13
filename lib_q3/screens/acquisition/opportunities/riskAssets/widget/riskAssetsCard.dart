import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiskAssetsCard extends StatelessWidget {
  final VoidCallback onClick;
  final String imgAsset;
  final String title;
  final String platform;
  final String roi;
  final String mincap;

  const RiskAssetsCard({
    super.key,
    required this.title,
    required this.platform,
    required this.onClick,
    required this.roi,
    required this.imgAsset,
    required this.mincap,
  });
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SizedBox(
      // height: height * .44,
      width: width * .9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: onClick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * .04),
              child: Stack(
                children: [
                  Image.asset(
                    imgAsset,
                    height: height * .27,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * .01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: width * .045,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(platform,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: width * .045,
                          color: const Color(0xff808080),
                          fontWeight: FontWeight.w400)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text('Up to ',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16.sp,
                              color: AppColors.grayColor,
                              fontWeight: FontWeight.w400)),
                      Text('$roi% ',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600)),
                      Text('Return',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.grayColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Invest from ',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16.sp,
                              color: AppColors.grayColor,
                              fontWeight: FontWeight.w400)),
                      Text('£$mincap',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: height * .02,
          ),
        ],
      ),
    );
  }
}
