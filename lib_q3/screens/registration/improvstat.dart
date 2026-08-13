import 'dart:convert';
import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:nimble_charts/flutter.dart' as charts;

class IndependenceSeries {
  final double time;
  final double cash;
  final charts.Color lineColor;

  IndependenceSeries(this.time, this.cash, this.lineColor);
}

class Improvstat extends StatefulWidget {
  final Calculatormodel parameters;
  const Improvstat(this.parameters, {super.key});
  @override
  _ImprovstatState createState() => _ImprovstatState(parameters);
}

class _ImprovstatState extends State<Improvstat> {
  Calculatormodel parameters;
  _ImprovstatState(this.parameters) : other = 0, total = 0;
  final TextEditingController _roce = TextEditingController();
  final TextEditingController _invest = TextEditingController();
  final now = DateTime.now();

  DialogBox dialogBox = DialogBox();
  bool toggs = true;
  double shortfall = 0.0;
  double avr = 0;
  double t2fi = 0;
  double total, other;
  @override
  void initState() {
    super.initState();
    var a = double.parse(widget.parameters.periodic!);
    var b = double.parse(widget.parameters.education!);
    var c = double.parse(widget.parameters.mortgage!);
    var d = double.parse(widget.parameters.mobility!);
    var e = double.parse(widget.parameters.expenses!);
    var f = double.parse(widget.parameters.utility!);
    var g = double.parse(widget.parameters.debtRepay!);
    var h = double.parse(widget.parameters.charity!);

    other = double.parse(widget.parameters.otherIncome!);
    total = a + b + c + d + e + f + g + h;
  }

