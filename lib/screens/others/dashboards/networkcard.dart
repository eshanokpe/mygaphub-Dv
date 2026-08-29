import 'dart:async';
import 'package:GapHub/screens/360/accounts/networth/networth.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/screens/360/accounts/networth/networthdetails.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dashboard.dart';

class Networthcard extends StatefulWidget {
  final double height;
  final double width;
  final String currency;
  final Map netData;
  final List<charts.Series<Networths, String>> seriesBarData;

  const Networthcard({
    super.key,
    required this.height,
    required this.currency,
    required this.netData,
    required this.width,
    required this.seriesBarData,
  });

  @override
  _NetworthcardState createState() => _NetworthcardState();
}

class _NetworthcardState extends State<Networthcard> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  bool? contains;
  @override
  Widget build(BuildContext context) {
    // final assets = widget.netData['values'][0];
    // final liabilities = widget.netData['values'][1];
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Map dashData = context.read<Providers>().dashdata;
    Map netData = dashData["net_detail"] ?? {};
    // Safely extract values with fallbacks
    final assets = netData["values"] != null && netData["values"].length > 0
        ? netData["values"][0]
        : 0.0;
    final liabilities =
        netData["values"] != null && netData["values"].length > 1
        ? netData["values"][1]
        : 0.0;
    final total = netData["sum"] ?? 0.0;

    var colors = context.watch<Providers>().sevengeemodel.backgrounds;
    List<String> sevenGeesColor = [];
    List<String> sevenGeesColors = [];
    List<int> realColors = [];
    for (var a in colors) {
      sevenGeesColor.add(a.toString().substring(1));
    }

    for (var a in sevenGeesColor) {
      sevenGeesColors.add('0xff$a');
    }
    for (var a in sevenGeesColors) {
      realColors.add(int.parse(a));
    }
    contains = realColors.contains(0xff494949);

    // final total = widget.netData["sum"];

    return Column(
      children: [
        RowViewDetails(
          mainText: 'Net worth',
          detailText: 'View Details',
          onTap: () => networth(currency),
          arrowTap: true,
        ),
        SizedBox(height: widget.height * .02),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
              color: Color.fromARGB(255, 241, 241, 241),
              width: 1.5,
            ),
          ),
          color: const Color.fromARGB(255, 253, 253, 253),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: widget.width * .01),
            width: widget.width,
            child: Column(
              children: [
                SizedBox(height: widget.height * .02),
                widget.seriesBarData.any(
                      (series) => series.data.any((data) => data.value > 1),
                    )
                    ? Container(
                        height: widget.height * .2,
                        width: widget.width,
                        alignment: Alignment.center,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.start,
                            barGroups: generateBarGroups(widget.seriesBarData),
                            titlesData: const FlTitlesData(
                              show: false, // Hide axis labels and titles
                            ),
                            borderData: FlBorderData(
                              show: false, // Remove borders around the chart
                            ),
                            gridData: const FlGridData(
                              show: false, // Hide grid lines
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: widget.height * .02),
                widget.seriesBarData.any(
                      (series) => series.data.any((data) => data.value > 1),
                    )
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xff7E9CA8),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              SizedBox(width: widget.width * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Assets',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: const Color(0xff272727),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: widget.height * 0.005),
                                  Text(
                                    '${widget.currency}${assets.toStringAsFixed(2)}'
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    204,
                                    211,
                                    202,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              SizedBox(width: widget.width * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Liabilities',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: const Color(0xff272727),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    '${widget.currency}${liabilities.toStringAsFixed(2)}'
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xff7E9CA8),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              SizedBox(width: widget.width * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Assets',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: const Color(0xff272727),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: widget.height * 0.005),
                                  Text(
                                    '${widget.currency}${assets.toStringAsFixed(2)}'
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    204,
                                    211,
                                    202,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              SizedBox(width: widget.width * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Liabilities',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: const Color(0xff272727),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    '${widget.currency}${liabilities.toStringAsFixed(2)}'
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: widget.height * 0.03),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.width * 0.02,
                    0,
                    widget.width * 0.02,
                    0,
                  ),
                  child: Card(
                    elevation: 0,
                    color: const Color.fromARGB(255, 247, 247, 247),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 241, 241, 241),
                        width: 1.5,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.width * 0.05,
                        vertical: widget.height * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/rec_infor.png',
                                width: 18,
                                height: 18,
                              ),
                              SizedBox(width: widget.width * 0.02),
                              Text(
                                'Total Net Worth',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff808080),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${widget.currency}${total.toStringAsFixed(2)}'
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: widget.height * .03),
              ],
            ),
          ),
        ),
        SizedBox(height: widget.height * .02),
      ],
    );
  }

  List<BarChartGroupData> generateBarGroups(
    List<charts.Series<Networths, String>> seriesBarData,
  ) {
    return seriesBarData.asMap().entries.map((entry) {
      int index = entry.key;
      charts.Series<Networths, String> series = entry.value;
      List<BarChartRodData> rods = [];
      // Add the BarChartRodData to the list in reverse order
      for (var data in series.data) {
        Color barColor = colorFromString(data.colorVal);
        rods.add(
          BarChartRodData(
            fromY: 0,
            toY: data.value.toDouble(),
            color: barColor,
            width: widget.width * .35, // Set bar width to eliminate gaps
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), // Rounded top-left corner
              topRight: Radius.circular(24), // Rounded top-right corner
            ),
          ),
        );
      }
      List<BarChartRodData> reorderedRods = [
        rods[0],
        rods.length > 1 ? rods[1] : null,
      ].whereType<BarChartRodData>().toList();

      return BarChartGroupData(
        x: index,
        barRods: reorderedRods,
        barsSpace: -15,
      );
    }).toList();
  }

  Color colorFromString(String colorString) {
    return Color(int.parse(colorString.replaceFirst('#', '0xff')));
  }

  networth(String currency) async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/net";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    // Navigator.pop(context);
    // Navigator.pop(context);
    if (int.tryParse(response.data["isNet"]["net_confirm"]) == 0) {
      print("statusCode:${response.data["isNet"]["net_confirm"]}");
      Navigator.pop(context);
      timer.cancel();
      navigateWithSlideTransition(
        context: context,
        destinationScreen: Networth(item: response.data),
        transitionDuration: const Duration(milliseconds: 200),
      );
    } else if (int.tryParse(response.data["isNet"]["net_confirm"]) == 1) {
      Navigator.pop(context);
      timer.cancel();
      print("contains:$contains");
      if (contains!) {
        dropdown(context);
      } else {
        navigateWithSlideTransition(
          context: context,
          destinationScreen: Networthdetails(
            item: response.data,
            currency: currency,
          ),
          transitionDuration: const Duration(milliseconds: 200),
        );
      }
    }
  }

  void dropdown(BuildContext context) {
    showDialog(context: context, builder: (context) => const SelectSevenG());
  }
}

class SelectSevenG extends StatelessWidget {
  const SelectSevenG({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.only(top: width * .01),
      elevation: 5,
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .01,
              ),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Kindly validate all your 7G assumptions in order to view your 360°",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: height * .03),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(index: 1),
                        ),
                      );
                    },
                    child: Text(
                      "Navigate to Analytics page now",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        fontSize: 14.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
