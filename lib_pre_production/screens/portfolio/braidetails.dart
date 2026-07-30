import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'charts/portfoliovaluechart.dart';
import 'charts/detailsvaluechart.dart';
import 'charts/portfolioIncomechart.dart';
import 'braiditem.dart';
import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'package:http/http.dart' as http;
import 'portarchives.dart';
import 'package:nimble_charts/flutter.dart' as charts;

import 'widget/braid_list_item.dart';

class Braidetails extends StatefulWidget {
  final String type;
  final Map data;
  final bool fromInvestment360;

  const Braidetails(this.type, this.data, this.fromInvestment360, {super.key});
  @override
  _BraidetailsState createState() => _BraidetailsState();
}

class _BraidetailsState extends State<Braidetails> {
  Dio dio = Dio();
  bool? fromInvestment360;
  DialogBox dialogBox = DialogBox();
  final double width = 20;
  int bigNumIncome = 0;
  int bigNumValue = 0;
  int bigNumIncom = 0;
  int bigNumValu = 0;
  List<charts.Series<Norms, String>> _seriesData = [];

  List<BarChartGroupData> showingBarGroupsIncome = [];
  List<BarChartGroupData> rawBarGroupsIncome = [];
  List<BarChartGroupData> showingBarGroupsValue = [];
  List<BarChartGroupData> rawBarGroupsValue = [];
  List existing = [];
  List desired = [];
  var chartData;
  List aInc = [];
  List aVal = [];
  List names = [];
  List lablesAsset = [];
  int lengthInc = 0;
  int lengthVal = 0;
  List colors = [
    0xff8C8D86,
    0xffE6C069,
    0xff897B61,
    0xff8DAB8E,
    0xff77A2BB,
    0xffE28394,
  ];
  List<TableRow> existingTabs = [];
  List<TableRow> desiredTabs = [];
  addData() {
    _seriesData = [];

    _seriesData.add(
      charts.Series(
        data: [],
        domainFn: (Norms kpi, _) => kpi.name,
        measureFn: (Norms kpi, _) => kpi.value,
        colorFn: (Norms kpi, _) =>
            charts.ColorUtil.fromDartColor(Color(kpi.color)),
        outsideLabelStyleAccessorFn: (Norms kpi, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.red.shadeDefault,
        ),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: '7G KPI',
        // domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Norms kpi, _) => '${(kpi.value).toInt()}%',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fromInvestment360 = widget.fromInvestment360;
    _seriesData = [];
    addData();
    existing = widget.data["existing"];
    desired = widget.data["desired"];
    chartData = widget.data["existing_details"];
    aInc = chartData["asset_incomes"];
    aVal = chartData["asset_values"];
    names = chartData["labels"];
    lablesAsset = chartData["label_asset"];

    lengthInc = aInc.length;
    lengthVal = aVal.length;

    if (aInc.isNotEmpty) {
      bigNumIncom = aInc
          .reduce((curr, next) => curr > next ? curr : next)
          .round();
    }
    if (aVal.isNotEmpty) {
      bigNumValu = aVal
          .reduce((curr, next) => curr > next ? curr : next)
          .round();
    }

    if (bigNumIncom >= 0 && bigNumIncom <= 100) {
      bigNumIncome = 100;
    } else if (bigNumIncom >= 101 && bigNumIncom <= 1000) {
      bigNumIncome = 1000;
    } else if (bigNumIncom >= 1001 && bigNumIncom <= 10000) {
      bigNumIncome = 10000;
    } else if (bigNumIncom >= 10001 && bigNumIncom <= 100000) {
      bigNumIncome = 100000;
    } else if (bigNumIncom >= 100001 && bigNumIncom <= 1000000) {
      bigNumIncome = 1000000;
    } else if (bigNumIncom >= 1000001 && bigNumIncom <= 10000000) {
      bigNumIncome = 10000000;
    } else if (bigNumIncom >= 10000001 && bigNumIncom <= 100000000) {
      bigNumIncome = 100000000;
    } else {
      bigNumIncome = bigNumIncom;
    }
    if (bigNumValu >= 0 && bigNumValu <= 100) {
      bigNumValue = 100;
    } else if (bigNumValu >= 101 && bigNumValu <= 1000) {
      bigNumValue = 1000;
    } else if (bigNumValu >= 1001 && bigNumValu <= 10000) {
      bigNumValue = 10000;
    } else if (bigNumValu >= 10001 && bigNumValu <= 100000) {
      bigNumValue = 100000;
    } else if (bigNumValu >= 100001 && bigNumValu <= 1000000) {
      bigNumValue = 1000000;
    } else if (bigNumValu >= 1000001 && bigNumValu <= 100000000) {
      bigNumValue = 100000000;
    } else if (bigNumValu >= 100000001 && bigNumValu <= 1000000000) {
      bigNumValue = 1000000000;
    } else {
      bigNumValue = bigNumValu;
    }

    final barGroupIncome0 = makeGroupDataIncome(0, 0, const Color(0xffffffff));

    final barGroupValue0 = makeGroupDataValue(0, 0, const Color(0xffffffff));

    for (var i = 0; i < desired.length; i++) {
      desiredTabs.add(
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: [
            Tabledata(text: '${desired[i]["name"]}', thick: false),
            Tabledata(
              thick: false,
              text:
                  '${splitit(desired[i]["asset_currency"])}${desired[i]["asset_value"]}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
            ),
            Tabledata(
              thick: false,
              text:
                  '${desired[i]["asset_currency"]}${desired[i]["monthly_roi"]}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
            ),
          ],
        ),
      );
    }

    List<BarChartGroupData> itemsIncome = [barGroupIncome0];
    for (var i = 0; i < lengthInc; i++) {
      itemsIncome.add(
        makeGroupDataIncome(
          i + 1,
          (bigNumIncome <= 0 ? 0 : (aInc[i] / bigNumIncome) * 5) < 0
              ? 0
              : (bigNumIncome <= 0 ? 0 : (aInc[i] / bigNumIncome) * 5),
          Color(colors[i]),
        ),
      );
    }

    itemsIncome.add(
      makeGroupDataIncome(lengthInc + 1 + 1, 0, const Color(0xffffffff)),
    );

    final itemsValue = [barGroupValue0];
    for (var i = 0; i < lengthVal; i++) {
      itemsValue.add(
        makeGroupDataValue(
          i + 1,
          (bigNumValue <= 0 ? 0 : (aVal[i] / bigNumValue) * 5) < 0
              ? 0
              : (bigNumValue <= 0 ? 0 : (aVal[i] / bigNumValue) * 5),
          Color(colors[i]),
        ),
      );
    }

    itemsValue.add(
      makeGroupDataValue(lengthVal + 1 + 1, 0, const Color(0xffffffff)),
    );

    rawBarGroupsIncome = itemsIncome;

    showingBarGroupsIncome = rawBarGroupsIncome;
    rawBarGroupsValue = itemsValue;

    showingBarGroupsValue = rawBarGroupsValue;
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

    Widget topMenu() => IconButton(
      icon: Image.asset('assets/images/menu_icon.png', width: 24, height: 24),
      onPressed: () async {
        dialogBox.waiting(context, "Opening");
        var url =
            "$baseUrl/app/portfolio/${widget.type.toLowerCase()}?archive=all";
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        var response = await dio.get(
          url,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Portarchives(response.data, widget.type),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );

    List listInc = [];
    if (bigNumIncome != 0) {
      for (var i = 0; i < 6; i++) {
        listInc.add((bigNumIncome / 5) * i);
      }
    } else {
      listInc = [0, 0, 0, 0, 0, 0];
    }

    List listVal = [];
    if (bigNumValue != 0) {
      for (var i = 0; i < 6; i++) {
        listVal.add((bigNumValue / 5) * i);
      }
    } else {
      listVal = [0, 0, 0, 0, 0, 0];
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [topMenu()],
      ),
      bottomNavigationBar: const BottomNav(3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            SizedBox(height: height * .03),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.type} Assets",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "View, edit and manage all your assets",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grayColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: height * .02),
                Text(
                  "Existing Assets".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * .015),
            existing.isEmpty
                ? Container(
                    color: Colors.grey[200],
                    height: height * .1,
                    child: Center(
                      child: Text(
                        "No Existing Assets Added Yet",
                        style: TextStyle(
                          fontSize: width * .05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Card(
                        elevation: 0,
                        color: const Color(0xfff7f7f7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(
                            color: Color(0xffD8D8D8),
                            width: 1.5,
                          ),
                        ),
                        child: SizedBox(
                          height: height * .25,
                          child: Column(
                            children: [
                              // getData(id),
                              Expanded(
                                child: BraidListItem(
                                  existing: existing,
                                  type: widget.type,
                                ),
                              ),
                              const Divider(
                                color: AppColors.grayColor,
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/value_icon.png',
                                          width: width * .04,
                                        ),
                                        SizedBox(width: width * .02),
                                        const Text(
                                          'Value',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.grayColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/income_icon.png',
                                          width: width * .04,
                                        ),
                                        SizedBox(width: width * .02),
                                        const Text(
                                          'Income',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.grayColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: height * .02),

            existing.isEmpty
                ? Container()
                : Row(
                    children: [
                      Text(
                        'Portfolio Value'.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * .04,
                          color: Colors.black,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),

            fromInvestment360!
                ? Container()
                : existing.isEmpty
                ? Container()
                : PortfolioValueChart(
                    data: widget.data,
                    labelsAsset: lablesAsset,
                    showingBarGroups: showingBarGroupsIncome,
                  ),

            // fromInvestment360?
            //   Container()
            //   :
            SizedBox(height: height * .01),
            existing.isEmpty
                ? Container()
                : Row(
                    children: [
                      Text(
                        'Portfolio Income'.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * .04,
                          color: Colors.black,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
            existing.isEmpty
                ? Container()
                : Column(
                    children: [
                      SizedBox(height: height * .01),
                      fromInvestment360!
                          ? PortfolioIncomeChart(
                              data: widget.data,
                              labelsAsset: lablesAsset,
                              showingBarGroups: showingBarGroupsValue,
                              small: widget.type,
                            )
                          : Detailsvaluechart(
                              labelsAsset: lablesAsset,
                              data: widget.data,
                              showingBarGroups: showingBarGroupsValue,
                            ),
                    ],
                  ),
            SizedBox(height: height * .02),
          ],
        ),
      ),
    );
  }

  getData(String id) async {
    var type = widget.type.toLowerCase();
    Timer timer = Timer(const Duration(seconds: 40), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    // print(response.statusCode);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Braiditem(data: jsonDecode(response.body)),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }

  BarChartGroupData makeGroupDataIncome(int x, double y1, Color barColor) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: barColor,
          width: width,
        ),
      ],
    );
  }

  BarChartGroupData makeGroupDataValue(int x, double y1, Color barColor) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: barColor,
          width: width,
        ),
      ],
    );
  }
}
