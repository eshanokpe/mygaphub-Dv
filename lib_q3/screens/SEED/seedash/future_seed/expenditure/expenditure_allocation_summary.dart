import 'dart:convert';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'expenditure_allocation.dart';

class FSExpenditureAllocationSummary extends StatefulWidget {
  List<SavingAllexpenditure> data;
  FSExpenditureAllocationSummary({super.key, required this.data});

  @override
  State<FSExpenditureAllocationSummary> createState() =>
      _FSExpenditureAllocationSummaryState();
}

class _FSExpenditureAllocationSummaryState
    extends State<FSExpenditureAllocationSummary> {
  bool isLoading = false;
  int totalleft = 0;
  int? allocationid;
  var expenList;
  int? expen_length;

  @override
  // ignore: must_call_super
  void initState() {
    checkExpenditure();
  }

  //Check Expenditure Allocation Summary
  checkExpenditure() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var url2 = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=expenditure",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response2 = await http.get(
      url2,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    if (response2.statusCode == 200) {
      var body = jsonDecode(response2.body);
      var expendituredata = body["data"]['budget_expenditures'];
      int length = expendituredata.length;
      print('Expenditure:$length');
      setState(() {
        expen_length = length;
      });
      EasyLoading.dismiss();
    } else {}
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
          'SEED',
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Expenditure Allocation',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.065,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Summary',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.065,
                                        ),
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
                              top: Offset(screenWidth / 2, 30),
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
                        padding: EdgeInsets.only(
                          top: height * .25,
                          right: width * .05,
                          left: width * .05,
                        ),
                        child: Container(
                          //margin:  EdgeInsets.only(right:width * .05, left:width * .05),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              /* bottom: BorderSide(
                                color: Color.fromARGB(
                                        255, 196, 196, 196) 
                              ), */
                              top: BorderSide(
                                color: Color.fromARGB(255, 196, 196, 196),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .01,
                            vertical: height * .0,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: widget.data.length,
                            itemBuilder: (context, index) {
                              final item = widget.data[index];

                              return Container(
                                // margin:  EdgeInsets.only(right:width * .05, left:width * .05),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    /* bottom: BorderSide(
                                            color: Color.fromARGB(
                                                    255, 196, 196, 196) 
                                          ), */
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 196, 196, 196),
                                    ),
                                  ),
                                ),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: width * .03,
                                      left: width * .03,
                                    ),
                                    child: Container(
                                      height: height * .07,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * .02,
                                        vertical: height * .0,
                                      ),
                                      child: ListTile(
                                        // horizontalTitleGap: -10.0,
                                        contentPadding: EdgeInsets.only(
                                          right: width * .0,
                                          left: width * .0,
                                          top: height * .0,
                                        ),
                                        isThreeLine: true,
                                        leading: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 0.0,
                                          ),
                                          child: Container(
                                            height: width * .04,
                                            width: width * .04,
                                            margin: const EdgeInsets.only(
                                              top: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xffD13B56,
                                                  ),
                                                  blurRadius: 0,
                                                  offset: Offset(
                                                    width * .006,
                                                    width * .005,
                                                  ),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    width * .005,
                                                  ),
                                              border: Border.all(
                                                color: const Color(0xffD13B56),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Padding(
                                          padding: EdgeInsets.only(
                                            top: height * .0,
                                          ),
                                          child: item.label == "family"
                                              ? Text(
                                                  toBeginningOfSentenceCase(
                                                    'home and Family',
                                                  )!,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xffD13B56,
                                                    ),
                                                    fontSize: width * .050,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              : item.label == "debt_repayment"
                                              ? Text(
                                                  toBeginningOfSentenceCase(
                                                    'debt Repayment',
                                                  )!,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xffD13B56,
                                                    ),
                                                    fontSize: width * .050,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              : Text(
                                                  toBeginningOfSentenceCase(
                                                    item.label,
                                                  )!,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xffD13B56,
                                                    ),
                                                    fontSize: width * .050,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                        trailing: Text(
                                          '$currency${item.amount.toStringAsFixed(2)} '
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
                                        subtitle: Container(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Text(expenList.toString()),
                      expen_length == 5
                          ? Container()
                          : Container(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FSExpenditureAllocation(),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: OverflowBar(
                                      overflowAlignment:
                                          OverflowBarAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              "Add more",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
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
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * .01),
            ],
          ),
        ),
      ),
      /*  bottomNavigationBar: BottomAppBar(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ExpenditureAllocation()));
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: OverflowBar(
                overflowAlignment: OverflowBarAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Add more",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ), */
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
