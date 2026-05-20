import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/models/IncomeChartModel.dart';
import 'dart:math';

class Linechart extends StatefulWidget {
  final IncomeChartModel model;

  Linechart({required this.model});

  @override
  State<StatefulWidget> createState() => LinechartState(this.model);
}

class LinechartState extends State<Linechart> {
  bool isShowingMainData;
  int totInc;
  int val;
  IncomeChartModel model;
  double interval = 10;
  bool intervalBool = false;
  LinechartState(this.model)
    : isShowingMainData = true,
      totInc = 0,
      val = 0,
      interval = 10,
      intervalBool = false,
      _spot = [],
      _spot2 = [];
  List<FlSpot> _spot = [];
  List<FlSpot> _spot2 = [];

  @override
  void initState() {
    super.initState();
    var geekList = model.portfolioValues;

    weigh(List geekList) {
      var largestGeekValue = geekList[0].round();
      var smallestGeekValue = geekList[0];
      // print(geekList);
      for (var i = 0; i < geekList.length; i++) {
        // Checking for largest value in the list
        if (geekList[i] > largestGeekValue) {
          largestGeekValue = geekList[i].round();
        }

        // Checking for smallest value in the list
        if (geekList[i] < smallestGeekValue) {
          smallestGeekValue = geekList[i].round();
        }
      }

      if (geekList.length > 0) {
        var split = largestGeekValue.toString().split("");
        var fin =
            ((largestGeekValue / pow(10, (split.length - 1))).ceil()) *
            pow(10, (split.length - 1));
        // print(fin);
        return fin.toInt();
      }

      return 0;
    }

    var portValues = weigh(model.portfolioValues!);
    var nonportValues = weigh(model.nonPortfolioValues!);
    setState(() {
      totInc = portValues > nonportValues ? portValues : nonportValues;
    });

    if (model.portfolioValues!.length <= 0) {
      setState(() {
        _spot2.add(const FlSpot(0, 0));
      });
    }

    if (model.nonPortfolioValues!.length <= 0) {
      setState(() {
        _spot.add(const FlSpot(0, 0));
      });
    }

    for (var i = 0; i < model.portfolioValues!.length; i++) {
      _spot2.add(FlSpot(i + 1.0, ((model.portfolioValues![i]) * 6) / totInc));
    }

    for (var i = 0; i < model.nonPortfolioValues!.length; i++) {
      _spot.add(
        FlSpot(i + 1.toDouble(), ((model.nonPortfolioValues![i]) * 5) / totInc),
      );
    }
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

    // totInc = int.parse(context
    //     .watch<Providers>()
    //     .snapshotmodel
    //     .financial["portfolio"]
    //     .round()
    //     .toString());
    // val = totInc / 5;
    val = totInc;
    return AspectRatio(
      aspectRatio: 1.13,
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        child: Container(
          padding: EdgeInsets.only(left: width * .02),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xffC9D7E1),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 37),
                  Text(
                    'Income Characteristics',
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
                        sampleData(width, height),
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
                              color: Color(0xffC5BD99),
                            ),
                          ),
                          SizedBox(width: width * .03),
                          const Text("Portfolio"),
                        ],
                      ),
                      SizedBox(width: width * .05),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: width * .01,
                            width: width * .03,
                            decoration: const BoxDecoration(
                              color: Color(0xffED3237),
                            ),
                          ),
                          SizedBox(width: width * .03),
                          const Text("Non-Portfolio"),
                        ],
                      ),
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

  LineChartData sampleData(double width, double height) {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: const Color(0xff37434d), strokeWidth: .5);
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              if (model.periods != null &&
                  model.periods!.length > value.toInt()) {
                return Text(
                  model.periods![value.toInt()] is String
                      ? model.periods![value.toInt()]
                      : '',
                  style: const TextStyle(
                    color: Color(0xFF3C3D3D),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                '${val - ((val / 5) * (5 - value.toInt())).round().toInt()}',
                style: TextStyle(
                  color: Color(0xff75729e),
                  fontWeight: FontWeight.bold,
                  fontSize: width * .03,
                ),
              );
            },
            // margin: 20,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 1),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.grey),
        ),
      ),
      minX: 0,
      maxX: 4,
      maxY: 5,
      minY: 0,
      lineBarsData: linesBarData(),
    );
  }

  List<LineChartBarData> linesBarData() {
    return [
      LineChartBarData(
        spots: _spot,
        isCurved: true,
        curveSmoothness: 0,
        color: const Color(0xffED3237),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: _spot2,
        isCurved: true,
        curveSmoothness: 0,
        color: const Color(0xffC5BD99),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }
}
