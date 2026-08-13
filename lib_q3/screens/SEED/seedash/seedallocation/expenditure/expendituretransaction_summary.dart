import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/screens/SEED/seedash/seedallocation/record_spend/recordspend.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'expenditure_allocation_summary.dart';
import 'expenditureditTransaction.dart';

class ExpenditureTransactionSummary extends StatefulWidget {
  String label;
  String label2;
  var balance;
  String date;
  String note;
  int id;
  var amount;
  var recuring;
  var allocation_id;
  var spent_current_month;
  var spent_last_month;
  ExpenditureTransactionSummary({
    super.key,
    this.allocation_id,
    required this.id,
    required this.label,
    required this.note,
    required this.balance,
    required this.date,
    required this.label2,
    this.amount,
    this.spent_current_month,
    this.spent_last_month,
    this.recuring,
  });

  @override
  State<ExpenditureTransactionSummary> createState() =>
      _ExpenditureTransactionSummaryState();
}

class _ExpenditureTransactionSummaryState
    extends State<ExpenditureTransactionSummary> {
  var d = DateFormat.yMMMEd();
  List<SavingAllexpenditure> _dataExpen = [];

  @override
  void initState() {
    super.initState();
    var id = widget.id;
    print('id:$id');
  }

  void _delete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Delete Account'),
          content: const Text(
            'Are you sure you want to delete this record spent?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                var id = widget.id;
                Navigator.of(context).pop();
                var timer = Timer(const Duration(milliseconds: 30000), () {
                  Navigator.pop(context);
                  dialogBox.information(context, 'Status', 'Service timed out');
                  return;
                });
                dialogBox.waiting(context, 'Loading');
                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('tokenDB');
                var url = Uri.parse("$baseUrl/app/seed/record/spent/$id");
                var urlSA = Uri.parse(
                  "$baseUrl/app/seed/allocate/budget?category=expenditure",
                );
                var response = await http.delete(
                  url,
                  headers: {"Authorization": 'Bearer $token'},
                );
                if (response.statusCode == 200) {
                  var response2 = await http.get(
                    urlSA,
                    headers: {
                      "Authorization": 'Bearer $token',
                      "Accept": "application/json",
                      "Content-Type": "application/x-www-form-urlencoded",
                    },
                  );
                  if (response2.statusCode == 200) {
                    var body = jsonDecode(response2.body);
                    var savingsdata = body["data"]['budget_allocations'];
                    int length = savingsdata.length;
                    print('Savings:$length');
                    if (length >= 1) {
                      var data = body["data"]['budget_expenditures'];
                      List res = data;
                      setState(() {
                        _dataExpen = res
                            .map(
                              (dataExpen) =>
                                  SavingAllexpenditure.fromJson(dataExpen),
                            )
                            .toList();
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenditureAllocationSummary(data: _dataExpen),
                        ),
                      );

                      timer.cancel();
                      Fluttertoast.showToast(
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        msg: 'Record Spent has been Deleted',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                } else {
                  timer.cancel();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Something went wrong',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              isDefaultAction: true,
              isDestructiveAction: true,
              child: const Text('Yes'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              isDefaultAction: false,
              isDestructiveAction: false,
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Balance',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: width * .035,
              ),
            ),
            Text(
              '$currency${widget.allocation_id != null ? widget.balance : '300'}',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: width * .04,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var url = Uri.parse("$baseUrl/app/seed");
              var timer = Timer(const Duration(milliseconds: 20000), () {
                Navigator.pop(context);
                dialogBox.information(context, 'Status', 'Service timed out');
                return;
              });
              dialogBox.waiting(context, 'Loading');
              final prefs = await SharedPreferences.getInstance();
              var token = prefs.getString('tokenDB');
              var response = await http.get(
                url,
                headers: {"Authorization": 'Bearer $token'},
              );
              if (response.statusCode == 200) {
                var body = jsonDecode(response.body);

                context.read<Providers>().setSeeData(body);
                timer.cancel();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordSpend(true)),
                );
              } else {
                timer.cancel();
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_down_sharp,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          //duration: const Duration(milliseconds: 500),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(
                  132,
                  0,
                  0,
                  0,
                ), // the color of a shadow, you can adjust it
                spreadRadius:
                    3, //also play with this two values to achieve your ideal result
                blurRadius: 7,
                offset: Offset(
                  0,
                  -7,
                ), // changes position of shadow, negative value on y-axis makes it appering only on the top of a container
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: height * .01, left: width * .02),
                child: Padding(
                  padding: EdgeInsets.only(bottom: height * .01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.close,
                            size: 20.0,
                            color: Color.fromRGBO(0, 0, 0, 0.411),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 3,
                            width: 30,
                            color: Colors.black26,
                          ),
                        ),
                      ),
                      SizedBox(height: 3, width: 30, child: Container()),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width * .05, right: width * .05),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.black,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(
                            132,
                            0,
                            0,
                            0,
                          ), // the color of a shadow, you can adjust it
                          spreadRadius:
                              3, //also play with this two values to achieve your ideal result
                          blurRadius: 7,
                          offset: Offset(
                            0,
                            -1,
                          ), // changes position of shadow, negative value on y-axis makes it appering only on the top of a container
                        ),
                      ],
                      color: const Color.fromARGB(255, 242, 242, 242),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // alignment: Alignment.center,
                    height: height * .19,
                    // width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: width * .03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.of(context).pushNamed("EditExpenditureTransactionSummary");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditExpenditureTransactionSummary(
                                              amount: widget.amount,
                                              label: widget.label,
                                              date: widget.date,
                                              note: widget.note,
                                              id: widget.id,
                                              recuring: widget.recuring,
                                              allocationid:
                                                  widget.allocation_id,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20.0,
                                    color: Color.fromRGBO(0, 0, 0, 0.411),
                                  ),
                                ),
                              ),
                              Container(child: const SizedBox(width: 10)),
                              Material(
                                color: Colors.transparent,
                                child: CupertinoButton(
                                  onPressed: () {
                                    _delete(context);
                                  },
                                  child: const Icon(
                                    Icons.delete_forever,
                                    size: 20.0,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: height * .04,
                          width: width * .12,
                          color: const Color.fromARGB(255, 230, 193, 105),
                          child: Text(
                            toBeginningOfSentenceCase(widget.label2)!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * .050,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        SizedBox(height: height * .01),
                        Text(
                          toBeginningOfSentenceCase(widget.label)!,
                          style: TextStyle(
                            fontSize: width * .050,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: height * .01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$currency${double.parse(widget.amount).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: width * .050,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: width * .01),
                            Container(
                              child: widget.recuring == '1'
                                  ? Image.asset('assets/images/refresh33.png')
                                  : //show progress on loading = true
                                    Container(), //show this text on loading = false
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .05),
              Padding(
                padding: EdgeInsets.only(left: width * .05, right: width * .05),
                child: Container(
                  padding: EdgeInsets.only(
                    left: width * .03,
                    top: height * .02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 242, 242),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topLeft,
                  height: height * .12,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: width * .03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: width * .04,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Color.fromARGB(144, 33, 149, 243),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        d.format(DateTime.parse(widget.date)),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              Padding(
                padding: EdgeInsets.only(left: width * .05, right: width * .05),
                child: Container(
                  padding: EdgeInsets.only(
                    left: width * .03,
                    top: height * .02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 242, 242),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topLeft,
                  height: height * .12,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: width * .03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent so far this month',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: width * .04,
                              ),
                            ),
                            Image.asset(
                              'assets/images/money.png',
                              width: 30,
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$currency ${widget.spent_current_month}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              Padding(
                padding: EdgeInsets.only(left: width * .05, right: width * .05),
                child: Container(
                  padding: EdgeInsets.only(
                    left: width * .03,
                    top: height * .02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 242, 242),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topLeft,
                  height: height * .12,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: width * .03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total spent last month',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: width * .04,
                              ),
                            ),
                            Image.asset(
                              'assets/images/clock.png',
                              width: 30,
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$currency ${widget.spent_last_month}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              Padding(
                padding: EdgeInsets.only(left: width * .05, right: width * .05),
                child: Container(
                  padding: EdgeInsets.only(
                    left: width * .03,
                    top: height * .02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 242, 242),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topLeft,
                  height: height * .12,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: width * .03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Note',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: width * .04,
                              ),
                            ),
                            Image.asset(
                              'assets/images/notee.jpg',
                              width: 30,
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.note,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .05,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
