import 'package:GapHub/provider/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Dashlinechart extends StatefulWidget {
  const Dashlinechart({super.key});

  @override
  _DashlinechartState createState() => _DashlinechartState();
}

class _DashlinechartState extends State<Dashlinechart> {
  int existNum = 0;
  List data1 = [];
  List data2 = [];
  Map data = {};
  int desiredNum = 0;

  int chosenOne = 0;

  List numbers = [
    10,
    50,
    100,
    200,
    500,
    1000,
    5000,
    10000,
    25000,
    50000,
    100000,
    250000,
    500000,
    1000000,
    10000000,
    50000000,
    100000000,
  ];
  int existNumber() {
    for (var i = 0; i < numbers.length; i++) {
      if (existNum < numbers[i]) {
        return numbers[i];
      }
    }
    return existNum;
  }

  int desiredNumber() {
    for (var i = 0; i < numbers.length; i++) {
      if (desiredNum < numbers[i]) {
        return numbers[i];
      }
    }
    return desiredNum;
  }

  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().portfolio;

    data1 = data["existing_report"]["incomes"];
    data2 = data["desired_report"]["incomes"];
    if (data1.isNotEmpty) {
      existNum = data1
          .reduce((curr, next) => curr > next ? curr : next)
          .round();
    }
    if (data2.isNotEmpty) {
      desiredNum = data2
          .reduce((curr, next) => curr > next ? curr : next)
          .round();
    }
    desiredNumber();
    existNumber();
    chosenOne = [
      desiredNumber(),
      existNumber(),
    ].reduce((curr, next) => curr > next ? curr : next).round();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AspectRatio(
      aspectRatio: 1.13,
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.only(left: width * .02),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.white,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 37),
                  Text(
                    'Portfolio Income',
                    style: TextStyle(
                      color: const Color(0xff77839a),
                      fontSize: width * .05,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * .02),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                      child: LineChart(
                        sampleData(width, height, context),
                        duration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                  SizedBox(height: height * .01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: width * .01,
                            width: width * .03,
                            decoration: const BoxDecoration(
                              color: Color(0xff8C8D86),
                            ),
                          ),
                          SizedBox(width: width * .03),
                          const Text("Investment"),
                        ],
                      ),
                      // SizedBox(
                      //   width: width * .05,
                      // ),
                      // Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Container(
                      //       height: width * .01,
                      //       width: width * .03,
                      //       decoration: BoxDecoration(color: Color(0xffE6C069)),
                      //     ),
                      //     SizedBox(
                      //       width: width * .03,
                      //     ),
                      //     Text("Desired")
                      //   ],
                      // ),
                    ],
                  ),
                  SizedBox(height: height * .01),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData sampleData(width, height, BuildContext context) {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: .5);
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (double value, TitleMeta meta) {
              TextStyle style = TextStyle(
                color: const Color(0xff72719b),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              );

              String text;
              switch (value.toInt()) {
                case 1:
                  text = 'B';
                  break;
                case 2:
                  text = 'R';
                  break;
                case 3:
                  text = 'A';
                  break;
                case 4:
                  text = 'I';
                  break;
                case 5:
                  text = 'D';
                  break;
                default:
                  text = '';
              }

              return Container();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (double value, TitleMeta meta) {
              TextStyle style = TextStyle(
                color: const Color(0xff75729e),
                fontWeight: FontWeight.bold,
                fontSize: chosenOne.toString().length > 5
                    ? width * .02
                    : width * .03,
              );

              String formattedValue;
              switch (value.toInt()) {
                case 1:
                  formattedValue = '${(chosenOne / 5 * 1).round()}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  break;
                case 2:
                  formattedValue = '${(chosenOne / 5 * 2).round()}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  break;
                case 3:
                  formattedValue = '${(chosenOne / 5 * 3).round()}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  break;
                case 4:
                  formattedValue = '${(chosenOne / 5 * 4).round()}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  break;
                case 5:
                  formattedValue = '${(chosenOne / 5 * 5).round()}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );
                  break;
                default:
                  return Container();
              }

              return Container();
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide right axis
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide right axis
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 1),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),
      minX: 0,
      maxX: 6,
      maxY: 6,
      minY: 0,
      lineBarsData: linesBarData(context),
    );
  }

  List<LineChartBarData> linesBarData(BuildContext context) {
    return [
      // LineChartBarData(
      //   spots: [
      //     FlSpot(1, (data2[0] / desiredNumber()) * 5),
      //     FlSpot(2, (data2[1] / desiredNumber()) * 5),
      //     FlSpot(3, (data2[2] / desiredNumber()) * 5),
      //     FlSpot(4, (data2[3] / desiredNumber()) * 5),
      //     FlSpot(5, (data2[4] / desiredNumber()) * 5),
      //   ],
      //   isCurved: true,
      //   curveSmoothness: 0,
      //   colors: const [
      //     Color(0xffE6C069),
      //   ],
      //   barWidth: 4,
      //   isStrokeCapRound: true,
      //   dotData: FlDotData(
      //     show: true,
      //   ),
      //   belowBarData: BarAreaData(
      //     show: false,
      //   ),
      // ),
      LineChartBarData(
        spots: [
          FlSpot(1, (data1[0] / existNumber()) * 5),
          FlSpot(2, (data1[1] / existNumber()) * 5),
          FlSpot(3, (data1[2] / existNumber()) * 5),
          FlSpot(4, (data1[3] / existNumber()) * 5),
          FlSpot(5, (data1[4] / existNumber()) * 5),
        ],
        isCurved: true,
        curveSmoothness: 0,
        color: const Color(0xff8C8D86),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }
}

class ValueChart {
  final int type;
  final int value;

  ValueChart(this.type, this.value);
}
