import 'package:GapHub/screens/360/iLAB/settarget.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/semi_circle.dart';
import 'package:flutter/material.dart';
import 'gapanalysis.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class Ilab extends StatefulWidget {
  const Ilab({super.key});

  @override
  _IlabState createState() => _IlabState();
}

class _IlabState extends State<Ilab> {
  bool switc = false;
  Map data = {};
  bool expenTick0 = true;
  bool invTick0 = true;
  bool equTick0 = true;
  bool savTick0 = true;
  bool creTick0 = true;
  bool mortTick0 = true;
  bool npTick0 = true;
  bool portTick0 = true;
  bool eduTick0 = true;
  bool perTick0 = true;
  bool discTick0 = true;
  bool expenTick1 = true;
  bool invTick1 = true;
  bool equTick1 = true;
  bool savTick1 = true;
  bool creTick1 = true;
  bool mortTick1 = true;
  bool npTick1 = true;
  bool portTick1 = true;
  bool eduTick1 = true;
  bool perTick1 = true;
  bool discTick1 = true;
  List b = [];

  @override
  @override
  void initState() {
    super.initState();
    setState(() {
      data = context.read<Providers>().ilabdata;
    });
    Map a = data["ilab"];
    b = a.values.toList();
    print("b ${b.toString()}");
    if (b.length >= 17) {
      b.removeRange(0, 2);
      b.removeRange(11, 15);
    }
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
    var wheelWidth = width;
    if (width < 390) {
      wheelWidth = width - 35;
    }

    print(width);

    String currency = context.watch<Providers>().snapshotmodel.currency;

    var investment0 = invTick0
        ? (int.tryParse(data["current_ilab"]["investment"].toString()) ?? 0)
        : 0;

    var equity0 = equTick0
        ? (int.tryParse(data["current_ilab"]["equity"].toString()) ?? 0)
        : 0;

    var savings0 = savTick0
        ? (num.tryParse(data["current_ilab"]["savings"].toString()) ?? 0)
        : 0;

    num assetTotal0 = investment0 + equity0 + savings0;

    var credit0 = creTick0 ? (data["current_ilab"]["credit"] ?? 0) : 0;
    var mortgage0 = mortTick0 ? (data["current_ilab"]["mortgage"] ?? 0) : 0;
    var liabilityTotal0 = credit0 + mortgage0;

    var nonP0 = npTick0 ? (data["current_ilab"]["non_portfolio"] ?? 0) : 0;
    var port0 = portTick0 ? (data["current_ilab"]["portfolio"] ?? 0) : 0;
    var incomeTotal0 = nonP0 + port0;

    var periodic0 = perTick0
        ? (data["current_ilab"]["periodic_saving"] ?? 0)
        : 0;
    var education0 = eduTick0 ? (data["current_ilab"]["education"] ?? 0) : 0;
    var expenditure0 = expenTick0
        ? (data["current_ilab"]["expenditure"] ?? 0)
        : 0;
    var discretionary0 = discTick0
        ? (data["current_ilab"]["discretionary"] ?? 0)
        : 0;
    var budget0 = periodic0 + education0 + expenditure0 + discretionary0;

    var investment1 = invTick1 ? (data["ilab"]["investment"] ?? 0) : '0';
    var equity1 = equTick1 ? (data["ilab"]["equity"] ?? 0) : '0';
    var savings1 = savTick1 ? (data["ilab"]["savings"] ?? 0) : '0';
    var assetTotal1 = investment1 + equity1 + savings1;

    var credit1 = creTick1 ? (data["ilab"]["credit"] ?? 0) : '0';
    var mortgage1 = mortTick1 ? (data["ilab"]["mortgage"] ?? 0) : '0';
    var liabilityTotal1 = credit1 + mortgage1;

    var nonP1 = npTick1 ? (data["ilab"]["non_portfolio"] ?? 0) : '0';
    var port1 = portTick1 ? (data["ilab"]["asset_portfolio"] ?? 0) : '0';
    var incomeTotal1 = nonP1 + port1;

    var periodic1 = perTick1 ? (data["ilab"]["periodic_savings"] ?? 0) : '0';
    var education1 = eduTick1 ? (data["ilab"]["education"] ?? 0) : '0';
    var expenditure1 = expenTick1 ? (data["ilab"]["expenditure"] ?? 0) : '0';
    var discretionary1 = discTick1 ? (data["ilab"]["discretionary"] ?? 0) : '0';
    var budget1 = periodic1 + education1 + expenditure1 + discretionary1;
    num getNumValue(dynamic value) {
      if (value is String) {
        return num.tryParse(value) ??
            0; // Try to parse String to num, default to 0
      }
      return value is num ? value : 0; // If it's already num, return it
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "360 iLAB Clock",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * .035),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: height * .01),
              Text(
                "Play with your iLAB Clock",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  // decoration: TextDecoration.underline,
                  fontSize: width * .06,
                ),
              ),
              SizedBox(height: height * .04),
              Text(
                "Current Position: ${DateTime.now().year}".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  fontSize: width * .04,
                ),
              ),
              SizedBox(height: height * .01),
              Container(
                child: Column(
                  children: [
                    Text(
                      "12",
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xffe28394),
                                        circleAlignment:
                                            CircleAlignment.bottomRight,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: width * .05),
                                        Text(
                                          "ASSET",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: width * .03),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  invTick0 = !invTick0;
                                                });
                                              },
                                              child: Icon(
                                                invTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Investments",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  equTick0 = !equTick0;
                                                });
                                              },
                                              child: Icon(
                                                equTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Home Equity",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  savTick0 = !savTick0;
                                                });
                                              },
                                              child: Icon(
                                                savTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Cash",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .02),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$assetTotal0"
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                ),
                                            style: TextStyle(
                                              fontSize:
                                                  assetTotal0
                                                          .toString()
                                                          .length <
                                                      8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: width * .01),
                                Stack(
                                  alignment: AlignmentDirectional.centerStart,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xff77a2bb),
                                        circleAlignment:
                                            CircleAlignment.bottomLeft,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: width * .05),
                                        Text(
                                          "LIABILITIES",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: width * .03),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  creTick0 = !creTick0;
                                                });
                                              },
                                              child: Icon(
                                                creTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Credit",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  mortTick0 = !mortTick0;
                                                });
                                              },
                                              child: Icon(
                                                mortTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Mortgage",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .02),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$liabilityTotal0"
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                ),
                                            style: TextStyle(
                                              fontSize:
                                                  liabilityTotal0
                                                          .toString()
                                                          .length <
                                                      8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: width * .01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xffd77dd6),
                                        circleAlignment:
                                            CircleAlignment.topRight,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "INCOME",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: width * .02),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  npTick0 = !npTick0;
                                                });
                                              },
                                              child: Icon(
                                                npTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Non-Portfolio",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  portTick0 = !portTick0;
                                                });
                                              },
                                              child: Icon(
                                                portTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Portfolio",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .02),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$incomeTotal0"
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                ),
                                            style: TextStyle(
                                              fontSize:
                                                  incomeTotal0
                                                          .toString()
                                                          .length <
                                                      8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: width * .01),
                                Stack(
                                  alignment: AlignmentDirectional.topStart,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xff8879ca),
                                        circleAlignment:
                                            CircleAlignment.topLeft,
                                      ),
                                    ),
                                    Column(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "BUDGET",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .045,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  perTick0 = !perTick0;
                                                });
                                              },
                                              child: Icon(
                                                perTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Savings Periodic",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  eduTick0 = !eduTick0;
                                                });
                                              },
                                              child: Icon(
                                                eduTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Education",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  expenTick0 = !expenTick0;
                                                });
                                              },
                                              child: Icon(
                                                expenTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Expenditure",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  discTick0 = !discTick0;
                                                });
                                              },
                                              child: Icon(
                                                discTick0
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Discretionary",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .01),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$budget0".replaceAllMapped(
                                              RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                              ),
                                              (Match m) => '${m[1]},',
                                            ),
                                            style: TextStyle(
                                              fontSize:
                                                  budget0.toString().length < 8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .005,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "9",
                                style: TextStyle(
                                  fontSize: width * .05,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "3",
                                style: TextStyle(
                                  fontSize: width * .05,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "6",
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .05),
              Text(
                "GAP ANALYSIS",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  fontSize: width * .05,
                ),
              ),
              SizedBox(height: height * .01),
              DiffTable(
                width: width,
                npi: getNumValue(nonP0) - getNumValue(nonP1),
                api: getNumValue(port0) - getNumValue(port1),
                lia:
                    getNumValue(liabilityTotal1) - getNumValue(liabilityTotal0),
                asset: getNumValue(assetTotal0) - getNumValue(assetTotal1),
                budget: getNumValue(budget1) - getNumValue(budget0),
              ),
              SizedBox(height: height * .07),
              Text(
                "Target Position: ${data["ilab"]["other"]}".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  fontSize: width * .04,
                ),
              ),
              SizedBox(height: height * .01),
              Container(
                child: Column(
                  children: [
                    Text(
                      "12",
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xffe28394),
                                        circleAlignment:
                                            CircleAlignment.bottomRight,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: width * .05),
                                        Text(
                                          "ASSET",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: width * .03),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  invTick1 = !invTick1;
                                                });
                                              },
                                              child: Icon(
                                                invTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Investment",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  equTick1 = !equTick1;
                                                });
                                              },
                                              child: Icon(
                                                equTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Home Equity",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  savTick1 = !savTick1;
                                                });
                                              },
                                              child: Icon(
                                                savTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Cash",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .02),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$assetTotal1"
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                ),
                                            style: TextStyle(
                                              fontSize:
                                                  assetTotal1
                                                          .toString()
                                                          .length <
                                                      8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: width * .01),
                                Stack(
                                  alignment: AlignmentDirectional.centerStart,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xff77a2bb),
                                        circleAlignment:
                                            CircleAlignment.bottomLeft,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: width * .05),
                                        Text(
                                          "LIABILITIES",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: width * .03),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  creTick1 = !creTick1;
                                                });
                                              },
                                              child: Icon(
                                                creTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Credit",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  mortTick1 = !mortTick1;
                                                });
                                              },
                                              child: Icon(
                                                mortTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Mortgage",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .02),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$liabilityTotal1"
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                ),
                                            style: TextStyle(
                                              fontSize:
                                                  liabilityTotal1
                                                          .toString()
                                                          .length <
                                                      8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: width * .01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xffd77dd6),
                                        circleAlignment:
                                            CircleAlignment.topRight,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "INCOME",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .05,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: width * .02),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  npTick1 = !npTick1;
                                                });
                                              },
                                              child: Icon(
                                                npTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Non-Portfolio",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  portTick1 = !portTick1;
                                                });
                                              },
                                              child: Icon(
                                                portTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Portfolio",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .02),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$incomeTotal1"
                                                .replaceAllMapped(
                                                  RegExp(
                                                    r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                  ),
                                                  (Match m) => '${m[1]},',
                                                ),
                                            style: TextStyle(
                                              fontSize:
                                                  incomeTotal1
                                                          .toString()
                                                          .length <
                                                      8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: width * .01),
                                Stack(
                                  alignment: AlignmentDirectional.topStart,
                                  children: [
                                    SizedBox(
                                      height: width * .45,
                                      width: width * .45,
                                      child: const QuarterCircle(
                                        color: Color(0xff8879ca),
                                        circleAlignment:
                                            CircleAlignment.topLeft,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "BUDGET",
                                          style: TextStyle(
                                            fontSize: wheelWidth * .045,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  perTick1 = !perTick1;
                                                });
                                              },
                                              child: Icon(
                                                perTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Savings Periodic",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  eduTick1 = !eduTick1;
                                                });
                                              },
                                              child: Icon(
                                                eduTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Education",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  expenTick1 = !expenTick1;
                                                });
                                              },
                                              child: Icon(
                                                expenTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Expenditure",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  discTick1 = !discTick1;
                                                });
                                              },
                                              child: Icon(
                                                discTick1
                                                    ? Icons.check_box_rounded
                                                    : Icons.check_box_outlined,
                                                size: width * .06,
                                              ),
                                            ),
                                            Text(
                                              "Discretionary",
                                              style: TextStyle(
                                                fontSize: wheelWidth * .03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: width * .01),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                          ),
                                          child: Text(
                                            "$currency$budget1".replaceAllMapped(
                                              RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                              ),
                                              (Match m) => '${m[1]},',
                                            ),
                                            style: TextStyle(
                                              fontSize:
                                                  budget1.toString().length < 8
                                                  ? wheelWidth * .045
                                                  : wheelWidth * .035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .005,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "9",
                                style: TextStyle(
                                  fontSize: width * .05,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "3",
                                style: TextStyle(
                                  fontSize: width * .05,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "6",
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .02),
                  ),
                ),
                onPressed: () {
                  context.read<Providers>().setSettarget(data);
                  // Navigator.of(context).pushNamed("Settarget");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settarget()),
                  );
                },
                child: Text(
                  b.any((element) => element == 0)
                      ? "Set Target"
                      : "Edit Target",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * .04,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .02),
            ],
          ),
        ),
      ),
    );
  }
}
