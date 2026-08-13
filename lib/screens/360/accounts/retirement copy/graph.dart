// import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample1 extends StatefulWidget {
  final Map data;
  final String currency;
  const LineChartSample1(this.data, this.currency, {super.key});
  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  double? current;
  double? needed;
  @override
  void initState() {
    super.initState();
    current = double.parse(
      widget.data["improve_status"]["portfolio"].toString(),
    );
    needed = double.parse(
      widget.data["improve_status"]["monthly_asset"].toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currency = widget.currency;

    var listofLabels = [];
    // var top = needed + 100;
    var dividend = needed! / 10;
    for (var i = 1; i < 12; i++) {
      listofLabels.add(dividend.round() * i);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            color: Colors.white,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: const LineTouchData(enabled: false),
                          gridData: FlGridData(
                            show: true,
                            // drawVerticalLine: true,
                            drawHorizontalLine: true,

                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                color: Color(0xff37434d),
                                strokeWidth: .5,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  TextStyle style = const TextStyle(
                                    color: Color(0xff72719b),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 1:
                                      text = Text('Today', style: style);
                                      break;
                                    case 7:
                                      text = Text(
                                        'Year ${widget.data["roi_detail"]["time_finiancial"].round()}',
                                        style: style,
                                      );
                                      break;
                                    default:
                                      text = const Text('');
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                getTitlesWidget: (value, meta) {
                                  TextStyle style = const TextStyle(
                                    color: Color(0xff75729e),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 7,
                                  );
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < listofLabels.length) {
                                    String formattedValue =
                                        listofLabels[value.toInt()]
                                            .replaceAllMapped(
                                              RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                              ),
                                              (Match m) => '${m[1]},',
                                            );
                                    return Container();
                                  }
                                  return Container();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(
                                color: Color(0xff37434d),
                                width: .5,
                              ),
                              left: BorderSide(color: Colors.transparent),
                              right: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          minX: 0,
                          maxX: 8,
                          maxY: 11,
                          minY: 0,
                          lineBarsData: linesBarData2(needed),
                        ),
                        duration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 2,
                        width: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("Financial Independence Journey"),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> linesBarData2(top) {
    var diff = (needed! - current!) / 6;

    double x1 = current! / top * 10;
    double x2 = (current! + (diff * 1)) / top * 10;
    double x3 = (current! + (diff * 2)) / top * 10;
    double x4 = (current! + (diff * 3)) / top * 10;
    double x5 = (current! + (diff * 4)) / top * 10;
    double x6 = (current! + (diff * 5)) / top * 10;
    double x7 = needed! / top * 10;

    return [
      LineChartBarData(
        spots: [
          FlSpot(1, x1),
          FlSpot(2, x2),
          FlSpot(3, x3),
          FlSpot(4, x4),
          FlSpot(5, x5),
          FlSpot(6, x6),
          FlSpot(7, x7),
        ],
        isCurved: true,
        curveSmoothness: 0,
        color: const Color(0xff000000),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }
}