  @override
  Widget build(BuildContext context) {
    double year = now.year.toDouble();
    String symbo = context.watch<Providers>().currencySymbol;
    var symboll = symbo.split(" ").toList();
    String symbol = symboll[0];
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final List<IndependenceSeries> data = [
      IndependenceSeries(
        year,
        double.parse(widget.parameters.otherIncome!),
        charts.ColorUtil.fromDartColor(Colors.black),
      ),
      IndependenceSeries(
        (year + t2fi.roundToDouble()),
        context.watch<Providers>().totMonExp,
        charts.ColorUtil.fromDartColor(Colors.black),
      ),
    ];

    List<charts.Series<IndependenceSeries, num>> series = [
      charts.Series(
        id: "Independence chart",
        data: data,
        domainFn: (IndependenceSeries series, _) => series.time,
        measureFn: (IndependenceSeries series, _) => series.cash,
        colorFn: (IndependenceSeries series, _) => series.lineColor,
      ),
    ];

    String userEmail = context.watch<Providers>().loginDetails.email!;
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f4),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'GAPhub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .01,
            vertical: width * .04,
          ),
          child: Column(
            children: [
              Text(
                'Financial Independence Timeline',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: width * .055,
                ),
              ),
              SizedBox(height: height * .01),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your status can be improved by saving more for rainy day and acquiring more income-generating assets.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: width * .03,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Find out below how long it will take you to become financially independent based on your affordability.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: width * .03,
                  ),
                ),
              ),
              SizedBox(height: height * .06),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Asset Portfolio (API) needed',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: width * .042,
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      '$symbol${context.watch<Providers>().totMonExp.toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      style: TextStyle(
                        fontSize: width * .06,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Text(
                      'Your Current Monthly Asset Portfolio Income',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: width * .042,
                      ),
                    ),
                    SizedBox(height: height * .01),
                    Text(
                      '$symbol${double.parse(widget.parameters.otherIncome!).toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      style: TextStyle(
                        fontSize: width * .06,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .03,
                child: Divider(color: Theme.of(context).primaryColor),
              ),
              Padding(
                padding: EdgeInsets.all(width * .02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How much can you set aside monthly for investments?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: width * .04,
                      ),
                    ),
                    SizedBox(height: height * .01),
                    TextFormField(
                      inputFormatters: [amountValidator],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: width * .04,
                      ),
                      controller: _invest,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefix: Text(
                          symbol,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: width * .04,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(width * .02),
                        errorStyle: const TextStyle(),
                        labelStyle: const TextStyle(color: Colors.black),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: height * .03),
                    RichText(
                      // textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(height: 1.5),
                        children: [
                          TextSpan(
                            text:
                                'What is your expected Return On Capital Employed (ROCE)?',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: width * .04,
                            ),
                          ),
                          const WidgetSpan(
                            child: Tooltip(
                              triggerMode: TooltipTriggerMode.tap,
                              textStyle: TextStyle(
                                height: 1.5,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              message:
                                  "To help you achieve the monthly financial target, you will need to consider investments with adequate returns. Choose a desired return on capital employed (Typical conventional rate of return, is between 3% to 10%).",
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * .01),
                    TextFormField(
                      inputFormatters: [amountValidator],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: width * .04,
                      ),
                      controller: _roce,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        suffix: Text(
                          '% ',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: width * .04,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(width * .02),
                        errorStyle: const TextStyle(),
                        labelStyle: const TextStyle(color: Colors.black),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: height * .05),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .02),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (_roce.text.isEmpty || _invest.text.isEmpty) {
                    dialogBox.information(
                      context,
                      'Status',
                      'Fill up the field',
                    );
                    return;
                  }

                  try {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (double.parse(_roce.text) > 0) {
                      setState(() {
                        shortfall = total - other;
                        avr = (shortfall * 12 * 100) / double.parse(_roce.text);
                        t2fi = (avr / double.parse(_invest.text)) / 12;

                        toggs = false;
                      });
                    } else {
                      dialogBox.information(
                        context,
                        'Status',
                        'Value cannot be 0',
                      );
                    }
                  } catch (e) {
                    dialogBox.information(context, 'title', e.toString());
                  }
                },
                child: Container(
                  padding: EdgeInsets.zero,
                  // height: height * .05,
                  width: width * .4,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'See Result',
                      style: TextStyle(
                        color: const Color(0xfff3f3f4),
                        fontWeight: FontWeight.w900,
                        fontSize: width * .05,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .05,
                child: Divider(color: Theme.of(context).primaryColor),
              ),
              Visibility(
                visible: !toggs,
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Time to Financial Independence: ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w900,
                              fontSize: width * .06,
                            ),
                          ),
                          Text(
                            '${t2fi.round()} Years'.replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: width * .06,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * .05),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(width * .02),
                        child: Column(
                          children: [
                            Text(
                              'Summary & Recommendations',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: width * .05,
                              ),
                            ),
                            SizedBox(height: height * .01),
                            Text(
                              'You have a shortfall of $symbol${shortfall.round()} in your asset portfolio income. In order to become financially independent, you will need to acquire assets to the value of $symbol${avr.round()} generating income at ${_roce.text}% ROCE to make up this shortfall. Setting aside $symbol${_invest.text} monthly for investment will allow you become financially independent in ${t2fi.round()} years. Explore the opportunities listed by our partners from your GAPhub account. Also, visit the acquisition section of your account and start using MyGAPhub to build a profitable asset portfolio globally.'
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: width * .035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * .03),
                    SizedBox(
                      height: height * 0.3,
                      child: Flex(
                        direction: Axis.vertical,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: LineChart(
                              sampleData(symbol, context),
                              duration: const Duration(milliseconds: 250),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * .02),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        dialogBox.waiting(context, 'Loading');
                        try {
                          Map<String, dynamic> body = {
                            "currency": parameters.currency,
                            "periodic_savings": parameters.periodic,
                            "education": parameters.education,
                            "mortgage": parameters.mortgage,
                            "mobility": parameters.mobility,
                            "expenses": parameters.expenses,
                            "utility": parameters.utility,
                            "dept_repay": parameters.debtRepay,
                            "charity": parameters.charity,
                            "other_income": parameters.otherIncome,
                            "extra_save": parameters.extraSave,
                            "roce": _roce.text,
                            "investment": _invest.text,
                          };

                          var url = Uri.parse("$baseUrl/app/calculator");
                          final prefs = await SharedPreferences.getInstance();
                          var token = prefs.getString('tokenDB');
                          final response = await http.post(
                            url,
                            body: body,
                            headers: {
                              "Authorization": 'Bearer $token',
                              "Accept": "application/json",
                              "Content-Type":
                                  "application/x-www-form-urlencoded",
                            },
                            encoding: Encoding.getByName("utf-8"),
                          );

                          if (response.statusCode == 200) {
                            try {
                              sendinblue(userEmail);
                            } catch (e) {}
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Prequestions(),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            dialogBox.information(
                              context,
                              'Status',
                              'Network or Server Error',
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          dialogBox.information(
                            context,
                            'Status',
                            'Network or Server Error',
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.zero,
                        height: height * .06,
                        width: width * .6,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: const Color(0xfff3f3f4),
                              fontWeight: FontWeight.w900,
                              fontSize: width * .05,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * .02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData sampleData(String symbol, BuildContext context) {
    final otherIncome =
        double.tryParse(widget.parameters.otherIncome ?? '0') ?? 0;
    final monthlyAssetNeeded = context.watch<Providers>().totMonExp;
    final now = DateTime.now();

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) =>
            const FlLine(color: Color(0xff37434d), strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            // margin: 10,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return const Text('');
                case 1:
                  return Text('${now.year}');
                case 5:
                  return Text('${(t2fi ?? 0).round() + now.year}');
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return const Text('');
                case 1:
                  return Text('$symbol${parsed(otherIncome * 0.4)}');
                case 2:
                  return Text('$symbol${parsed(otherIncome * 0.6)}');
                case 3:
                  return Text('$symbol${parsed(otherIncome * 0.8)}');
                case 4:
                  return Text('$symbol${parsed(otherIncome)}');
                case 5:
                  return Text('$symbol${parsed(monthlyAssetNeeded)}');
              }
              return const Text('');
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
          left: BorderSide(color: Color(0xff4e4965), width: 1),
          right: BorderSide(color: Color(0xff4e4965), width: 0.2),
          top: BorderSide(color: Color(0xff4e4965), width: 0.2),
        ),
      ),
      minX: 0,
      maxX: 5,
      maxY: 5,
      minY: 0,
      lineBarsData: linesBarData(),
    );
  }

  List<LineChartBarData> linesBarData() {
    return [
      LineChartBarData(
        spots: [const FlSpot(1, 4), const FlSpot(5, 5)],
        isCurved: true,
        curveSmoothness: 0,
        color: Colors.black.withOpacity(0.7),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  String parsed(double value) {
    return '${(value).round()}'.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  sendinblue(String email) async {
    var url = Uri.parse("https://api.sendinblue.com/v3/contacts");
    Map body = {
      "email": email,
      "Firstname": "",
      "listIds": [26],
      "updateEnabled": false,
    };

    var response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "api-key":
            "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",
      },
    );
  }
}
