import 'package:GapHub/screens/SEED/seedash/historic_seed/reports/periodicData.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';

class ViewReportChartEduction extends StatefulWidget {
  final Map<String, dynamic> data;
  final String currency;
  final String historicdate;
  final String date;
  final String? title;
  final List<dynamic> list;

  const ViewReportChartEduction({
    super.key,
    required this.currency,
    required this.data,
    required this.historicdate,
    required this.list,
    required this.date,
    this.title,
  });

  @override
  State<ViewReportChartEduction> createState() =>
      _ViewHistoricReportChartState();
}

class _ViewHistoricReportChartState extends State<ViewReportChartEduction> {
  Map dashData = {};
  Map seedData = {};
  Dio dio = Dio();
  Map historicData = {};
  Map historicvalue = {};

  @override
  void initState() {
    super.initState();

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<charts.Series<dynamic, String>> seriesList = _createSeriesList();
    String currency = context.read<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Historic Seed',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.045),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(height: height * .02),
          PeriodicData(
            date: widget.date,
            historicdate: widget.historicdate,
            list: widget.list,
          ),
          SizedBox(height: height * .03),
          Stack(
            children: [
              Center(
                child: Container(
                  width: width * .88,
                  height: height * .20,
                  decoration: BoxDecoration(
                    color: const Color(0xffE6C069),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        //color: Color(0xff00B050).withOpacity(0.4),
                        spreadRadius: 6,
                        blurRadius: 1,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: height * .02,
                left: width * .04,
                right: width * .04,
                child: Center(
                  child: SizedBox(
                    width: width * .88,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: width * .05,
                        right: width * .05,
                      ),
                      child: Text(
                        "${widget.title}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: context.width(.07),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: width * .27),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ClipPath(
                    clipper: ProsteBezierCurve(
                      position: ClipPosition.top,
                      list: [
                        BezierCurveSection(
                          start: Offset(screenWidth, 0),
                          top: Offset(screenWidth / 2, 0),
                          end: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Container(color: Colors.white, height: height),
                  ),
                ),
              ),
              Positioned(
                top: height * .15,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      SizedBox(height: height * .02),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400, // Specify a height for the chart
                        padding: const EdgeInsets.all(8.0),
                        child: charts.BarChart(
                          seriesList,
                          animate: true,
                          vertical: true,
                          defaultRenderer: charts.BarRendererConfig(
                            groupingType: charts.BarGroupingType.grouped,
                            barRendererDecorator:
                                charts.BarLabelDecorator<String>(),
                          ),
                          barRendererDecorator: charts.BarLabelDecorator(
                            labelPosition: charts.BarLabelPosition.outside,
                            labelAnchor: charts.BarLabelAnchor.start,
                            labelPadding: 1,
                            insideLabelStyleSpec: const charts.TextStyleSpec(
                              color: charts.MaterialPalette.white,
                            ),
                          ),
                          primaryMeasureAxis: charts.NumericAxisSpec(
                            renderSpec: charts.GridlineRendererSpec(
                              labelStyle: const charts.TextStyleSpec(
                                fontSize: 14,
                                color: charts.MaterialPalette.black,
                              ),
                            ),
                            tickProviderSpec:
                                const charts.BasicNumericTickProviderSpec(
                                  desiredTickCount: 5,
                                  dataIsInWholeNumbers: true,
                                ),
                            tickFormatterSpec:
                                charts.BasicNumericTickFormatterSpec(
                                  (value) => '$currency$value',
                                ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * .03,
                        child: const Divider(thickness: 2),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height * .0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: height * .01,
                                  width: width * .03,
                                  child: Container(
                                    color: const Color(0xFFA3AF65),
                                  ),
                                ),
                                SizedBox(height: height * .01),
                                Text(
                                  'Budget',
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: width * .035,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: width * .03),
                            Column(
                              children: [
                                SizedBox(
                                  height: height * .01,
                                  width: width * .03,
                                  child: Container(
                                    color: const Color(0xffE6C069),
                                  ),
                                ),
                                SizedBox(height: height * .01),
                                Text(
                                  'Actual',
                                  style: TextStyle(
                                    color: const Color(0xFFBAB09E),
                                    fontSize: width * .035,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .03),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: EdgeInsets.only(bottom: height * .02),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Click ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: width * .03,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      Navigator.pop(context);
                    },
                  text: 'here ',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                    fontSize: width * .035,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'to return to the previous page',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: width * .03,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final date = DateFormat("MMM");

  List<charts.Series<dynamic, String>> _createSeriesList() {
    List<ChartData> budgetData = [];
    List<ChartData> actualData = [];
    String currency = context.read<Providers>().snapshotmodel.currency;

    // Extract data from historicSeedData
    for (var entry in widget.data.keys) {
      String period = date.format(DateTime.parse(entry));
      print(widget.data[entry]['budget']);
      print(widget.data[entry]['actual']);

      budgetData.add(ChartData(period, widget.data[entry]['budget']));
      actualData.add(ChartData(period, widget.data[entry]['actual']));
    }

    return [
      charts.Series<ChartData, String>(
        id: 'Budget',
        data: budgetData,
        domainFn: (ChartData sales, _) => sales.period,
        measureFn: (ChartData sales, _) => sales.amount,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xFFA3AF65)),
        labelAccessorFn: (ChartData data, _) =>
            '$currency${data.amount.toInt()}',
      ),
      charts.Series<ChartData, String>(
        id: 'Actual',
        data: actualData,
        domainFn: (ChartData sales, _) => sales.period,
        measureFn: (ChartData sales, _) => sales.amount,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xFFBAB09E)),
        labelAccessorFn: (ChartData data, _) =>
            '$currency${data.amount.toInt()}',
      ),
    ];
  }
}

class ChartData {
  final String period;
  int amount;

  ChartData(this.period, this.amount);
}
