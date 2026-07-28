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
  String? _selectedLabel;
  num?    _selectedValue;

  void _handleBarTouch(String? label, num? value) {
    setState(() {
      _selectedLabel = label;
      _selectedValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currency      = context.watch<Providers>().snapshotmodel.currency;
    final Map    portfolioData = context.watch<Providers>().portfolio;

    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // Safely extract values — default to 0 if not ready
    final values = portfolioData['data']?['existing_report']?['values'];
    final bool hasValues = values is List && values.length >= 3;

    final num bussAssetValue    = hasValues ? (values[0] is num ? values[0] : 0) : 0;
    final num riskValue         = hasValues ? (values[1] is num ? values[1] : 0) : 0;
    final num appreciatingValue = hasValues ? (values[2] is num ? values[2] : 0) : 0;

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
            child: Container(
              width: width,
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
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        PortfolioRowWidget(
                          label: 'Business Asset',
                          value: (_selectedLabel == 'B' && _selectedValue != null)
                              ? _selectedValue!
                              : bussAssetValue,
                          currency: currency,
                          color: const Color(0xff447384),
                        ),
                        SizedBox(height: height * 0.015),
                        PortfolioRowWidget(
                          label: 'Appreciating Asset',
                          value: (_selectedLabel == 'A' && _selectedValue != null)
                              ? _selectedValue!
                              : appreciatingValue,
                          currency: currency,
                          color: const Color(0xffBBC3A4),
                        ),
                        SizedBox(height: height * 0.015),
                        PortfolioRowWidget(
                          label: 'Risk Asset',
                          value: (_selectedLabel == 'R' && _selectedValue != null)
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