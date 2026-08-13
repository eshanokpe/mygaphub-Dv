import 'dart:convert';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './seedtabs.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';

import 'seedallocation/discretionary/discretionary_allocation.dart';
import 'seedallocation/discretionary/discretionary_allocation_summary.dart';
import 'seedallocation/education/education_allocation.dart';
import 'seedallocation/education/education_allocation_summary.dart';
import 'seedallocation/expenditure/expenditure_allocation.dart';
import 'seedallocation/expenditure/expenditure_allocation_summary.dart';
import 'seedallocation/saving/saving_allocation.dart';
import 'seedallocation/saving/saving_allocation_summary.dart';

class Seeds extends StatefulWidget {
  final List list;
  const Seeds(this.list, {super.key});
  @override
  _SeedsState createState() => _SeedsState();
}

class _SeedsState extends State<Seeds> {
  Map data = {};
  final List<SavingAllserver> _data = [];
  final List<SavingAllexpenditure> _dataExpen = [];
  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * .04,
        vertical: height * .03,
      ),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SeedRow(
              onTap: () async {
                EasyLoading.show(status: 'Loading', dismissOnTap: false);

                var urlSA = Uri.parse(
                  "$baseUrl/app/seed/allocate/budget?category=savings",
                );

                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('tokenDB');

                if (token == null) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Authentication error. Please log in again.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return;
                }

                try {
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
                    var savingsdata = body["data"]['budget_allocations'] ?? [];

                    if (savingsdata.isNotEmpty) {
                      List<SavingAllserver> data = savingsdata
                          .map<SavingAllserver>(
                            (data) => SavingAllserver.fromJson(data),
                          )
                          .toList();

                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SavingAllocationSummary(data: data),
                        ),
                      );
                    } else if (body["data"]["current_seed"]?["budget_amount"] ==
                        0) {
                      EasyLoading.dismiss();
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'Please Set Budget Amount',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavingAllocation(),
                        ),
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: 'Service Time Out',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    EasyLoading.dismiss();
                  }
                } catch (e) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'An error occurred: $e',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              color: 0xff00B050,
              name: "Savings",
              value: "$currency${widget.list[0].toStringAsFixed(2)}",
            ),
            const Divider(thickness: 1.5),
            SeedRow(
              onTap: () async {
                EasyLoading.show(status: 'Loading', dismissOnTap: false);

                var url2 = Uri.parse(
                  "$baseUrl/app/seed/allocate/budget?category=education",
                );

                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('tokenDB');

                if (token == null) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Authentication error. Please log in again.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return;
                }

                try {
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
                    var educationdata =
                        body["data"]['budget_allocations'] ?? [];

                    if (educationdata.isNotEmpty) {
                      List<SavingAllserver> data = educationdata
                          .map<SavingAllserver>(
                            (data) => SavingAllserver.fromJson(data),
                          )
                          .toList();

                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EducationAllocationSummary(data: data),
                        ),
                      );
                    } else if (body["data"]["current_seed"]?["budget_amount"] ==
                        0) {
                      EasyLoading.dismiss();
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'Please Set Budget Amount',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EducationAllocation(),
                        ),
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: 'Service Time Out',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    EasyLoading.dismiss();
                  }
                } catch (e) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'An error occurred: $e',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              color: 0xffE6C069,
              name: "Education",
              value: "$currency${widget.list[1].toStringAsFixed(2)}",
            ),
            const Divider(thickness: 1.5),
            SeedRow(
              onTap: () async {
                EasyLoading.show(status: 'Loading', dismissOnTap: false);

                var url2 = Uri.parse(
                  "$baseUrl/app/seed/allocate/budget?category=expenditure",
                );

                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('tokenDB');

                if (token == null) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Authentication error. Please log in again.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return;
                }

                try {
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
                    var expenditureData =
                        body["data"]?['budget_allocations'] ?? [];

                    if (expenditureData.isNotEmpty) {
                      var dataExpen =
                          body["data"]?['budget_expenditures'] ?? [];
                      List<SavingAllexpenditure> dataExpen0 = dataExpen
                          .map<SavingAllexpenditure>(
                            (dataExpen) =>
                                SavingAllexpenditure.fromJson(dataExpen),
                          )
                          .toList();

                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenditureAllocationSummary(data: dataExpen0),
                        ),
                      );
                    } else if (body["data"]?["current_seed"]?["budget_amount"] ==
                        0) {
                      EasyLoading.dismiss();
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'Please Set Budget Amount',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenditureAllocation(),
                        ),
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: 'Service Time Out',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    EasyLoading.dismiss();
                  }
                } catch (e) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'An error occurred: $e',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              color: 0xffD13B56,
              name: "Expenditure",
              value: "$currency${widget.list[2].toStringAsFixed(2)}",
            ),
            const Divider(thickness: 1.5),
            SeedRow(
              onTap: () async {
                EasyLoading.show(status: 'Loading', dismissOnTap: false);

                var url2 = Uri.parse(
                  "$baseUrl/app/seed/allocate/budget?category=discretionary",
                );

                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('tokenDB');

                if (token == null) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Authentication error. Please log in again.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return;
                }

                try {
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
                    var discretionaryData =
                        body["data"]?['budget_allocations'] ?? [];

                    if (discretionaryData.isNotEmpty) {
                      List<SavingAllserver> data = discretionaryData
                          .map<SavingAllserver>(
                            (item) => SavingAllserver.fromJson(item),
                          )
                          .toList();

                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DiscretionaryAllocationSummary(data: data),
                        ),
                      );
                    } else if (body["data"]?["current_seed"]?["budget_amount"] ==
                        0) {
                      EasyLoading.dismiss();
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'Please Set Budget Amount',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      EasyLoading.dismiss();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiscretionaryAllocation(),
                        ),
                      );
                    }
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: 'Service Time Out',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    EasyLoading.dismiss();
                  }
                } catch (e) {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'An error occurred: $e',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              name: "Discretionary",
              value: "$currency${widget.list[3].toStringAsFixed(2)}",
              color: 0xff77A2BB,
            ),
            const Divider(thickness: 1.5),
          ],
        ),
      ),
    );
  }
}
