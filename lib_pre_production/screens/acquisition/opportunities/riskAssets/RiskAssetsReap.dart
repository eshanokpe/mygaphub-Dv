import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'aITradedForex.dart';
import 'deFiMasteryTrading.dart';
import 'widget/riskAssetSearch.dart';
import 'widget/riskAssetsCard.dart';

class RiskAssetsReap extends StatefulWidget {
  const RiskAssetsReap({super.key});

  @override
  _RiskAssetsReapState createState() => _RiskAssetsReapState();
}

class _RiskAssetsReapState extends State<RiskAssetsReap> {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  bool filterToggle = true;
  String item1 = 'Zip Code';
  String item2 = 'Bed';
  String item3 = 'Bath';
  TextEditingController city = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController priceFrom = TextEditingController();
  TextEditingController priceTo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Fixed header section
            Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  ),
                  actions: const [AvatarImage()],
                ),
                const RiskAssetsSearch(),
                SizedBox(height: height * .01),
              ],
            ),

            // Scrollable content section
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height * .01),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: width * .035),
                        child: Visibility(
                          visible: !filterToggle,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      keyboardType: TextInputType.name,
                                      style: TextStyle(fontSize: width * .035),
                                      controller: city,
                                      decoration: InputDecoration(
                                        hintText: 'City',
                                        contentPadding: EdgeInsets.all(
                                          width * .03,
                                        ),
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            width * .02,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * .01),
                                  Expanded(
                                    child: TextField(
                                      style: TextStyle(fontSize: width * .035),
                                      controller: country,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        hintText: 'Country',
                                        contentPadding: EdgeInsets.all(
                                          width * .03,
                                        ),
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            width * .02,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * .01),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      style: TextStyle(fontSize: width * .035),
                                      controller: priceFrom,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Price From (\$)',
                                        contentPadding: EdgeInsets.all(
                                          width * .03,
                                        ),
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            width * .02,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * .01),
                                  Expanded(
                                    child: TextField(
                                      style: TextStyle(fontSize: width * .035),
                                      controller: priceTo,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Price To (\$)',
                                        contentPadding: EdgeInsets.all(
                                          width * .03,
                                        ),
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            width * .02,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      RiskAssetsCard(
                        title: 'AI Traded Forex Account',
                        platform: 'Vantage Platform',
                        onClick: () {},
                        imgAsset: 'assets/images/acquisition/tradedForex.png',
                        roi: '60',
                        mincap: '5,000',
                      ),
                      CustomButton(
                        borderColor: Colors.white,
                        text: 'Visit',
                        fontSize: 16.sp,
                        borderRadius: 8,
                        onPressed: () {
                          navigateWithSlideTransition(
                            context: context,
                            destinationScreen: const AITradedForex(),
                            transitionDuration: const Duration(
                              milliseconds: 200,
                            ),
                          );
                        },
                        icon: Icons.arrow_forward_ios,
                        color: AppColors.primaryColor,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: height * .03),
                      const Divider(
                        height: 10,
                        thickness: 1.0,
                        color: Color(0xffe2e2e2),
                      ),
                      SizedBox(height: height * .01),
                      RiskAssetsCard(
                        title: 'DeFi Mastery Training',
                        platform: 'FIT Platform',
                        onClick: () {},
                        imgAsset: 'assets/images/acquisition/deFi.png',
                        roi: '20',
                        mincap: '500',
                      ),
                      CustomButton(
                        borderColor: Colors.white,
                        text: 'Visit',
                        fontSize: 16.sp,
                        borderRadius: 8,
                        onPressed: () {
                          navigateWithSlideTransition(
                            context: context,
                            destinationScreen: const DeFiMasteryTrading(),
                            transitionDuration: const Duration(
                              milliseconds: 200,
                            ),
                          );
                        },
                        icon: Icons.arrow_forward_ios,
                        color: AppColors.primaryColor,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: height * .03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNav(2),
      ),
    );
  }
}
