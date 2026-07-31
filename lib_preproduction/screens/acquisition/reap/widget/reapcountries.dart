import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class Reapcountries extends StatelessWidget {
  final VoidCallback onClick;
  final String imgAsset;
  final String country;
  final String roi;
  final String mincap;
  final String imgAssetFlag;

  const Reapcountries({
    super.key,
    required this.country,
    required this.onClick,
    required this.roi,
    required this.imgAsset,
    required this.mincap,
    required this.imgAssetFlag,
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
          SizedBox(
            height: height * .01,
          ),
          InkWell(
            onTap: onClick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * .04),
              child: Stack(
                children: [
                  SizedBox(
                    height: height * .27,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit
                          .cover, // Or BoxFit.contain depending on the desired behavior
                      child: Image.asset(imgAsset),
                    ),
                  ),
                  Positioned(
                      right: 20,
                      top: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff000000).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: height * .03,
                        padding: EdgeInsets.symmetric(horizontal: width * .02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/infor_white.png',
                              height: height * .02,
                            ),
                            const SizedBox(width: 5),
                            Text('Multiple Cities',
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: width * .040,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                      )),
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
                      Text('REAP $country',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: width * .045,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 5),
                      Image.asset(
                        imgAssetFlag,
                        height: 15,
                      )
                    ],
                  ),
                  Text('Various Vendors',
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
                              fontSize: width * .045,
                              color: AppColors.grayColor,
                              fontWeight: FontWeight.w400)),
                      Text('$roi% ',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: width * .045,
                              fontWeight: FontWeight.w400)),
                      Text('Return',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.grayColor,
                              fontSize: width * .045,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Invest from ',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: width * .040,
                              color: AppColors.grayColor,
                              fontWeight: FontWeight.w400)),
                      Text('\$$mincap',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: width * .040,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: height * .03,
          ),
          CustomButton(
            borderColor: Colors.white,
            text: 'Visit ',
            fontSize: width * .035,
            borderRadius: 8,
            onPressed: onClick,
            icon: Icons.arrow_forward_ios,
            color: AppColors.primaryColor,
            textColor: Colors.white,
          ),
          SizedBox(
            height: height * .03,
          ),
          const Divider(
            height: 10,
            thickness: 1.0,
            color: Color(0xffe2e2e2),
          )
        ],
      ),
    );
  }
}
