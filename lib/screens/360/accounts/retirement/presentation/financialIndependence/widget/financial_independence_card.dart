import 'dart:async';
import 'dart:ui' as ui;

import 'package:GapHub/screens/registration/financial_snapshot/widget/zone_item_inverted.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'buildGradientCircularIndicator.dart';
import 'fI_cardPercentage_bottomSheet.dart';
import 'fI_cardTime_bottomSheet.dart';
import 'time_FI_card.dart';

class FinancialIndependenceCard extends StatefulWidget {
  const FinancialIndependenceCard({
    super.key,
    required this.width,
    required this.height,
    required this.yes,
  });

  final double width;
  final bool yes;
  final double height;

  @override
  _FinancialIndependenceCardState createState() =>
      _FinancialIndependenceCardState();
}

class _FinancialIndependenceCardState extends State<FinancialIndependenceCard> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  double? a;
  String? b, c;

  // MARK: - Gradient Color Definitions - BOLD COLORS
  static const List<Color> _redGradient = [
    Color(0xFFFF0001),
    Color(0xFFCE0001),
  ];

  static const List<Color> _amberGradient = [
    Color(0xFFF6AE39),
    Color(0xFFFF7A00),
  ];

  static const List<Color> _greenGradient = [
    Color(0xFF005E32),
    Color(0xFF17B26A),
  ];

  static const List<Color> _blueGradient = [
    Color(0xFF005E77),
    Color(0xFF002E77),
  ];

  // MARK: - Gradient Helper Methods
  List<Color> _getGradientForPercentage(double percentage) {
    if (percentage <= 25) {
      return _redGradient;
    } else if (percentage <= 50) {
      return _amberGradient;
    } else if (percentage <= 75) {
      return _greenGradient;
    } else {
      return _blueGradient;
    }
  }

  List<Color> _getGradientForValue(String value) {
    // Remove commas and parse to double
    final cleanValue = value.replaceAll(',', '');
    final numericValue = double.tryParse(cleanValue) ?? 0;

    return _getGradientForPercentage(numericValue);
  }

  double _readSnapshotNumber(Map snapshot, String key) {
    final value = snapshot[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  String _formatSnapshotValue(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final pensionsdata = providers.pensionsdata;
    final timeFiniancial =
        providers.retiredata['roi_detail']['time_finiancial'];
    final assetValue = providers.retiredata['roi_detail']['asset_require'];
    final monthlyAsset =
        providers.retiredata['improve_status']['monthly_asset'];
    final roceValue = providers.retiredata['improve_status']['roce'];
    final retirementDetail = pensionsdata['retirement_detail'];
    final incomeValue = retirementDetail["sum"];
    final currency = providers.snapshotmodel.currency.toString();

    debugPrint("roceValue: $roceValue");
    debugPrint("monthlyAsset: $monthlyAsset");
    debugPrint("timeFiniancial: $timeFiniancial");
    debugPrint("retirementDetail: $retirementDetail");
    debugPrint("incomeValue: $incomeValue");

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // Get snapshot data
    final snapshot = context.watch<Providers>().snapshotmodel.snapshot;

    final currentValue = _readSnapshotNumber(snapshot, "currentper");
    final time360Value = _readSnapshotNumber(snapshot, "currenttime");
    final timeValue = _readSnapshotNumber(snapshot, "timeper");

    String current = _formatSnapshotValue(currentValue);
    String time360 = _formatSnapshotValue(time360Value);

    // String current = 55.toString();
    // String time360 = 80.toString();

    double currentPer = currentValue / 100;
    double timePer = timeValue / 100;

    // Get gradients based on percentage values - BOLD COLORS
    final timeGradient = _getGradientForValue(time360);
    final percentGradient = _getGradientForValue(current);

    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffEEEEEE), width: 0.7),
          ),
          color: const Color(0xffFBFBFB),
          child: Padding(
            padding: EdgeInsets.only(top: widget.height * .03),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    'Financial Independence is a smarter way to retire and still be buzzing with Life',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,

                      fontSize: 14.sp,
                      color: const Color(0xff525252),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                SizedBox(height: widget.height * .04),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      enableDrag: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(56.0),
                          topRight: Radius.circular(56.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return FICardTimeBottomSheet(
                          title:
                              'How much Time you can sustain yourself before running out of money',
                          time360Value: time360Value,
                          time360: time360,
                          percentGradient: timeGradient,
                          current: current,
                          // ✅ Important: Make sure you pass a decimal here e.g. 75% = 0.75 NOT 75
                          currentPer: currentPer.clamp(0.0, 1.0),
                          currency: currency,
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientCircularIndicator(
                              radius: widget.width * .2,
                              lineWidth: widget.width * 0.05,
                              backgroundColor: Colors.grey.withOpacity(0.25),
                              center: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  time360Value > 1000
                                      ? GradientText(
                                          text: '999+',
                                          gradientColors: timeGradient,
                                          fontSize: 34.sp,
                                          fontWeight: FontWeight.w900,
                                        )
                                      : GradientText(
                                          text: time360,
                                          gradientColors: timeGradient,
                                          fontSize: 36.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  const SizedBox(width: 2),
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: timeGradient,
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ).createShader(bounds);
                                    },
                                    child: SvgPicture.asset(
                                      'assets/icons/hourglass.svg',
                                      width: 24.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              percent: timePer,
                              gradientColors: timeGradient,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Current Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: const Color.fromARGB(
                                      255,
                                      39,
                                      39,
                                      39,
                                    ),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                GradientText(
                                  text: "$time360 days".replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                                  gradientColors: timeGradient,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.03),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Target Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: const Color.fromARGB(
                                      255,
                                      39,
                                      39,
                                      39,
                                    ),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                Text(
                                  "360 days",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                    color: AppColors.blackColor,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: widget.height * .03),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      enableDrag: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(56.0),
                          topRight: Radius.circular(56.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return FICardPercentageBottomSheet(
                          title:
                              'The percentage of your Income covered by income generated from your asset portfolio',
                          currentValue: currentValue,
                          percentGradient: percentGradient,
                          current: current,
                          // ✅ Important: Make sure you pass a decimal here e.g. 75% = 0.75 NOT 75
                          currentPer: currentPer.clamp(0.0, 1.0),
                          currency: currency,
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientCircularIndicator(
                              radius: widget.width * .2,
                              lineWidth: widget.width * 0.05,
                              backgroundColor: Colors.grey.withOpacity(0.25),
                              center: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  currentValue > 1000
                                      ? GradientText(
                                          text: '999+%',
                                          gradientColors: percentGradient,
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w900,
                                        )
                                      : GradientText(
                                          text: '$current%',
                                          gradientColors: percentGradient,
                                          fontSize: 36.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                ],
                              ),
                              percent: currentPer,
                              gradientColors: percentGradient,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Current Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: const Color.fromARGB(
                                      255,
                                      39,
                                      39,
                                      39,
                                    ),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                GradientText(
                                  text: "$current%",
                                  gradientColors: percentGradient,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.03),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Target Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                    color: const Color.fromARGB(
                                      255,
                                      39,
                                      39,
                                      39,
                                    ),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                Text(
                                  "100%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                    color: AppColors.blackColor,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: widget.height * 0.04),
              ],
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
        TimeFICard(
          timeFiniancialValue: timeFiniancial,
          monthlyAsset: monthlyAsset,
          roceValue: roceValue,
          incomeValue: incomeValue,
          assetValue: assetValue,
          currency: currency,
        ),
        SizedBox(height: height * 0.02),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffEEEEEE), width: 0.7),
          ),
          color: const Color(0xFFF7F7F7),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ZoneItemInverted(
                    imagePath: 'assets/icons/red_zone.png',
                    text: 'Red Zone     ',
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                    textStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(56.0),
                            topRight: Radius.circular(56.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const CustomBottomSheet(
                            title: 'Red Zone',
                            content:
                                'This is an undesirable state. It means if you were to lose your job, you have savings to cover you only for a period between 0-90 days. It also means you have an asset portfolio income that is 25% or less of your cost of living.',
                          );
                        },
                      );
                    },
                  ),
                  ZoneItemInverted(
                    imagePath: 'assets/icons/green_infor.png',
                    text: 'Green Zone',
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                    textStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(56.0),
                            topRight: Radius.circular(56.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const CustomBottomSheet(
                            title: 'Green Zone',
                            content:
                                'This is a comfortable state. It means if you were to lose your job, you have savings to cover you for a period between 181-270 days. It also means you have an asset portfolio income that is between 51 - 75% of your cost of living.',
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ZoneItemInverted(
                    imagePath: 'assets/icons/amber_zone_infor.png',
                    text: 'Amber Zone',
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                    textStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(56.0),
                            topRight: Radius.circular(56.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const CustomBottomSheet(
                            title: 'Amber Zone',
                            content:
                                'This is a progressive state. It means if you were to lose your job, you have savings to cover you for a period between 91-180 days. It also means you have an asset portfolio income that is between 26 - 50% of your cost of living.',
                          );
                        },
                      );
                    },
                  ),
                  ZoneItemInverted(
                    imagePath: 'assets/icons/blue_zone_infor.png',
                    text: 'Blue Zone  ',
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 15),
                    textStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(56.0),
                            topRight: Radius.circular(56.0),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const CustomBottomSheet(
                            title: 'Blue Zone',
                            content:
                                'This is a desirable state. It means if you were to lose your job, you have savings to cover you for a period between 271-360 days and possibly beyond. It also means you have an asset portfolio income that is between 76 - 100%+ of your cost of living.',
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
