import 'dart:math' as math;
import 'package:GapHub/provider/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FinancialTimeChart extends StatefulWidget {
  const FinancialTimeChart({super.key});

  @override
  State<FinancialTimeChart> createState() => _FinancialTimeChartState();
}

class _FinancialTimeChartState extends State<FinancialTimeChart> {
  bool _showSecondChart = false;

  @override
  Widget build(BuildContext context) {
    final providers = context.watch<Providers>();
    final snapshotModel = providers.snapshotmodel;
    final retireData = providers.retiredata;

    final currency = snapshotModel.currency.toString();
    final now = DateTime.now();

    final timeChartValue = retireData['roi_detail']['time_finiancial_chart'];
    final timeFinancialValue = retireData['roi_detail']['time_finiancial'];
    final averageExpenditure =
        retireData['improve_status']['average_expenditure'] ?? 0.0;

    final timeValue = timeFinancialValue;
    final timeAsInt = timeValue.round();
    final chartYears = _parseDouble(timeChartValue);
    final investmentTarget = _parseDouble(averageExpenditure);

    final maxX = chartYears <= 0 ? 1.0 : chartYears;
    final maxY = _calculateChartMaxY(investmentTarget);
    final double xInterval = maxX <= 4 ? 1 : (maxX / 3).ceilToDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xffEEEEEE), width: 0.7),
      ),
      color: const Color(0xffFBFBFB),
      child: Container(
        height: 280.h,
        width: double.infinity,
        // ✅ ONLY change: guaranteed equal fixed padding, no scaling
        padding: EdgeInsets.symmetric(
          horizontal: 12.w, // Exact equal left/right
          vertical: 30, // Exact fixed top/bottom
        ),
        child: Stack(
          children: [
            /// Chart axes and grid only
            LineChart(
              LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                clipData: const FlClipData.all(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: _calculateOptimalYInterval(maxY),
                  getDrawingVerticalLine: (value) {
                    if (value == 0 || value == maxX) {
                      return const FlLine(
                        color: Color(0xff37434d),
                        strokeWidth: 0.5,
                      );
                    }
                    return const FlLine(
                      color: Colors.transparent,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0xff37434d), strokeWidth: 0.05),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: maxY,
                      color: const Color(0xff37434d),
                      strokeWidth: 0.08,
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: _calculateOptimalYInterval(maxY),
                      getTitlesWidget: (value, meta) {
                        if (maxY <= 1.0) {
                          final List<double> yValues = [
                            0,
                            0.1,
                            0.2,
                            0.4,
                            0.6,
                            0.8,
                            1.0,
                          ];
                          if (yValues.contains(
                                (value * 10).roundToDouble() / 10,
                              ) ||
                              yValues.contains(value.roundToDouble())) {
                            if (value == 0) {
                              return Padding(
                                padding: EdgeInsets.only(right: 25.w),
                                child: Text(
                                  '0',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Text(
                                "$currency${value.toStringAsFixed(1)}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        if (value == 0) {
                          return Padding(
                            padding: EdgeInsets.only(right: 25.w),
                            child: Text(
                              '0',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        final displayText = _formatValueLabel(value);
                        return Text(
                          '$currency$displayText',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  // ✅ REVERTED: bottomTitles exactly as your original code
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: xInterval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return Padding(
                            padding: EdgeInsets.only(left: 40.w, top: 10.h),
                            child: Text(
                              '${now.year}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        if ((value - maxX).abs() < 0.01) {
                          return Padding(
                            padding: EdgeInsets.only(right: 40.w, top: 10.h),
                            child: Text(
                              '${now.year + timeAsInt}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 0)],
                    color: Colors.transparent,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                minY: 0,
                maxY: maxY,
                minX: 0,
                maxX: maxX,
              ),
            ),

            /// ✅ REVERTED: Overlay chart exactly as your original positioning
            Positioned(
              left: 35,
              right: 0,
              top: 0,
              bottom: 20,
              child: GestureDetector(
                onTap: _toggleChartView,
                child: Image.asset(
                  _showSecondChart
                      ? 'assets/images/community/chart_data2.png'
                      : 'assets/images/community/chart_data.png',
                  fit: BoxFit.fill,
                  width: 30.w,
                ),
              ),
            ),

            /// Time period label
            if (_showSecondChart)
              Positioned(
                left: timeAsInt == 0 || timeAsInt == 1 ? 230 : 220,
                right: 0,
                top: 170,
                bottom: 0,
                child: Text(
                  '$timeAsInt ${timeAsInt == 0 || timeAsInt == 1 ? 'Year' : 'Years'}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: const Color(0xff477282),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleChartView() {
    setState(() => _showSecondChart = !_showSecondChart);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showSecondChart) {
        setState(() => _showSecondChart = false);
      }
    });
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double _calculateChartMaxY(double targetValue) {
    if (targetValue <= 0) return 1.0;

    final paddedTarget = targetValue * 1.1;
    final magnitude = math
        .pow(10, (math.log(paddedTarget) / math.ln10).floor())
        .toDouble();
    final normalized = paddedTarget / magnitude;

    final niceNormalized = switch (normalized) {
      <= 1 => 1,
      <= 1.2 => 1.2,
      <= 1.5 => 1.5,
      <= 2 => 2,
      <= 2.5 => 2.5,
      <= 3 => 3,
      <= 4 => 4,
      <= 5 => 5,
      <= 6 => 6,
      <= 8 => 8,
      _ => 10,
    };

    return niceNormalized * magnitude;
  }

  double _calculateOptimalYInterval(double maxValue) {
    if (maxValue <= 1.0) {
      return 0.1;
    }
    return switch (maxValue) {
      <= 5 => 1,
      <= 10 => 2,
      <= 20 => 5,
      <= 50 => 10,
      _ => maxValue / 5,
    };
  }

  String _formatValueLabel(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).round()}M';
    }
    if (value >= 10000) {
      return '${(value / 1000).round()}k';
    }
    return value.round().toString();
  }
}
