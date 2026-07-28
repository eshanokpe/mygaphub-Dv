import 'package:GapHub/provider/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'portfolio_row_widget.dart';

class PortfolioIncomeWidget extends StatelessWidget {
  const PortfolioIncomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // Use context.watch to listen for changes in the provider
    final data = context.watch<Providers>().portfolio;
    final data1 = data['data']["existing_report"]["incomes"];
    final currency = context.watch<Providers>().snapshotmodel.currency;

    // Ensure data1 is not null and has at least 3 elements
    if (data1 == null || data1.length < 3) {
      return const Center(child: Text('Insufficient data to display chart.'));
    }

    // Convert the data1 values to FlSpot objects
    List<FlSpot> spots = [];
    for (int i = 0; i < data1.length && i < 3; i++) {
      final value = data1[i] as num;
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }

    // Calculate maxY safely
    final maxY = spots.isNotEmpty
        ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Color(0xffeeeeee), width: 1.5),
        ),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            SizedBox(
              height: height * 0.2,
              width: width * 0.7,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 15,
                        getTitlesWidget: (value, meta) {
                          final spot = spots.firstWhere(
                            (spot) => spot.x == value,
                            orElse: () => const FlSpot(double.nan, double.nan),
                          );

                          if (spot.x.isNaN) {
                            return const SizedBox();
                          }
                          final formatter = NumberFormat('#,###');
                          return Text(
                            formatter.format(
                              spot.y.toInt(),
                            ), // Show value at dot points
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xff6E755B),
                      barWidth: 2.5,
                      // isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xff6E755B).withOpacity(0.5),
                            const Color(0xffF8F8F8).withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY,
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            Container(
              color: const Color(0xfff7f7f7),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * .030,
                  vertical: height * .01,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Portfolio Income',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: width * .040,
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
                      value: data1[0].round(),
                      currency: currency,
                      color: const Color(0xff447384),
                    ),
                    SizedBox(height: height * 0.015),
                    PortfolioRowWidget(
                      label: 'Appreciating Asset',
                      value: data1[2].round(),
                      currency: currency,
                      color: const Color(0xffBBC3A4),
                    ),
                    SizedBox(height: height * 0.015),
                    PortfolioRowWidget(
                      label: 'Risk Asset',
                      value: data1[1].round(),
                      currency: currency,
                      color: const Color(0xffFA7070),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
