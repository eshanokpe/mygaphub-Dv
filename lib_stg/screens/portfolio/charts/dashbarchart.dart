import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashBarChart extends StatefulWidget {
  final List<BarChartGroupData> showingBarGroups;
  final Function(String? label, num? value)? onBarTouched;
  const DashBarChart({
    super.key,
    required this.showingBarGroups,
    this.onBarTouched,
  });
  @override
  State<DashBarChart> createState() => _DashBarChartState();
}

class _DashBarChartState extends State<DashBarChart> {
  Map data = {};

  @override
  void initState() {
    super.initState();
    try {
      data = context.read<Providers>().portfolio;
      // Basic check if data is usable
      if (data['data']?["existing_report"]?["values"] == null ||
          data['data']["existing_report"]["values"] is! List ||
          data['data']["existing_report"]["values"].length < 3) {
        print(
            "DashBarChart: Invalid or incomplete data structure in portfolio provider.");
        // Handle this case, maybe show an error message or an empty chart
        data = {}; // Reset data to prevent errors later
      }
    } catch (e) {
      print("Error fetching portfolio data in DashBarChart initState: $e");
      // Handle error state
      data = {};
    }
  }

  // 1. Define the new label order
  static const List<String> _labels = ['B', 'A', 'R'];

  // 3. Reorder gradient colors to match the new label order: B, A, R
  static const List<List<Color>> _gradientColors = [
    [Color(0xFF105068), Color(0xFF477282)], // Colors for 'B' (original index 0)
    [Color(0xFFA4B083), Color(0xFFBBC3A4)], // Colors for 'A' (original index 2)
    [Color(0xFFE84141), Color(0xFFFA7070)], // Colors for 'R' (original index 1)
  ];

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // Defensive check in case initState failed
    if (data.isEmpty || data['data']?["existing_report"]?["values"] == null) {
      return Container(
        height: height * 0.2,
        alignment: Alignment.center,
        child: const Text(
            "Chart data unavailable"), // Or a loading indicator/placeholder
      );
    }

    var dataValues = data['data']["existing_report"]["values"];
    print(
        "Original dataValues: $dataValues"); // Should be [valueB, valueR, valueA]

    final existing = List.generate(_labels.length, (index) {
      String currentLabel = _labels[index];
      num value;
      if (currentLabel == 'B') {
        value = (dataValues[0] is num) ? dataValues[0] : 0;
      } else if (currentLabel == 'A') {
        value = (dataValues[2] is num) ? dataValues[2] : 0;
      } else {
        // currentLabel == 'R'
        value = (dataValues[1] is num) ? dataValues[1] : 0;
      }
      return ValueChart(currentLabel, value.round());
    });

    print(
        "Processed existing values (B, A, R order): ${existing.map((e) => '${e.type}:${e.value}').toList()}");

    return Container(
      height: height * 0.2,
      // width: width, // Container takes full width by default if parent allows
      alignment: Alignment.center,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          barGroups: generateBarGroups(existing),
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
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  // Use the reordered _labels list here
                  if (index >= 0 && index < _labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _labels[index], // Uses the new ['B', 'A', 'R'] order
                        style: TextStyle(
                            fontSize: width *
                                .035, // Slightly increased for readability
                            fontWeight: FontWeight.w500,
                            color: Colors.black54),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(
            enabled: false, // Ensure touch is enabled
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Use the reordered _labels list for tooltips too
                String label = _labels[group.x.toInt()];
                return BarTooltipItem(
                  '$label\n',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: rod.toY.round().toString(),
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
              if (widget.onBarTouched == null) {
                return;
              }
              if (event is FlTapUpEvent && response?.spot != null) {
                final groupIndex = response!.spot!.touchedBarGroupIndex;
                if (groupIndex >= 0 && groupIndex < _labels.length) {
                  final label = _labels[groupIndex];
                  final value = response.spot!.touchedRodData.toY;
                  widget.onBarTouched!(label, value);
                }
              } else if (event is FlTapUpEvent && response?.spot == null) {
                // Tapped on background, reset selection
                widget.onBarTouched!(null, null);
              }
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> generateBarGroups(List<ValueChart> existing) {
    final width = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final double barWidth = width * 0.30; // Adjusted width slightly

    return existing.asMap().entries.map((entry) {
      int index = entry.key;
      ValueChart valueChart = entry.value;

      // Ensure index is within bounds for the reordered colors
      List<Color> gradientColors =
          (index >= 0 && index < _gradientColors.length)
              ? _gradientColors[index]
              : [Colors.grey, Colors.grey];

      // Ensure value is not negative for bar height
      double barHeight =
          valueChart.value > 0 ? valueChart.value.toDouble() : 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barHeight,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: barWidth, // Use calculated barWidth
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ],
      );
    }).toList();
  }
}

// Keep this simple data class
class ValueChart {
  final String type;
  final int value;

  ValueChart(this.type, this.value);
}
