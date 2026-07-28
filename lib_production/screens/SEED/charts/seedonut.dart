import 'package:GapHub/widgets/indicators_average_seed.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class Seedonut extends StatefulWidget {
  final List values;
  final List labels;
  final List colors;
  final List percent;
  final bool indicators;

  const Seedonut({
    super.key,
    required this.values,
    required this.labels,
    this.indicators = false,
    required this.colors,
    required this.percent,
  });
  @override
  _SeedonutState createState() => _SeedonutState();
}

class _SeedonutState extends State<Seedonut> {
  List<IndicatorAS> indicators = [];

  addIndicators() {
    for (var i = 0; i < widget.values.length; i++) {
      indicators.add(
        IndicatorAS(
          isSquare: false,
          color: Color(int.parse(widget.colors[i])),
          text: widget.labels[i],
          textColor: Color(int.parse(widget.colors[i])),
          size: 13,
          // size: touchedIndex == i ? 18 : 16,
        ),
      );
    }
  }

  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    addIndicators();
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

    var currency = context.watch<Providers>().snapshotmodel.currency;

    return Container(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.3,
            width: height * 0.3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback:
                      (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          }
                        });
                      },
                ),
                sectionsSpace: 0,
                centerSpaceRadius: width * 0.1,
                sections: showingSections(height, width, currency),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          Visibility(
            visible: widget.indicators,
            child: Column(
              children: [
                SizedBox(height: height * .05),
                Wrap(children: indicators),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(height, width, currency) {
    List<PieChartSectionData> items = [];
    for (var i = 0; i < widget.values.length; i++) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? width * .035 : width * .03;
      final double radius = isTouched ? width * .15 : width * .13;
      items.add(
        PieChartSectionData(
          color: Color(int.parse(widget.colors[i])),
          value: double.parse(widget.values[i].toString()),
          title: widget.percent[i] <= 0 ? "" : '${widget.percent[i]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        ),
      );
    }
    return items;
  }
}
