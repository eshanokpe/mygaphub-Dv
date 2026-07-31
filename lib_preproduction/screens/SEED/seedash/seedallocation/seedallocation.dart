import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/network_checker.dart';
import 'package:GapHub/models/savingAllocationexpenditure.dart';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/screens/SEED/seedash/setbudget.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'assignIncomechannels/assignIncomechannels.dart';
import 'discretionary/discretionary_allocation.dart';
import 'discretionary/discretionary_allocation_summary.dart';
import 'education/education_allocation.dart';
import 'education/education_allocation_summary.dart';
import 'expenditure/expenditure_allocation.dart';
import 'expenditure/expenditure_allocation_summary.dart';
import 'saving/saving_allocation.dart';
import 'saving/saving_allocation_summary.dart';

class SeedAllocation extends StatefulWidget {
  final bool month;
  const SeedAllocation(this.month, {super.key});

  @override
  State<SeedAllocation> createState() => _SeedAllocationState();
}

class _SeedAllocationState extends State<SeedAllocation> {
  final TextEditingController setbudget = TextEditingController();
  Map data = {};
  // int allocationamount;
  var d = DateFormat.yMMMM();
  var datez = "";
  var currentmonth = "";
  Map dat = {};
  var length;
  var allocationamount;
  List<SavingAllserver> _data = [];
  final List<SavingAllexpenditure> _dataExpen = [];
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  bool isChanging = true;
  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
    dat = widget.month
        ? data['data']["current_seed"]
        : data['data']["target_seed"];
    DateTime date = DateTime.parse(data['data']["current_seed"]["period"]);
    datez = d.format(date);
    DateTime month = DateTime.parse(dat['period']);
    currentmonth = d.format(month);
    print("currentmonth:$currentmonth");

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setbudget.text = ""; // Set the initial value here
        _isEditing = false;
        print("Budget Amount");
      }
    });
    enode = FocusNode();
    pnode = FocusNode();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isChanging = false;
      });
    });
  }

  checkSaving() async {
    // Start a timer for timeout handling
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context); // Close any active dialog
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    // Show loading dialog
    dialogBox.waiting(context, 'Loading');

    try {
      var urlSA = Uri.parse(
        "$baseUrl/app/seed/allocate/budget?category=savings",
      );
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      // API call
      var response = await http
          .get(
            urlSA,
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
          )
          .timeout(const Duration(seconds: 20)); // HTTP timeout

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var savingsData = body["data"]['budget_allocations'] ?? [];
        var currentSeed = body["data"]["current_seed"] ?? {};

        if (savingsData.isNotEmpty) {
          List<SavingAllserver> allocations = savingsData
              .map<SavingAllserver>((data) => SavingAllserver.fromJson(data))
              .toList();
          print('object');

          setState(() => _data = allocations);

          timer.cancel(); // Cancel the timeout timer
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SavingAllocationSummary(data: _data),
            ),
          );
        } else if (currentSeed["budget_amount"] == 0) {
          timer.cancel();
          Navigator.pop(context);
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'Please Set Budget Amount',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          timer.cancel();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavingAllocation()),
          );
        }
      } else {
        timer.cancel();
        handleError('Service Error');
      }
    } catch (e) {
      timer.cancel();
      print('Service Timeout or Unexpected Error ${e.toString()}');
      handleError('Service Timeout or Unexpected Error ${e.toString()}');
    }
  }

  // Error handling helper
  void handleError(String message) {
    Navigator.pop(context);
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  checkEducation() async {
    // Start a timer for timeout handling
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context); // Close any active dialog
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    // Show loading dialog
    dialogBox.waiting(context, 'Loading');

    try {
      var urlSA = Uri.parse(
        "$baseUrl/app/seed/allocate/budget?category=education",
      );
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      // API call
      var response = await http
          .get(
            urlSA,
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
          )
          .timeout(const Duration(seconds: 20)); // HTTP timeout

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var savingsData = body["data"]['budget_allocations'] ?? [];
        var currentSeed = body["data"]["current_seed"] ?? {};

        if (savingsData.isNotEmpty) {
          List<SavingAllserver> allocations = savingsData
              .map<SavingAllserver>((data) => SavingAllserver.fromJson(data))
              .toList();
          print('object');

          setState(() => _data = allocations);

          timer.cancel(); // Cancel the timeout timer
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EducationAllocationSummary(data: _data),
            ),
          );
        } else if (currentSeed["budget_amount"] == 0) {
          timer.cancel();
          Navigator.pop(context);
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'Please Set Budget Amount',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          timer.cancel();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavingAllocation()),
          );
        }
      } else {
        timer.cancel();
        handleError('Service Error');
      }
    } catch (e) {
      timer.cancel();
      print('Service Timeout or Unexpected Error ${e.toString()}');
      handleError('Service Timeout or Unexpected Error ${e.toString()}');
    }
  }

  checkExpenditure() async {
    // EasyLoading.show(
    //   status: 'Loading',
    //   dismissOnTap: false,
    // );
    dialogBox.waiting(context, 'Loading');
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
        List<SavingAllexpenditure> dataExpen0 = dataExpen
            .map<SavingAllexpenditure>(
              (dataExpen) => SavingAllexpenditure.fromJson(dataExpen),
            )
            .toList();
        // EasyLoading.dismiss();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ExpenditureAllocationSummary(data: dataExpen0),
          ),
        );
      } else if (data['data']["current_seed"]["budget_amount"] == 0) {
        EasyLoading.dismiss();
        Navigator.pop(context);
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'Please Set Budget Amount ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // EasyLoading.dismiss();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpenditureAllocation(),
          ),
        );
      }
    } else {
      // EasyLoading.dismiss();
      Navigator.pop(context);
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Service Time Out ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  checkDiscretionary() async {
    // Start a timer for timeout handling
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context); // Close any active dialog
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    // Show loading dialog
    dialogBox.waiting(context, 'Loading');

    try {
      var urlSA = Uri.parse(
        "$baseUrl/app/seed/allocate/budget?category=discretionary",
      );
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      // API call
      var response = await http
          .get(
            urlSA,
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
          )
          .timeout(const Duration(seconds: 20)); // HTTP timeout

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var savingsData = body["data"]['budget_allocations'] ?? [];
        var currentSeed = body["data"]["current_seed"] ?? {};

        if (savingsData.isNotEmpty) {
          List<SavingAllserver> allocations = savingsData
              .map<SavingAllserver>((data) => SavingAllserver.fromJson(data))
              .toList();
          print('object');

          setState(() => _data = allocations);

          timer.cancel();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiscretionaryAllocationSummary(data: _data),
            ),
          );
        } else if (currentSeed["budget_amount"] == 0) {
          timer.cancel();
          Navigator.pop(context);
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'Please Set Budget Amount',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          timer.cancel();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavingAllocation()),
          );
        }
      } else {
        timer.cancel();
        handleError('Service Error');
      }
    } catch (e) {
      timer.cancel();
      print('Service Timeout or Unexpected Error ${e.toString()}');
      handleError('Service Timeout or Unexpected Error ${e.toString()}');
    }
  }

  FocusNode? pnode, enode;

  @override
  Widget build(BuildContext context) {
    //List current = data['data']["current_seed"];
    var total = data['data']["current_detail"]["total"];
    print("total: $total");

    var allocationamount = data['data']["current_seed"]["budget_amount"];
    var totalassigned = data['data']["total_assigned"];
    var savings = data['data']["current_detail"]["table"]["savings"];
    var education = data['data']["current_detail"]["table"]["education"];
    var expenditure = data['data']["current_detail"]["table"]["expenditure"];
    var discretionary =
        data['data']["current_detail"]["table"]["discretionary"];
    var alloamoun = allocationamount;
    String currency = context.watch<Providers>().snapshotmodel.currency;
    var totalSpent = data['data']["current_detail"]["total_spent"];
    num getNumValue(dynamic value) {
      if (value is String) {
        return num.tryParse(value) ??
            0; // Try to parse String to num, default to 0
      }
      return value is num ? value : 0; // If it's already num, return it
    }

    var remainBalance = getNumValue(allocationamount) - getNumValue(totalSpent);
    var availableallocation =
        getNumValue(allocationamount) - getNumValue(total);

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      // color: Colors.blue.withOpacity(.00),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.blue.withOpacity(.0),
            width: width,
            child: Column(
              children: [
                SizedBox(height: height * .02),
                Center(
                  child: Text(
                    datez,
                    style: TextStyle(
                      fontSize: width * .05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      //FocusScope.of(context).requestFocus(FocusNode());
                      // bool result = await isInternetAvailable();
                      // if (!result) {
                      //   dialogBox.information(context, 'Status',
                      //       'Check your Internet Connection');
                      //   EasyLoading.dismiss();
                      //   return;
                      // }
                      var url = Uri.parse("$baseUrl/app/seed/store/budget");
                      var url2 = Uri.parse("$baseUrl/app/seed/");
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');

                      final response = await http.post(
                        url,
                        body: {'budget': setbudget.text},
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
                          var body = jsonDecode(response2.body);
                          context.read<Providers>().setSeeData(body);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Setbudget(true),
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
                                    builder: (context) => Setbudget(true),
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
          AssignIncomeChannels(),

          Padding(
            padding: EdgeInsets.only(left: width * 0.05, bottom: height * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate font size based on available width
                      double availableWidth = constraints.maxWidth;
                      String text =
                          "Available for Allocation: $currency${(availableallocation ?? 0).toStringAsFixed(2)}";

                      // Format the number with commas
                      String formattedText = text.replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      );

                      // Determine font size based on text length and available width
                      double fontSize =
                          (availableWidth / formattedText.length) * 1.8;

                      // Clamp font size to reasonable values
                      fontSize = fontSize.clamp(12.0, 24.0);

                      return Text(
                        formattedText,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
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

          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  checkSaving();
                },
                // onTap: () async {},
                child: Card(
                  color: const Color(0xff00B050),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  // elevation: 5,
                  child: Container(
                    width: width * .90,
                    padding: EdgeInsets.all(width * .05),
                    child: Column(
                      children: [
                        Text(
                          'Savings',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .06,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${savings.toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: width * .05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: GestureDetector(
              onTap: () async {
                checkEducation();
              },
              child: Card(
                color: const Color(0xffE6C069),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                // elevation: 5,
                child: Container(
                  width: width * .90,
                  padding: EdgeInsets.all(width * .05),
                  child: Column(
                    children: [
                      Text(
                        'Education',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * .06,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$currency${education.toStringAsFixed(2)}'
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: width * .05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: GestureDetector(
              onTap: () async {
                checkExpenditure();
              },
              child: Card(
                color: const Color(0xffD13B56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                // elevation: 5,
                child: Container(
                  width: width * .90,
                  padding: EdgeInsets.all(width * .05),
                  child: Column(
                    children: [
                      Text(
                        'Expenditure',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * .06,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$currency${expenditure.toStringAsFixed(2)}'
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: width * .05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: GestureDetector(
              onTap: () async {
                checkDiscretionary();
              },
              child: Card(
                color: const Color.fromARGB(255, 77, 125, 153),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                // elevation: 5,
                child: Container(
                  width: width * .90,
                  padding: EdgeInsets.all(width * .05),
                  child: Column(
                    children: [
                      Text(
                        'Discretionary',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: width * .06,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$currency${discretionary.toStringAsFixed(2)}'
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: width * .05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * .10),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     primary: Theme.of(context).primaryColor,
          //   ),
          //   onPressed: () async {
          //     var _url2 = Uri.parse("$baseUrl/app/reminder");
          //     final prefs = await SharedPreferences.getInstance();
          //     var token = prefs.getString('tokenDB');
          //     var response2 = await http
          //         .get(_url2, headers: {"Authorization": 'Bearer $token'});
          //     if (response2.statusCode == 200) {
          //       //Rem rem = Rem.fromJson(jsonDecode(response2.body));
          //       //Savv savingAllserver =
          //       //    Savv.fromJson(jsonDecode(response2.body));
          //       //savingAllserver["firstname"];
          //       //var whatiwant = savingAllserver;
          //       //print(savingAllserver);
          //       //for (var i = 0; i < whatiwant.length; i++) {
          //       //String id = whatiwant[i]["id"].toString();
          //       //print(id);
          //       //}
          //     } else {
          //       Navigator.pop(context);
          //       Fluttertoast.showToast(msg: "Error occurred");
          //     }
          //   },
          //   child: Text(
          //     "Update Next Year Goal",
          //     style:
          //         TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          //   ),
          // )
        ],
      ),
    );
  }
}
