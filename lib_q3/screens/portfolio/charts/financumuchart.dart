import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Financumuchart extends StatefulWidget {
  const Financumuchart({
    super.key,
    required this.data,
    // @required this.yAxis,
    required this.xAxis,
    required this.length,
    required this.type,
    required this.id,
    // @required this.names,
    required this.currency,
  });

  final Map data;
  final int length;
  final String type;
  final String id;
  // final List names;
  // final List yAxis;
  final List xAxis;
  final String currency;

  @override
  State<Financumuchart> createState() => _FinancumuchartState();
}

class _FinancumuchartState extends State<Financumuchart> {
  String selectedFrom = "";
  String selectedTo = "";
  List<double> revenueValues = [];
  List<double> expenditureValues = [];
  List<double> netIncomeValues = [];
  List<BarChartGroupData> showingBarCumu = [];
  List<BarChartGroupData> rawBarCumu = [];
  List names2 = ["Revenue", "Expenditure", "Net Income"];

  List<TableRow> expenInfo = [];
  List<TableRow> cumuInfo = [];
  var d = DateFormat.yMMMM();
  var mgtTotal = 0;
  var taxTotal = 0;
  var mtnTotal = 0;
  var othersTotal = 0;
  int length = 0;
  var revTotal = 0;
  var expenTotal = 0;
  var netTotal = 0;
  List cumu = [];
  List mgnt = [];
  List taxes = [];
  List mtn = [];
  List others = [];
  List labels = [];
  int bigNumCumu = 0;
  int bigNumCum = 0;
  int lengthCumu = 0;
  int bigNumExpen = 0;
  int lengthExpen = 0;
  var currency;
  int m = 0;
  int c = 0;
  int t = 0;
  int o = 0;

  List colors = [
    0xff479CC6,
    0xffBBC3A4,
    0xffFF8F28,
    0xff414141,
    0xff77A2BB,
    0xffE28394,
  ];

  @override
  void initState() {
    super.initState();
    selectedFrom = widget.xAxis[0];
    selectedTo = widget.xAxis[1];
    List financialData = widget.data['data']["asset_financial"];
    length = financialData.length;
    var parts = widget.data['data']["asset"]["asset_currency"].toString().split(
      " ",
    );
    currency = parts[0];
    cumu = widget.data['data']["asset_financial_record"]["curriculum"];
    mgnt = widget.data['data']["asset_financial_record"]["management"];
    taxes = widget.data['data']["asset_financial_record"]["taxes"];
    mtn = widget.data['data']["asset_financial_record"]["maintenance"];
    others = widget.data['data']["asset_financial_record"]["others"];
    labels =
        widget.data['data']["asset_financial_record"]["expenditure_labels"];

    lengthCumu = cumu.length;
    lengthExpen = mgnt.length;
    if (cumu.isNotEmpty) {
      bigNumCum = cumu.reduce((curr, next) => curr > next ? curr : next);
    }
    print("mgnt:$mgnt");

    if (mgnt.isNotEmpty) {
      // Convert the list of strings to a list of integers
      List<int> mgntInt = mgnt.map((e) => int.tryParse(e) ?? 0).toList();
      m = mgntInt.reduce((curr, next) => curr > next ? curr : next);
    }

    if (taxes.isNotEmpty) {
      List<int> taxesInt = taxes.map((e) => int.tryParse(e) ?? 0).toList();
      t = taxesInt.reduce((curr, next) => curr > next ? curr : next);
    }
    if (mtn.isNotEmpty) {
      List<int> mtnInt = mtn.map((e) => int.tryParse(e) ?? 0).toList();
      c = mtnInt.reduce((curr, next) => curr > next ? curr : next);
    }

    if (others.isNotEmpty) {
      List<int> othersInt = others.map((e) => int.tryParse(e) ?? 0).toList();
      o = othersInt.reduce((curr, next) => curr > next ? curr : next);
    }

    if (bigNumCum >= 0 && bigNumCum <= 100) {
      bigNumCumu = 100;
    } else if (bigNumCum >= 101 && bigNumCum <= 1000) {
      bigNumCumu = 1000;
    } else if (bigNumCum >= 1001 && bigNumCum <= 10000) {
      bigNumCumu = 10000;
    } else if (bigNumCum >= 10001 && bigNumCum <= 100000) {
      bigNumCumu = 100000;
    } else if (bigNumCum >= 100001 && bigNumCum <= 1000000) {
      bigNumCumu = 1000000;
    } else if (bigNumCum >= 1000001 && bigNumCum <= 100000000) {
      bigNumCumu = 100000000;
    } else if (bigNumCum >= 100000001 && bigNumCum <= 1000000000) {
      bigNumCumu = 1000000000;
    } else {
      bigNumCumu = bigNumCum;
    }

    final barCum0 = makeCumu(1, 0, const Color(0xffffffff));
    List<BarChartGroupData> itemsCumu = [barCum0];

    for (var i = 0; i < lengthCumu; i++) {
      itemsCumu.add(
        makeCumu(
          i + 1,
          bigNumCumu == 0 ? 0 : (cumu[i] / bigNumCumu) * 5,
          Color(colors[i]),
        ),
      );
    }
    itemsCumu.add(makeCumu(lengthCumu + 1 + 1, 0, const Color(0xffffffff)));

    rawBarCumu = itemsCumu;

    showingBarCumu = rawBarCumu;
  }

