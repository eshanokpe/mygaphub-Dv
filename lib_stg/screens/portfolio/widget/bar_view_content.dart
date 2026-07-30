import 'package:GapHub/screens/portfolio/charts/dashpiechart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BarViewContent extends StatelessWidget {
  List dataList;
  BarViewContent({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    Orientation orientation = MediaQuery.of(context).orientation;
    final double chartHeight = isTablet
        ? (orientation == Orientation.portrait ? 400 : 300)
        : (orientation == Orientation.portrait ? 300 : 250);

    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        // height: height,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [DashPiechartPort(dataList)],
        ),
      ),
    );
  }
}

class PercentageChart extends StatelessWidget {
  const PercentageChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Risk', 20, const Color(0xFFFF5733)), // Orange-red
      ChartData('Business', 40, const Color(0xFF3385FF)), // Blue
      ChartData('Appreciating', 40, const Color(0xFF33FF57)), // Green
    ];

    return SizedBox(
      height: 300,
      child: SfCircularChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          DoughnutSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.value,
            pointColorMapper: (ChartData data, _) => data.color,
            radius: '70%',
            innerRadius: '60%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelIntersectAction: LabelIntersectAction.none,
              labelAlignment: ChartDataLabelAlignment.outer,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              connectorLineSettings: ConnectorLineSettings(
                length: '20%',
                width: 2,
              ),
            ),
          ),
        ],
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Container(
              child: const Text(
                'Asset Allocation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
