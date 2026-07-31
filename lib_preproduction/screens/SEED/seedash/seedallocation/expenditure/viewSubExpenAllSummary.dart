import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'expenditure_allocation.dart';
import 'vew_detaila_expenditure_allocation.dart';

class ViewSubExpenAllSummary extends StatefulWidget {
  final Map data;
  final String label;
  final String expenditure;

  const ViewSubExpenAllSummary({
    super.key,
    required this.data,
    required this.label,
    required this.expenditure,
  });

  @override
  State<StatefulWidget> createState() {
    return ViewSubExpenAllSummaryState();
  }
}

class ViewSubExpenAllSummaryState extends State<ViewSubExpenAllSummary> {
  //List expenList;
  List<SavingAllserver> item = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var expenList = widget.data["data"]['budget_allocations'];

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
                                    // Handle specific cases first, then apply general capitalization
                                    toBeginningOfSentenceCase(
                                      widget.expenditure == 'family'
                                          ? 'home and Family' // Specific override for 'family'
                                          : widget.expenditure ==
                                                'debt_repayment'
                                          ? 'debt Repayment' // Specific override for 'debt_repayment'
                                          : widget
                                                .expenditure // Use the original string for other cases
                                                .replaceAll(
                                                  '_',
                                                  ' ',
                                                ), // Replace underscores with spaces for better readability
                                    )!, // Apply sentence case capitalization
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.width(.06),
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
                        padding: EdgeInsets.only(top: height * .25, bottom: 0),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .01,
                            vertical: height * .0,
                          ),
                          child: expenList.isEmpty
                              ? Container()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: expenList.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * .02,
                                    ),
                                    child: Container(
                                      height: height * .09,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * .02,
                                        vertical: height * .0,
                                      ),
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
                                        horizontalTitleGap: -10.0,
                                        contentPadding: EdgeInsets.only(
                                          right: width * .0,
                                          left: width * .0,
                                          top: height * .0,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewDetailExpenditureAllocation(
                                                    item: expenList,
                                                    index: index,
                                                  ),
                                            ),
                                          );
                                        },
                                        trailing: Text(
                                          '$currency${(num.tryParse(expenList[index]["amount"]) ?? 0).toStringAsFixed(2)}'
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
                                        isThreeLine: true,
                                        leading: Container(
                                          height: width * .04,
                                          width: width * .04,
                                          margin: EdgeInsets.only(
                                            top: 5,
                                            right: width * .08,
                                          ),
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
                                        subtitle: Text(
                                          "$currency ${expenList[index]["summary"]["total_left"].toStringAsFixed(2) ?? 0} Balance",
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ExpenditureAllocation(),
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
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      /* bottomNavigationBar: BottomAppBar(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpenditureAllocation()));
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
