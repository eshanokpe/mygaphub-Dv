import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/indicators.dart';

class Piechart extends StatefulWidget {
  @override
  Key? key;
  final List values;
  final List labels;
  final List colors;
  final List percent;
  final bool doiwant;

  Piechart({
    super.key,
    required this.values,
    required this.labels,
    required this.colors,
    required this.percent,
    this.doiwant = false,
  });

  @override
  _PiechartState createState() => _PiechartState();
}

class _PiechartState extends State<Piechart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    var currency = context.watch<Providers>().snapshotmodel.currency;

    // Generate indicators dynamically
    List<Indicator> indicators = [];
    for (var i = 0; i < widget.values.length; i++) {
      indicators.add(
        Indicator(
          doiwant: widget.doiwant,
          isSquare: false,
          color: Color(int.parse(widget.colors[i % widget.colors.length])),
          text: ' ${widget.labels[i]}  ${widget.percent[i]}%',
          textColor: Color(int.parse(widget.colors[i % widget.colors.length])),
          size: 10,
        ),
      );
    }

    return Container(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (event is FlLongPressEnd || event is FlPanEndEvent) {
                        touchedIndex = -1;
                      } else {
                        touchedIndex = pieTouchResponse
                            ?.touchedSection
                            ?.touchedSectionIndex;
                      }
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showingSections(height, currency),
              ),
            ),
          ),
          Wrap(direction: Axis.horizontal, children: indicators),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(double height, String currency) {
    return List.generate(widget.values.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 16.sp : 12.sp;
      final double radius = isTouched ? height * .10 : height * .08;

      final double parsedValue =
          double.tryParse(widget.values[i].toString()) ?? 0.0;
      final value = parsedValue
          .round(); // Ensures value is a whole number, e.g., 99.0 or 100.0
      return PieChartSectionData(
        color: Color(int.parse(widget.colors[i % widget.colors.length])),
        value: value.toDouble(),
        title: widget.percent[i] <= 0 ? "" : '${widget.percent[i].round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: const Color(0xffffffff),
        ),
      );
    });
  }
}
