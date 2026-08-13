import 'dart:convert';

import 'package:GapHub/models/historicseddReport.dart';
import 'package:GapHub/screens/SEED/seedash/historic_seed/reports/periodicData.dart';
import 'package:GapHub/screens/SEED/seedash/historic_seed/reports/savings/viewhistoricReportChart.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class SavingsReport extends StatefulWidget {
  List<HistoricSeedReport> data;
  List list;
  String historicdate;
  final date;
  SavingsReport({
    super.key,
    required this.data,
    required this.list,
    required this.historicdate,
    this.date,
  });

  @override
  State<SavingsReport> createState() => _SavingsReportState();
}

class _SavingsReportState extends State<SavingsReport> {
  //List<SavingAllserver> _data;
  bool isLoading = false;
  int totalleft = 0;
  int allocationid = 0;

  @override
  // ignore: must_call_super
  void initState() {
    // print("allocationidd:$allocationid");
    //fectchAllocation();
  }

  @override
  Widget build(BuildContext context) {
    var savingAllocationList = context.watch<Providers>().savingAllocationList;
    double screenWidth = MediaQuery.of(context).size.width;
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Colors.blue.withOpacity(.05),
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
      body: Container(
        color: Colors.blue.withOpacity(.05),
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * .03),
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
                        color: const Color(0xff00B050),
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
                    top: height * .04,
                    left: width * .04,
                    right: width * .04,
                    child: Center(
                      child: SizedBox(
                        width: width * .88,
                        height: height * .10,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: height * .00,
                            right: width * .10,
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    'Savings Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.width(.07),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.width(.07),
                                    ),
                                  ),
                                ),
                              ],
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
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: height * .15),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .01,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: widget.data.length,
                            itemBuilder: (context, index) {
                              final item = widget.data[index];

                              allocationid = item.id;
                              print("allocationid:$allocationid");
                              fectchAllocation() async {
                                EasyLoading.show(
                                  status: 'Loading',
                                  dismissOnTap: false,
                                );
                                final allocationUrl = Uri.parse(
                                  "$baseUrl/app/seed/allocate/$allocationid",
                                );
                                final prefs =
                                    await SharedPreferences.getInstance();
                                var token = prefs.getString('tokenDB');
                                Response response = await Dio().get(
                                  '$allocationUrl',
                                  options: Options(
                                    headers: {
                                      "Authorization": 'Bearer $token',
                                      "Content-Type": 'appllication/json',
                                    },
                                  ),
                                  queryParameters: {
                                    'allocation_id': '$allocationid',
                                  },
                                );
                                if (response.statusCode == 200) {
                                  var body = response.data;
                                  // print('body: $body');
                                  var records = body["data"]['summary'];
                                  var totalspent = records['total_spent'];
                                  //var totalspent = records['total_spent'];
                                  print('totalspent: $totalspent');

                                  var left = records['total_left'];
                                  EasyLoading.dismiss();
                                  setState(() {
                                    totalleft = left;
                                  });
                                  //left = totalleft;

                                  print('totalleft: $totalleft');
                                  return totalleft;
                                }
                              }

                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Container(
                                  height: height * .09,
                                  margin: EdgeInsets.only(
                                    right: width * .03,
                                    left: width * .03,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * .02,
                                    vertical: height * .0,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Color.fromARGB(
                                          255,
                                          196,
                                          196,
                                          196,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    horizontalTitleGap: 0.0,
                                    contentPadding: EdgeInsets.only(
                                      right: width * .0,
                                      left: width * .0,
                                    ),
                                    onTap: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      var token = prefs.getString('tokenDB');
                                      var url = Uri.parse(
                                        "$baseUrl/app/seed/history/${widget.date}/savings?label=${item.label}",
                                      );
                                      var response = await http.get(
                                        url,
                                        headers: {
                                          "Authorization": 'Bearer $token',
                                          "Accept": "application/json",
                                          "Content-Type":
                                              "application/x-www-form-urlencoded",
                                        },
                                      );
                                      if (response.statusCode == 200) {
                                        var body = jsonDecode(response.body);
                                        Map<String, dynamic> data =
                                            body['data']['label_report'];
                                        String title = body['data']['label'];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewHistoricReportChart(
                                                  // actual: actuals,
                                                  title: title,
                                                  //budget: budgets,
                                                  data: data,
                                                  date: widget.date,
                                                  historicdate:
                                                      widget.historicdate,
                                                  list: widget.list,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    isThreeLine: true,
                                    leading: Container(
                                      height: width * .04,
                                      width: width * .04,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff00B050),
                                            blurRadius: 0,
                                            offset: Offset(
                                              width * .006,
                                              width * .005,
                                            ),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                          width * .005,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xff00B050),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: width * .050,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: Column(
                                      children: [
                                        Text(
                                          '$currency${num.parse(item.amount.toString()).toStringAsFixed(2)} '
                                              .replaceAllMapped(
                                                RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                ),
                                                (Match m) => '${m[1]},',
                                              ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: width * .040,
                                            // fontSize: context.width(.055),
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          'Budget'.replaceAllMapped(
                                            RegExp(
                                              r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                            ),
                                            (Match m) => '${m[1]},',
                                          ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: width * .040,
                                            // fontSize: context.width(.055),
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      "$currency ${num.parse(item.actual.toString()).toStringAsFixed(2)} Actual",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: width * .040,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: width * .05,
                          left: width * .05,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color.fromARGB(255, 196, 196, 196),
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Navigator.of(context).pushNamed('SavingAllocation');
                                /*  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SavingAllocation())); */
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: OverflowBar(
                                  overflowAlignment:
                                      OverflowBarAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: height * .05),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    'Click on any of the items above to view the chart ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: width * .03,
                                                  fontWeight: FontWeight.w300,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * .01),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSelfClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    BezierCurveSection section1 = BezierCurveSection(
      start: const Offset(0, 30),
      top: const Offset(10, 45),
      end: const Offset(0, 60),
    );
    BezierCurveSection section2 = BezierCurveSection(
      start: Offset(size.width, size.height - 90),
      top: Offset(size.width - 10, size.height - 105),
      end: Offset(size.width, size.height - 120),
    );
    BezierCurveDots dot1 = ProsteBezierCurve.calcCurveDots(section1);
    BezierCurveDots dot2 = ProsteBezierCurve.calcCurveDots(section2);

    path.lineTo(0, 0);
    path.lineTo(0, 30);
    path.quadraticBezierTo(dot1.x1, dot1.y1, dot1.x2, dot1.y2);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - 90);
    path.quadraticBezierTo(dot2.x1, dot2.y1, dot2.x2, dot2.y2);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class CustomSelfClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    BezierCurveSection section1 = BezierCurveSection(
      start: Offset(0, size.height),
      top: Offset(30, size.height - 50),
      end: Offset(80, size.height - 70),
    );
    BezierCurveSection section2 = BezierCurveSection(
      start: Offset(size.width - 100, size.height - 70),
      top: Offset(size.width - 30, size.height - 95),
      end: Offset(size.width, size.height - 160),
    );
    BezierCurveDots dot1 = ProsteBezierCurve.calcCurveDots(section1);
    BezierCurveDots dot2 = ProsteBezierCurve.calcCurveDots(section2);

    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(dot1.x1, dot1.y1, dot1.x2, dot1.y2);
    path.lineTo(size.width - 100, size.height - 70);
    path.quadraticBezierTo(dot2.x1, dot2.y1, dot2.x2, dot2.y2);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
