import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoricBarChart extends StatefulWidget {
  Map item;
  Map historicData;
  final String currency;

  HistoricBarChart({
    super.key,
    required this.item,
    required this.currency,
    required this.historicData,
  });
  @override
  State<HistoricBarChart> createState() => _HistoricBarChartState();
}

class _HistoricBarChartState extends State<HistoricBarChart> {
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
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Historic Seed',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.045),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            SizedBox(height: height * .02),
            const Text('Historic SEED Bar Chart'),
            SizedBox(height: height * .02),
            const Text('(slide to view more)'),
            SizedBox(height: height * .03, child: const Divider(thickness: 2)),
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
                  barRendererDecorator: charts.BarLabelDecorator<String>(
                    labelPosition: charts.BarLabelPosition.outside,
                    labelAnchor: charts.BarLabelAnchor.end,
                    labelPadding: 0,
                    outsideLabelStyleSpec: const charts.TextStyleSpec(
                      color: charts.MaterialPalette.black,
                      fontSize: 12,
                    ),
                  ),
                  maxBarWidthPx: 80,
                  strokeWidthPx: 50,
                  stackedBarPaddingPx: 80,
                ),
                barRendererDecorator: charts.BarLabelDecorator(
                  //labelPosition: charts.BarLabelPosition.outside,
                  labelAnchor: charts.BarLabelAnchor.end,
                  labelPadding: 1,
                  insideLabelStyleSpec: const charts.TextStyleSpec(
                    color: charts.MaterialPalette.white,
                    fontSize: 12,
                  ),
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                    labelStyle: const charts.TextStyleSpec(
                      fontSize: 14,
                      color: charts.MaterialPalette.black,
                    ),
                  ),
                  tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                    desiredTickCount: 5,
                    dataIsInWholeNumbers: true,
                  ),
                  tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                    (value) => '$currency${value!.toInt()}',
                  ),
                ),
                // Add BarLabelDecoratorSpec to show the percentage label on top of the bars
                behaviors: const [],
              ),
            ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                        width: width * .03,
                        child: Container(color: const Color(0xff00B050)),
                      ),
                      SizedBox(height: height * .01),
                      Text(
                        'Savings',
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
                        child: Container(color: const Color(0xffE6C069)),
                      ),
                      SizedBox(height: height * .01),
                      Text(
                        'Education',
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
                        child: Container(color: const Color(0xffD13B56)),
                      ),
                      SizedBox(height: height * .01),
                      Text(
                        'Expenditure',
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
                        child: Container(color: const Color(0xff4D7D99)),
                      ),
                      SizedBox(height: height * .01),
                      Text(
                        'Discretionary',
                        style: TextStyle(
                          color: Colors.black45,
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
            /* RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Click ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: width * .03,
                        fontWeight: FontWeight.w300),
                  ),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        EasyLoading.show(
                          status: 'Loading',
                          dismissOnTap: false,
                        );

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoricLineChart(
                                historicSeedData: widget.historicData,
                              ),
                            ));
                        EasyLoading.dismiss();
                        EasyLoading.dismiss();
                      },
                    text: 'here ',
                    style: TextStyle(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                      text: 'to switch the chart or ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .03,
                          fontWeight: FontWeight.w300)),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var timer = Timer(Duration(milliseconds: 20000), () {
                          Navigator.pop(context);
                          EasyLoading.dismiss();
                          dialogBox.information(
                              context, 'Status', 'Service timed out');
                          return;
                        });
                        EasyLoading.show(
                          status: 'Loading',
                          dismissOnTap: false,
                        );
                        var _urlSA = Uri.parse("$baseUrl2/app/seed/");
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');
                        var response = await http.get(_urlSA, headers: {
                          "Authorization": 'Bearer $token',
                          "Accept": "application/json",
                          "Content-Type": "application/x-www-form-urlencoded"
                        });
                        if (response.statusCode == 200) {
                          var bodyss = jsonDecode(response.body);
                          var average = bodyss['data']['average_detail'];
                          print('itemss:$average');
                          Map<String, dynamic> body = jsonDecode(response.body);
                          var period = body["data"]['periods'];
                          print('period:${period.length}');
                          print('itemss:$body');

                          if (period.length == 0) {
                            timer.cancel();
                            EasyLoading.dismiss();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AverageSeed(data: body),
                                ));
                          } else if (period.length == null) {
                            timer.cancel();
                            EasyLoading.dismiss();
                            Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                msg: 'No Data Found ',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM);
                          } else {
                            timer.cancel();
                            EasyLoading.dismiss();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HistoricSeed(data: body),
                                ));
                          }
                        } else {
                          timer.cancel();
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: 'No Data Found ',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                      },
                    text: 'here ',
                    style: TextStyle(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                      text: 'return to the titles',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .03,
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ), */
          ],
        ),
      ),
    );
  }

  final date = DateFormat("MMM");

  List<charts.Series<dynamic, String>> _createSeriesList() {
    List<ChartData> savingsData = [];
    List<ChartData> educationData = [];
    List<ChartData> expenditureData = [];
    List<ChartData> discretionaryData = [];
    String currency = context.read<Providers>().snapshotmodel.currency;

    // Extract data from historicSeedData
    for (var entry in widget.historicData.entries) {
      String period = date.format(DateTime.parse(entry.key));
      Map<String, dynamic> data = entry.value;

      savingsData.add(
        ChartData(period, data['table']['savings'], data['seed_web'][0]),
      );
      educationData.add(
        ChartData(period, data['table']['education'], data['seed_web'][1]),
      );
      expenditureData.add(
        ChartData(period, data['table']['expenditure'], data['seed_web'][2]),
      );
      discretionaryData.add(
        ChartData(period, data['table']['discretionary'], data['seed_web'][3]),
      );
    }

    return [
      charts.Series<ChartData, String>(
        id: 'Savings',
        data: savingsData,
        domainFn: (ChartData sales, _) => sales.period,
        measureFn: (ChartData sales, _) => sales.amount,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xff00B050)),
        labelAccessorFn: (ChartData sales, _) => '${sales.percentage}%',
      ),
      charts.Series<ChartData, String>(
        id: 'Education',
        data: educationData,
        domainFn: (ChartData sales, _) => sales.period,
        measureFn: (ChartData sales, _) => sales.amount,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xffE6C069)),
        labelAccessorFn: (ChartData sales, _) => '${(sales.percentage)}%',
      ),
      charts.Series<ChartData, String>(
        id: 'Expenditure',
        data: expenditureData,
        domainFn: (ChartData sales, _) => sales.period,
        measureFn: (ChartData sales, _) => sales.amount,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xffD13B56)),
        labelAccessorFn: (ChartData sales, _) => '${(sales.percentage)}%',
      ),
      charts.Series<ChartData, String>(
        id: 'Discretionary',
        data: discretionaryData,
        domainFn: (ChartData sales, _) => sales.period,
        measureFn: (ChartData sales, _) => sales.amount,
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(const Color(0xff4D7D99)),
        labelAccessorFn: (ChartData sales, _) => '${(sales.percentage)}%',
      ),
    ];
  }
}

class ChartData {
  final String period;
  var amount;
  var percentage;

  ChartData(this.period, this.amount, this.percentage);
}
