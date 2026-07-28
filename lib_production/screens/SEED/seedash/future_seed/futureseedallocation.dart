import 'dart:convert';

import 'package:GapHub/models/network_checker.dart';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/screens/SEED/seedash/future_seed/futureseed.dart';
import 'package:GapHub/screens/SEED/seedash/setbudget.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'discretionary/discretionary_allocation.dart';
import 'discretionary/discretionary_allocation_summary.dart';
import 'education/education_allocation.dart';
import 'education/education_allocation_summary.dart';
import 'expenditure/expenditure_allocation.dart';
import 'expenditure/expenditure_allocation_summary.dart';
import 'saving/saving_allocation.dart';
import 'saving/saving_allocation_summary.dart';
import 'seedallocation_widget.dart';

class FutureSeedAllocation extends StatefulWidget {
  final bool month;
  const FutureSeedAllocation(this.month, {super.key});

  @override
  State<FutureSeedAllocation> createState() => _FutureSeedAllocationState();
}

class _FutureSeedAllocationState extends State<FutureSeedAllocation> {
  final TextEditingController setbudget = TextEditingController();
  Map data = {};
  var d = DateFormat.yMMMM();
  var datez = "";
  var currentmonth = "";
  Map dat = {};

  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedtarget;
    dat = data['data']["target_seed"];
    DateTime month = DateTime.parse(dat['period']);
    currentmonth = d.format(month);
    print("currentmonth:$currentmonth");
  }

  List<SavingAllserver> _data = [];
  List<SavingAllexpenditure> _dataExpen = [];

  //CheckSaving Allocation Summary
  checkSaving() async {}
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  bool isChanging = true;
  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    var total = data['data']["target_detail"]["total"];
    var totalSpent = data['data']["target_detail"]["total_spent"];

    var allocationamount = data['data']["target_seed"]["budget_amount"];
    var savings = data['data']["target_detail"]["table"]["savings"];
    var education = data['data']["target_detail"]["table"]["education"];
    var expenditure = data['data']["target_detail"]["table"]["expenditure"];
    var discretionary = data['data']["target_detail"]["table"]["discretionary"];
    var remainBalance =
        double.parse(allocationamount.toString()) -
        double.parse(totalSpent.toString());
    var availableallocation =
        double.parse(allocationamount.toString()) -
        double.parse(total.toString());

    var alloamoun = allocationamount;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      //color: Colors.blue.withOpacity(.00),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Text(
              currentmonth,
              style: TextStyle(
                fontSize: width * .05,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: height * .03),
          SizedBox(height: height * .03),
          Padding(
            padding: EdgeInsets.only(left: width * .05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${alloamoun == null ? 'Set Budget Amount:' : 'My Budget'} ",
                  style: TextStyle(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: width * .05,
              top: width * .02,
              right: width * .06,
            ),
            child: Column(
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  controller: setbudget,
                  focusNode: _focusNode,
                  onEditingComplete: () async {
                    try {
                      EasyLoading.show(status: 'Loading', dismissOnTap: false);

                      var url = Uri.parse("$baseUrl/app/seed/store/budget");
                      var url2 = Uri.parse("$baseUrl/app/seed/");
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');

                      final response = await http.post(
                        url,
                        body: {
                          'budget': setbudget.text,
                          'period': 'seed_future_budget',
                        },
                        headers: {
                          "Authorization": 'Bearer $token',
                          "Accept": "application/json",
                          "Content-Type": "application/x-www-form-urlencoded",
                        },
                        encoding: Encoding.getByName("utf-8"),
                      );
                      if (response.statusCode == 200) {
                        EasyLoading.dismiss();
                        var data = jsonDecode(response.body);
                        var response2 = await http.get(
                          url2,
                          headers: {"Authorization": 'Bearer $token'},
                        );
                        if (response2.statusCode == 200) {
                          print('get:${response2.body}');
                          var body = jsonDecode(response2.body);
                          context.read<Providers>().setSeeData(body);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Futureseed(true),
                            ),
                          );
                          Fluttertoast.showToast(msg: "${data["message"]}");
                        } else {
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                          Fluttertoast.showToast(msg: "Error occurred");
                        }
                      } else {
                        EasyLoading.dismiss();
                        // print('Error');
                        //Navigator.pop(context);
                        dialogBox.information(
                          context,
                          'Status',
                          'Your set amount is lower than the sum of your allocated SEED, reduce any of your allocated SEED to accommodate this reduction',
                        );
                      }
                    } catch (e) {
                      print(e);
                      EasyLoading.dismiss();
                      //Navigator.pop(context);
                    }
                    _isEditing = true;
                    _focusNode.unfocus();
                  },
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: InputDecoration(
                    //prefix: Text('$currency '),
                    filled: true,
                    //label: Text('$currency'),
                    hintText: '$currency $allocationamount.00',
                    contentPadding: EdgeInsets.all(width * .05),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * .02),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * .02),
                    ),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                ),
                KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                    if (isKeyboardVisible) {
                      return CupertinoButton(
                        onPressed: () async {
                          try {
                            EasyLoading.show(
                              status: 'Loading',
                              dismissOnTap: false,
                            );
                            //FocusScope.of(context).requestFocus(FocusNode());
                            // bool result = await isInternetAvailable();
                            // if (!result) {
                            //   dialogBox.information(context, 'Status',
                            //       'Check your Internet Connection');
                            //   EasyLoading.dismiss();
                            //   return;
                            // }
                            //dialogBox.waiting(context, 'Loading');

                            var url = Uri.parse(
                              "$baseUrl/app/seed/store/budget",
                            );
                            var url2 = Uri.parse("$baseUrl/app/seed/");
                            final prefs = await SharedPreferences.getInstance();
                            var token = prefs.getString('tokenDB');

                            final response = await http.post(
                              url,
                              body: {'budget': setbudget.text},
                              headers: {
                                "Authorization": 'Bearer $token',
                                "Accept": "application/json",
                                "Content-Type":
                                    "application/x-www-form-urlencoded",
                              },
                              encoding: Encoding.getByName("utf-8"),
                            );
                            if (response.statusCode == 200) {
                              EasyLoading.dismiss();
                              var data = jsonDecode(response.body);
                              var response2 = await http.get(
                                url2,
                                headers: {"Authorization": 'Bearer $token'},
                              );
                              if (response2.statusCode == 200) {
                                var body = jsonDecode(response2.body);
                                context.read<Providers>().setSeeData(body);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Futureseed(true),
                                  ),
                                );
                                Fluttertoast.showToast(
                                  msg: "${data["message"]}",
                                );
                              } else {
                                EasyLoading.dismiss();
                                Navigator.pop(context);
                                Fluttertoast.showToast(msg: "Error occurred");
                              }
                            } else {
                              EasyLoading.dismiss();
                              // print('Error');
                              //Navigator.pop(context);
                              dialogBox.information(
                                context,
                                'Status',
                                'Your set amount is lower than the sum of your allocated SEED, reduce any of your allocated SEED to accommodate this reduction',
                              );
                            }
                          } catch (e) {
                            print(e);
                            EasyLoading.dismiss();
                            //Navigator.pop(context);
                          }
                          _isEditing = true;
                          _focusNode.unfocus(); // Dismiss the keyboard
                        },
                        child: const Text('Done'),
                      );
                    } else {
                      return const SizedBox.shrink(); // Hide the button when the keyboard is not visible
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: height * .02),
          Padding(
            padding: EdgeInsets.only(left: width * .05, bottom: height * .01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Available for Allocation: $currency${availableallocation.toStringAsFixed(2) ?? '0'}"
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  style: TextStyle(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * .05, bottom: height * .01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Total Spent: $currency ${totalSpent.toStringAsFixed(2) ?? '0'}"
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  style: TextStyle(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: width * .05, bottom: height * .01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Remaining Balance: $currency${remainBalance.toStringAsFixed(2) ?? '0'}"
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                  style: TextStyle(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SeelAllocationWidget(
            onClick: () async {
              EasyLoading.show(status: 'Loading', dismissOnTap: false);

              var urlSA = Uri.parse(
                "$baseUrl/app/seed/allocate/budget?category=savings",
              );
              final prefs = await SharedPreferences.getInstance();
              var token = prefs.getString('tokenDB');
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
                  var data = body["data"]['budget_allocations'];
                  List res = data;
                  setState(() {
                    _data = res
                        .map((data) => SavingAllserver.fromJson(data))
                        .toList();
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FS_SavingAllocationSummary(data: _data),
                    ),
                  );
                  EasyLoading.dismiss();
                } else if (data['data']["target_seed"]["budget_amount"] == 0) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Please Set Budget Amount ',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  EasyLoading.dismiss();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FS_SavingAllocation(),
                    ),
                  );
                  //saveLastPage();
                }
              } else {
                Fluttertoast.showToast(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  msg: 'Service Time Out ',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                EasyLoading.dismiss();
              }
            },
            amount: double.parse(savings.toStringAsFixed(2)),
            title: 'Savings',
            color: const Color(0xff00B050),
          ),
          SeelAllocationWidget(
            onClick: () async {
              EasyLoading.show(status: 'Loading', dismissOnTap: false);
              // bool result = await isInternetAvailable();
              // if (!result) {
              //   dialogBox.information(
              //       context, 'Status', 'Check your Internet Connection');
              //   EasyLoading.dismiss();
              //   return;
              // }
              var url2 = Uri.parse(
                "$baseUrl/app/seed/allocate/budget?category=education",
              );
              final prefs = await SharedPreferences.getInstance();
              var token = prefs.getString('tokenDB');
              var response2 = await http.get(
                url2,
                headers: {"Authorization": 'Bearer $token'},
              );
              if (response2.statusCode == 200) {
                var body = jsonDecode(response2.body);
                var educationdata = body["data"]['budget_allocations'];
                int length = educationdata.length;
                print('Education:$length');
                if (length >= 1) {
                  var data = body["data"]['budget_allocations'];
                  List res = data;
                  setState(() {
                    _data = res
                        .map((data) => SavingAllserver.fromJson(data))
                        .toList();
                  });
                  EasyLoading.dismiss();
                  // saveLastPage();
                  print("object:$data");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FSEducationAllocationSummary(data: _data),
                    ),
                  );
                } else if (data['data']["current_seed"]["budget_amount"] == 0) {
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Please Set Budget Amount ',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FSEducationAllocation(),
                    ),
                  );
                }
              } else {
                Fluttertoast.showToast(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  msg: 'Service Time Out ',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                EasyLoading.dismiss();
              }
            },
            // amount: education.toStringAsFixed(2),
            amount: double.parse(education.toStringAsFixed(2)),
            title: 'Education',
            color: const Color(0xffE6C069),
          ),
          SeelAllocationWidget(
            onClick: () async {
              EasyLoading.show(status: 'Loading', dismissOnTap: false);
              // bool result = await isInternetAvailable();
              // if (!result) {
              //   dialogBox.information(
              //       context, 'Status', 'Check your Internet Connection');
              //   EasyLoading.dismiss();
              //   return;
              // }
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
                var expendituredata = body["data"]['budget_allocations'];
                int length = expendituredata.length;
                print('Expenditure:$length');
                if (length >= 1) {
                  var dataExpen = body["data"]['budget_expenditures'];

                  List res = dataExpen;
                  print('data:$data');
                  setState(() {
                    _dataExpen = res
                        .map(
                          (dataExpen) =>
                              SavingAllexpenditure.fromJson(dataExpen),
                        )
                        .toList();
                  });
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FSExpenditureAllocationSummary(data: _dataExpen),
                    ),
                  );
                } else if (data['data']["current_seed"]["budget_amount"] == 0) {
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Please Set Budget Amount ',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FSExpenditureAllocation(),
                    ),
                  );
                }
              } else {
                EasyLoading.dismiss();
                //saveLastPage();
                Fluttertoast.showToast(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  msg: 'Service Time Out ',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            amount: double.parse(expenditure.toStringAsFixed(2)),
            title: 'Expenditure',
            color: const Color(0xffD13B56),
          ),
          SeelAllocationWidget(
            onClick: () async {
              EasyLoading.show(status: 'Loading', dismissOnTap: false);
              // bool result = await isInternetAvailable();
              // if (!result) {
              //   dialogBox.information(
              //       context, 'Status', 'Check your Internet Connection');
              //   EasyLoading.dismiss();
              //   return;
              // }
              var url2 = Uri.parse(
                "$baseUrl/app/seed/allocate/budget?category=discretionary",
              );
              final prefs = await SharedPreferences.getInstance();
              var token = prefs.getString('tokenDB');
              var response2 = await http.get(
                url2,
                headers: {"Authorization": 'Bearer $token'},
              );
              if (response2.statusCode == 200) {
                var body = jsonDecode(response2.body);
                var discretionarydata = body["data"]['budget_allocations'];
                int length = discretionarydata.length;
                print('Discretionary:$length');
                if (length >= 1) {
                  var data = body["data"]['budget_allocations'];
                  List res = data;
                  setState(() {
                    _data = res
                        .map((data) => SavingAllserver.fromJson(data))
                        .toList();
                  });
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FSDiscretionaryAllocationSummary(data: _data),
                    ),
                  );
                } else if (data['data']["current_seed"]["budget_amount"] == 0) {
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Please Set Budget Amount ',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  EasyLoading.dismiss();
                  //saveLastPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FSDiscretionaryAllocation(),
                    ),
                  );
                }
              } else {
                EasyLoading.dismiss();
                //saveLastPage();
                Fluttertoast.showToast(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  msg: 'Service Time Out ',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            // amount: discretionary.toStringAsFixed(2),
            amount: double.parse(discretionary.toStringAsFixed(2)),
            title: 'Discretionary',
            color: const Color.fromARGB(255, 77, 125, 153),
          ),
        ],
      ),
    );
  }
}
