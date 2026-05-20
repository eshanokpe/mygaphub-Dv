import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:GapHub/widgets/indicators.dart';
import 'package:GapHub/utils/constants.dart';
import '../braidetails.dart';

class DashPiechartPort extends StatefulWidget {
  final List data;

  const DashPiechartPort(this.data, {super.key});

  @override
  _DashPiechartPortState createState() => _DashPiechartPortState();
}

class _DashPiechartPortState extends State<DashPiechartPort> {
  static const _labelColors = [
    Color(0xff7799A4),
    Color(0XffE84141),
    Color(0XffA4B083),
  ];

  static const _labels = ['Business', 'Risk', 'Appreciating'];

  late List values;
  late List<Indicator> indicators;
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    values = widget.data;
    indicators = _createIndicators();
  }

  List<Indicator> _createIndicators() {
    return List.generate(
      values.length.clamp(0, 3),
      (i) => Indicator(
        doiwant: true,
        isSquare: true,
        color: _labelColors[i],
        text: _labels[i],
        textColor: _labelColors[i],
        size: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final total = values.take(3).fold<num>(0, (sum, value) => sum + value);

    if (total == 0) {
      return _buildEmptyChart();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize =
            min(constraints.maxWidth, constraints.maxHeight) * 0.9;
        final fontSizeFactor = chartSize * 0.035.h;

        return Center(
          child: SizedBox(
            width: chartSize,
            height: chartSize * (isTablet ? 0.7.h : 0.8.h),
            child: SfCircularChart(
              margin: EdgeInsets.all(chartSize * 0.0),
              series: <CircularSeries>[
                _buildDoughnutSeries(fontSizeFactor, chartSize),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize =
            min(constraints.maxWidth, constraints.maxHeight) * 0.7;
        return Center(
          child: Container(
            width: chartSize,
            height: chartSize,
            decoration: const BoxDecoration(
              color: Color(0XFF8C8D86),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  DoughnutSeries<Map<String, dynamic>, String> _buildDoughnutSeries(
    double fontSizeFactor,
    double chartSize,
  ) {
    return DoughnutSeries<Map<String, dynamic>, String>(
      dataSource: List.generate(3, (index) {
        return {
          'value': values[index],
          'category': _labels[index],
          'color': _labelColors[index],
        };
      }),
      yValueMapper: (data, _) => data['value'],
      xValueMapper: (data, _) => data['category'],
      pointColorMapper: (data, _) => data['color'],
      dataLabelSettings: DataLabelSettings(
        builder: (data, _, __, ___, ____) =>
            _buildDataLabel(data, fontSizeFactor, chartSize),
        isVisible: true,
        labelPosition: ChartDataLabelPosition.outside,
        connectorLineSettings: ConnectorLineSettings(
          type: ConnectorType.line,
          length: '15%',
          color: Colors.black.withOpacity(0.7),
        ),
        overflowMode: OverflowMode.none,
        labelIntersectAction: LabelIntersectAction.shift,
        labelAlignment: ChartDataLabelAlignment.outer,
        textStyle: TextStyle(
          fontSize: fontSizeFactor,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
      ),
      radius: '60%',
      // innerRadius: '70%',
      // enableTooltip: true,
    );
  }

  Widget _buildDataLabel(
    Map<String, dynamic> data,
    double fontSizeFactor,
    double chartSize,
  ) {
    final isRisk = data['category'] == 'Risk';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRisk)
              Padding(
                padding: EdgeInsets.only(top: chartSize * 0.02),
                child: _buildCategoryText(
                  data,
                  fontSizeFactor,
                  isFirstLetter: true,
                ),
              )
            else
              _buildCategoryText(data, fontSizeFactor, isFirstLetter: true),
            if (isRisk)
              Padding(
                padding: EdgeInsets.only(top: chartSize * 0.02),
                child: _buildCategoryText(
                  data,
                  fontSizeFactor,
                  isFirstLetter: false,
                ),
              )
            else
              _buildCategoryText(data, fontSizeFactor, isFirstLetter: false),
          ],
        ),
        SizedBox(height: chartSize * 0.01),
        Text(
          '${data['value'].toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: fontSizeFactor * 0.9,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryText(
    Map<String, dynamic> data,
    double fontSizeFactor, {
    required bool isFirstLetter,
  }) {
    final text = isFirstLetter
        ? data['category'][0]
        : data['category'].substring(1);

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSizeFactor,
        fontWeight: isFirstLetter ? FontWeight.bold : FontWeight.w300,
        fontFamily: isFirstLetter ? 'Nunito' : null,
        color: const Color(0xff676767),
      ),
    );
  }

  Future<void> getData(String cap, String small) async {
    final timer = Timer(const Duration(seconds: 40), () {
      EasyLoading.dismiss();
    });

    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    try {
      final url = Uri.parse("$baseUrl/app/portfolio/$small");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Braidetails(cap, jsonDecode(response.body), false),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Error");
      }
    } finally {
      timer.cancel();
      EasyLoading.dismiss();
    }
  }
}
