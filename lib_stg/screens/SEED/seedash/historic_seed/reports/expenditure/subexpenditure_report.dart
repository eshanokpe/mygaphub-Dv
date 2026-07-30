import 'dart:convert';

import 'package:GapHub/models/expenReport.dart';
import 'package:GapHub/screens/SEED/seedash/historic_seed/reports/periodicData.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:shared_preferences/shared_preferences.dart';

import 'viewReportchartexpenditure.dart';

class SubExpenditureReport extends StatefulWidget {
  final Map<String, dynamic> data;
  final String label;
  final String expenditure;
  final List<dynamic> list;
  final String historicdate;
  final String date;

  const SubExpenditureReport({
    super.key,
    required this.data,
    required this.label,
    required this.expenditure,
    required this.list,
    required this.historicdate,
    required this.date,
  });

  @override
  State<StatefulWidget> createState() {
    return SubExpenditureReportState();
  }
}

class SubExpenditureReportState extends State<SubExpenditureReport> {
  //List expenList;
  List<ExpenReport> item = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var expenList = widget.data["data"]['allocations'];

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Expenditure Summary',
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
                        color: const Color(0xffD13B56),
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
                    right: width * .0,
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
                                    toBeginningOfSentenceCase(
                                      '${widget.expenditure} ',
                                    )!,
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
                          child: expenList.isEmpty
                              ? Container()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: expenList.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                      right: width * .05,
                                      left: width * .05,
                                    ),
                                    child: Container(
                                      height: height * .09,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          /*  bottom: BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 196, 196, 196)), */
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
                                        // horizontalTitleGap: -10.0,
                                        contentPadding: EdgeInsets.only(
                                          right: width * .0,
                                          left: width * .0,
                                          top: height * .0,
                                        ),
                                        isThreeLine: true,
                                        onTap: () async {
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          var token = prefs.getString(
                                            'tokenDB',
                                          );
                                          var url = Uri.parse(
                                            "$baseUrl/app/seed/history/${widget.date}/expenditure?category=${widget.expenditure}&label=${expenList[index]["label"]}",
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
                                            var body = jsonDecode(
                                              response.body,
                                            );
                                            Map<String, dynamic> data =
                                                body['data']['label_report'];
                                            String title =
                                                body['data']['label'];
                                            print(data);
                                            String currency = context
                                                .read<Providers>()
                                                .snapshotmodel
                                                .currency;

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewReportChartExpenditure(
                                                      currency: currency,
                                                      data: data,
                                                      title: title,
                                                      date: widget.date,
                                                      historicdate:
                                                          widget.historicdate,
                                                      list: widget.list,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                        trailing: Column(
                                          children: [
                                            Text(
                                              '$currency${num.parse(expenList[index]["amount"].toString()).toStringAsFixed(2)}'
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
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
                                            ),
                                          ],
                                        ),
                                        leading: Container(
                                          height: width * .04,
                                          width: width * .04,
                                          margin: const EdgeInsets.only(top: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xffD13B56),
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
                                              color: const Color(0xffD13B56),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          toBeginningOfSentenceCase(
                                            "${expenList[index]["label"]}",
                                          )!,
                                          style: TextStyle(
                                            color: const Color(0xffD13B56),
                                            fontSize: width * .050,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            "$currency ${num.parse(expenList[index]["actual"].toString()).toStringAsFixed(2)} Actual",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: width * .040,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       right: width * .05, left: width * .05),
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //       border: Border(
                      //           top: BorderSide(
                      //               color: Color.fromARGB(255, 196, 196, 196))),
                      //     ),
                      //     child: Material(
                      //       color: Colors.transparent,
                      //       child: InkWell(
                      //         onTap: () {},
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(10),
                      //           child: OverflowBar(
                      //             overflowAlignment: OverflowBarAlignment.center,
                      //             children: <Widget>[
                      //               Row(
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: <Widget>[
                      //                   Text(
                      //                     'Click any of the items above to view more details ',
                      //                     style: TextStyle(
                      //                         color: Colors.black,
                      //                         fontSize: width * .03,
                      //                         fontWeight: FontWeight.w300),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
