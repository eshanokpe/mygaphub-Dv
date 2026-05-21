import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashBarChart extends StatelessWidget {
  final List<BarChartGroupData> showingBarGroups;
  final Function(String? label, num? value)? onBarTouched;

  const DashBarChart({
    super.key,
    required this.showingBarGroups,
    this.onBarTouched,
  });

  static const List<String> _labels = ['B', 'A', 'R'];

  static const List<List<Color>> _gradientColors = [
    [Color(0xFF105068), Color(0xFF477282)],
    [Color(0xFFA4B083), Color(0xFFBBC3A4)],
    [Color(0xFFE84141), Color(0xFFFA7070)],
  ];

  @override
  Widget build(BuildContext context) {
    // context.watch — reacts when portfolio data arrives
    final Map portfolioData = context.watch<Providers>().portfolio;

    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final values = portfolioData['data']?['existing_report']?['values'];
    final bool hasValues = values is List && values.length >= 3;

    // Show placeholder until data is ready
    if (!hasValues) {
      return SizedBox(
        height: height * 0.2,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final existing = [
      ValueChart('B', (values[0] is num ? values[0] : 0).round()),
      ValueChart('A', (values[2] is num ? values[2] : 0).round()),
      ValueChart('R', (values[1] is num ? values[1] : 0).round()),
    ];

    final double barWidth = width * 0.30;

    List<BarChartGroupData> barGroups = existing.asMap().entries.map((entry) {
      final index      = entry.key;
      final valueChart = entry.value;
      final colors     = _gradientColors[index];
      final barHeight  = valueChart.value > 0 ? valueChart.value.toDouble() : 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barHeight,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft:  Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: height * 0.2,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData:   const FlGridData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = _labels[group.x.toInt()];
                return BarTooltipItem(
                  '$label\n',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                  children: [
                    TextSpan(
                      text: rod.toY.round().toString(),
                      style: TextStyle(color: Colors.yellow, fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              if (onBarTouched == null) return;
              if (event is FlTapUpEvent) {
                if (response?.spot != null) {
                  final groupIndex = response!.spot!.touchedBarGroupIndex;
                  if (groupIndex >= 0 && groupIndex < _labels.length) {
                    onBarTouched!(_labels[groupIndex], response.spot!.touchedRodData.toY);
                  }
                } else {
                  onBarTouched!(null, null);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class ValueChart {
  final String type;
  final int    value;
  ValueChart(this.type, this.value);
}