  BarChartGroupData makeCumu(int x, double y1, Color barColor) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: barColor,
          width: 10,
        ),
      ],
    );
  }

  Future<void> fetchChartData(String month) async {
    print('type:${widget.type}');
    print('id:${widget.id}');
    print('selectedFrom:$selectedFrom');
    print('selectedTo:$selectedTo');

    String url =
        "$baseUrl/app/portfolio/${widget.type}/${widget.id}?period_from=$selectedFrom&period_to=$selectedTo"; // Replace with the actual URL
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": 'Bearer $token'},
      );
      print("response:${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          // print('responseData:${responseData}');
          cumu = responseData['data']["asset_financial_record"]["curriculum"];
          print('cumu:$cumu');
          mgnt = responseData['data']["asset_financial_record"]["management"];
          print('mgnt:$mgnt');
          taxes = responseData['data']["asset_financial_record"]["taxes"];
          print('taxes:$taxes');
          mtn = responseData['data']["asset_financial_record"]["maintenance"];
          others = responseData['data']["asset_financial_record"]["others"];
          labels =
              responseData['data']["asset_financial_record"]["expenditure_labels"];
          print('labels:$labels');
        });
      } else {
        throw Exception('Failed to load chart data');
      }
    } catch (error) {
      print('Error fetching chart data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List colors = [
      0xff479CC6,
      0xffBBC3A4,
      0xffFF8F28,
      0xff414141,
      0xff77A2BB,
      0xffE28394,
    ];

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List<Widget> indicators = [];
    for (var i = 0; i < widget.length; i++) {
      indicators.add(Indicators(name: "${names2[i]}", color: colors[i]));
    }
    List yAxis = [];
    if (bigNumCumu != 0) {
      for (var i = 0; i < 6; i++) {
        yAxis.add((bigNumCumu / 5) * i);
      }
    } else {
      yAxis = [0, 0, 0, 0, 0, 0];
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * .02),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: height * .02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: width * .04,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff808080),
                      ),
                    ),
                    DropdownButton<String>(
                      value:
                          selectedFrom, // Ensure this value is in the items list
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedFrom = newValue;
                            fetchChartData(selectedFrom);
                          });
                        }
                      },
                      underline: const SizedBox.shrink(),
                      items: widget.xAxis.toSet().map<DropdownMenuItem<String>>(
                        (dynamic name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: width * .04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: width * .04,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff808080),
                      ),
                    ),
                    DropdownButton<String>(
                      value:
                          selectedTo, // Ensure this value is in the items list
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedTo = newValue;
                            fetchChartData(selectedTo);
                          });
                        }
                      },
                      underline: const SizedBox.shrink(),
                      items: widget.xAxis.toSet().map<DropdownMenuItem<String>>(
                        (dynamic name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: width * .04,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * .45,
            width: width,
            child: Card(
              color: AppColors.cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Color(0xffD8D8D8), width: 0.5),
              ),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceBetween,
                        maxY: 6,
                        minY: 0,
                        groupsSpace: 20,
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: false,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: Color(0xff37434d),
                            strokeWidth: 0.2,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, meta) {
                                if (value >= 1 && value <= labels.length) {
                                  final String fullLabel =
                                      labels[value.toInt() - 1].toString();
                                  final List<String> parts = fullLabel.split(
                                    ' ',
                                  );
                                  final String monthLabel = parts.isNotEmpty
                                      ? parts[0]
                                      : fullLabel;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      monthLabel.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= 0 && value < yAxis.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      '${widget.currency}${formatValue(yAxis[value.toInt()])}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: width * 0.20,
                              // margin: width * 0.08,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ), // Hide right axis
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ), // Hide right axis
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(
                              color: Color(0xff37434d),
                              width: 0.5,
                            ),
                            left: BorderSide(color: Colors.transparent),
                            right: BorderSide(color: Colors.transparent),
                            top: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        barGroups: rawBarCumu.map((group) {
                          return BarChartGroupData(
                            x: group.x,
                            barRods: group.barRods.map((rod) {
                              return BarChartRodData(
                                toY: rod.toY,
                                color: rod.color,
                                width: rod.width,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchCallback:
                              (
                                FlTouchEvent event,
                                BarTouchResponse? barTouchResponse,
                              ) {
                                if (barTouchResponse?.spot != null &&
                                    event is! PointerUpEvent) {
                                  final touchedGroupIndex = barTouchResponse!
                                      .spot!
                                      .touchedBarGroupIndex;
                                  final touchedGroup =
                                      rawBarCumu[touchedGroupIndex];

                                  setState(() {
                                    revenueValues = touchedGroup.barRods
                                        .where(
                                          (rod) =>
                                              rod.color ==
                                              const Color(0xff479CC6),
                                        )
                                        .map(
                                          (rod) => rod.toY,
                                        ) // Use `.toY` if using latest `fl_chart`
                                        .toList();
                                    print("revenueValues: $revenueValues");

                                    expenditureValues = touchedGroup.barRods
                                        .where(
                                          (rod) =>
                                              rod.color ==
                                              const Color(0xffBBC3A4),
                                        )
                                        .map((rod) => rod.toY)
                                        .toList();

                                    netIncomeValues = touchedGroup.barRods
                                        .where(
                                          (rod) =>
                                              rod.color ==
                                              const Color(0xffFF8F28),
                                        )
                                        .map((rod) => rod.toY)
                                        .toList();
                                  });
                                }
                              },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(
                        color: Color(0xffD8D8D8),
                        width: 0.2,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: width * .05),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 15.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Indicators(
                            name: "Revenue",
                            color: 0xff479CC6,
                            currency: widget.currency,
                            values: revenueValues,
                          ),
                          SizedBox(height: 5.h),
                          Indicators(
                            name: "Expenditure",
                            color: 0xffBBC3A4,
                            currency: widget.currency,
                            values: expenditureValues,
                          ),
                          SizedBox(height: 5.h),
                          Indicators(
                            name: "Net Income", // Fixed Typo
                            color: 0xffFF8F28,
                            currency: widget.currency,
                            values: netIncomeValues,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Can only display a maximum of 6 months",
                    style: TextStyle(
                      color: const Color(0xff808080),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatValue(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

class Indicators extends StatelessWidget {
  const Indicators({
    super.key,
    this.color,
    this.name,
    this.values,
    this.currency,
  });

  final int? color;
  final String? name;
  final String? currency;
  final List<double>? values;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * .005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: width * .03,
                width: width * .03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(color!),
                ),
              ),
              SizedBox(width: width * .01),
              Text("$name", style: TextStyle(fontSize: width * .04)),
            ],
          ),
          SizedBox(width: width * .01),
          Expanded(
            child: Wrap(
              spacing: width * .02, // Adjust the spacing between items
              runSpacing: 4.0, // Adjust the spacing between lines
              alignment: WrapAlignment.end,
              children: values!.isNotEmpty
                  ? values!.map((value) {
                      return Text(
                        '$currency${value.toStringAsPrecision(2)}',
                        style: TextStyle(
                          fontSize: width * .04,
                          color: Color(color!),
                        ),
                      );
                    }).toList()
                  : [
                      Text(
                        '${currency}0.0',
                        style: TextStyle(
                          fontSize: width * .04,
                          color: Color(color!),
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
