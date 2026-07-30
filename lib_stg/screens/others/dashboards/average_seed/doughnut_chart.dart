import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutChart extends StatelessWidget {
  final List<int> values;
  final List<String> hexColors;
  final List<String> labels;

  const DoughnutChart({
    required this.values,
    required this.hexColors,
    required this.labels,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Validate input
    assert(values.length == hexColors.length);
    assert(values.length == labels.length,
        'Values, hexColors, and labels must have the same length.');

    final total = values.fold(0, (sum, item) => sum + item);

    // Create chart data - even if total is 0, we still create data with 0 values
    List<ChartData> chartData = List.generate(values.length, (index) {
      double percentage = total == 0 ? 0 : (values[index] / total) * 100.0;
      return ChartData(
        labels[index],
        values[index],
        Color(int.parse(hexColors[index])),
        percentage,
      );
    });

    return Center(
      child: SizedBox(
        height: 270.h, 
        child: SfCircularChart(
          series: <CircularSeries<ChartData, String>>[
            DoughnutSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                // Set to none to prevent any label hiding
                labelIntersectAction: LabelIntersectAction.none,
                labelAlignment: ChartDataLabelAlignment.outer,
                labelPosition: ChartDataLabelPosition.outside,
                // Use shorter connector lines to prevent overlap
                connectorLineSettings: const ConnectorLineSettings(
                  type: ConnectorType.line,
                  length: '10%',
                  color: Color(0xff777777),
                ),
                // Use builder to display percentage with the label
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      '${data.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              // Ensure all data points have labels
              enableTooltip: true,
              radius: '80%',
            ),
          ],
          // Disable tooltip to avoid interference
          tooltipBehavior: TooltipBehavior(enable: false),
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