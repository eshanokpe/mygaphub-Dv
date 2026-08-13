import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutChart extends StatelessWidget {
  final List<int> values;
  final List<Color> hexColors;
  final List<String> labels;

  DoughnutChart({
    super.key,
    required this.values,
    required List<String> hexColors, // List of hexadecimal color strings
    required this.labels,
  }) : hexColors = hexColors.map((color) => Color(int.parse(color))).toList();

  @override
  Widget build(BuildContext context) {
    int total = values.fold(0, (sum, value) => sum + value);

    List<ChartData> chartData = List.generate(values.length, (index) {
      double percentage = (values[index] / total) * 100.0;
      return ChartData(
        labels[index],
        values[index],
        hexColors[index],
        percentage,
      );
    });

    return Center(
      child: SizedBox(
        height: 14.h,
        // width: MediaQuery.of(context).size.width * 0.5,
        child: SfCircularChart(
          series: <CircularSeries>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.line,
                  length: '30%',
                  color: Color(0xff777777),
                ),
              ),
              dataLabelMapper: (ChartData data, _) =>
                  '${data.percentage.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;
  final double percentage;

  ChartData(this.x, this.y, this.color, this.percentage);
}
