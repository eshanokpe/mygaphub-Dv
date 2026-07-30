import 'package:GapHub/screens/portfolio/charts/dashbarchart.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'portfolio_row_widget.dart';

class InvestmentPerformanceWidget extends StatefulWidget {
  final List<BarChartGroupData> showingBarGroups;

  const InvestmentPerformanceWidget(this.showingBarGroups, {super.key});

  @override
  State<InvestmentPerformanceWidget> createState() =>
      _InvestmentPerformanceWidgetState();
}

class _InvestmentPerformanceWidgetState
    extends State<InvestmentPerformanceWidget> {
  Map data = {};
  List assetValue = [];
  num bussAssetValue = 0;
  num appreciatingValue = 0;
  num riskValue = 0;

  // State for touched bar
  String? _selectedLabel;
  num? _selectedValue;

  void _handleBarTouch(String? label, num? value) {
    setState(() {
      _selectedLabel = label;
      _selectedValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;

    // Use context.watch to listen for changes in portfolio data
    // and ensure the widget rebuilds when data is available.
    final portfolioData = context.watch<Providers>().portfolio;
    bool dataIsValid = false;

    // Safely extract and assign asset values
    if (portfolioData['data']?["existing_report"]?["values"] != null &&
        portfolioData['data']["existing_report"]["values"] is List) {
      List<dynamic> tempAssetValues =
          portfolioData['data']["existing_report"]["values"];
      if (tempAssetValues.length >= 3) {
        // Assuming the order from your original direct assignment:
        // assetValue[0] for Business, assetValue[2] for Appreciating, assetValue[1] for Risk.
        bussAssetValue = (tempAssetValues[0] is num ? tempAssetValues[0] : 0)
            .round();
        appreciatingValue = (tempAssetValues[2] is num ? tempAssetValues[2] : 0)
            .round();
        riskValue = (tempAssetValues[1] is num ? tempAssetValues[1] : 0)
            .round();
        dataIsValid = true;
        print(
          "InvestmentPerformanceWidget - Parsed assetValues: B:$bussAssetValue, A:$appreciatingValue, R:$riskValue",
        );
      }
    }

    if (!dataIsValid) {
      // If data is not valid or complete, ensure totals default to 0.
      print(
        "InvestmentPerformanceWidget - Portfolio data not valid/complete. Totals will be 0 or stale.",
      );
      bussAssetValue =
          bussAssetValue; // Retain previous value or initial 0 if never set
      appreciatingValue = appreciatingValue;
      riskValue = riskValue;
    }
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xffeeeeee), width: 0.3),
            ),
            // color: AppColors.cardColor,
            child: Container(
              width: width * 05,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(width * .02),
              ),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: DashBarChart(
                      showingBarGroups: widget.showingBarGroups,
                      onBarTouched: _handleBarTouch,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Container(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: AppColors.cardColor,
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Portfolio Value',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Image.asset(
                              'assets/images/portfolio_value.png',
                              height: 22.h,
                              width: 18.w,
                              // fit: B5xFit.contain,
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        PortfolioRowWidget(
                          label: 'Business Asset',
                          value:
                              (_selectedLabel == 'B' && _selectedValue != null)
                              ? _selectedValue!
                              : bussAssetValue,
                          currency: currency,
                          color: const Color(0xff447384),
                        ),
                        SizedBox(height: height * 0.015),
                        PortfolioRowWidget(
                          label: 'Appreciating Asset',
                          value:
                              (_selectedLabel == 'A' && _selectedValue != null)
                              ? _selectedValue!
                              : appreciatingValue,
                          currency: currency,
                          color: const Color(0xffBBC3A4),
                        ),
                        SizedBox(height: height * 0.015),
                        PortfolioRowWidget(
                          label: 'Risk Asset',
                          value:
                              (_selectedLabel == 'R' && _selectedValue != null)
                              ? _selectedValue!
                              : riskValue,
                          currency: currency,
                          color: const Color(0xffFA7070),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
