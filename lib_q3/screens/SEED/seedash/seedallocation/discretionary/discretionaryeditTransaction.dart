import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/seed_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'discretionary_allocation_summary.dart';

class EditDiscreationaryTransactionSummary extends StatefulWidget {
  final dynamic amount;
  final String label;
  final String date;
  final String note;
  final int id;
  final dynamic allocationid;
  final dynamic recuring;

  const EditDiscreationaryTransactionSummary({
    super.key,
    this.amount,
    this.recuring,
    this.allocationid,
    required this.label,
    required this.date,
    required this.note,
    required this.id,
  });

  @override
  State<EditDiscreationaryTransactionSummary> createState() =>
      _EditDiscreationaryTransactionSummaryState();
}

class _EditDiscreationaryTransactionSummaryState
    extends State<EditDiscreationaryTransactionSummary> {
  final _key = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();
  TextEditingController savingNote = TextEditingController();
  TextEditingController savdateinput = TextEditingController();
  TextEditingController savingPayee = TextEditingController();
  ValueNotifier<bool> _controller = ValueNotifier(false);
  //recurring
  bool showRecurring = false;
  bool isChecked = true;
  List<SavingAllserver> data = [];

  @override
  void initState() {
    super.initState();
    print("recur:${widget.recuring}");
    _controller = ValueNotifier<bool>(widget.recuring == '1' ? true : false);

    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    EasyLoading.dismiss();
    setState(() {
      // id = widget.id.toString();
      print('id:${widget.id}');
      amount.text = widget.amount.toString();
      savingPayee.text = widget.label.toString();
      savdateinput.text = widget.date.toString();
      savingNote.text = widget.note ?? '';
    });

    //fectchAllocation();
    EasyLoading.dismiss();
    _controller.addListener(() {
      setState(() {
        isChecked = _controller.value; // Simplified isChecked assignment
        showRecurring = isChecked; // Simplified showRecurring assignment
      });
    });
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
      //backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Transaction Summary',
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
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _key,
            child: Column(
              children: [
                SizedBox(height: height * .02),
                SeedForm(
                  name: "Amount",
                  hintText: ' 0.00',
                  controller: amount,
                  symbol: currency,
                  // ignore: missing_return
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter your Amount';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
                /*   SizedBox(
                height: height * .01,
              ),
             Padding(
                padding: EdgeInsets.only(left: width * .09),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Date:",
                        style: TextStyle(
                            fontSize: width * .05, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
               Padding(
                padding: EdgeInsets.only(
                    left: width * .08, top: width * .01, right: width * .08),
                child: TextFormField(
                  controller: savdateinput, //editing controller of this TextField
                  validator: (value) {
                    if (value.trim().isEmpty) {
                      return 'Please enter date';
                    }
                  },
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.calendar_month),
                    labelText: "Enter Date",
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * .02)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                        borderRadius: BorderRadius.circular(width * .02)),
                  ),
                  readOnly:
                      true, //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                            2000), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101));
      
                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      //you can implement different kind of Date Format here according to your requirement
      
                      setState(() {
                        savdateinput.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ), */
                SizedBox(height: height * .01),
                SeedForm(
                  name: "Payee / Merchant ",
                  hintText: 'E.g Hargreaves Lansdown',
                  controller: savingPayee,
                  keyboardType: TextInputType.text,
                  symbol: '',
                  maxLines: 1,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please fill the details';
                    }
                    return null;
                  },
                ),
                SeedForm(
                  name: "Description / Note ",
                  hintText: 'Optional',
                  controller: savingNote.text == 'null'
                      ? TextEditingController()
                      : savingNote,
                  keyboardType: TextInputType.text,
                  symbol: '',
                  maxLines: 2,
                ),
                SizedBox(height: height * .01),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: width * .10),
                      child: Row(
                        children: [
                          Text(
                            "Recurring",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: width * .12),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdvancedSwitch(
                          inactiveColor: Colors.red,
                          activeChild: const Text('Yes'),
                          inactiveChild: const Text('No'),
                          width: 70.0,
                          height: 30.0,
                          controller: _controller,
                          initialValue: widget.recuring == '1',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: height * .06),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.only(
                      left: width * .10,
                      right: width * .10,
                    ),
                  ),
                  onPressed: () async {
                    updateSavingsAllocation();
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  updateSavingsAllocation() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      EasyLoading.dismiss();
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    // bool result = await isInternetAvailable();

    // if (!result) {
    //   dialogBox.information(
    //       context, 'Status', 'Check your Internet Connection');
    //   EasyLoading.dismiss();
    //   return;
    // }
    var id = widget.id;
    var allocationid = widget.allocationid;
    print('id:$id');
    print("allocationid:$allocationid");
    var url = Uri.parse("$baseUrl/app/seed/record/spent/$id");
    const one = "1";
    const zero = "0";
    print('recuring: ${isChecked == true ? one : zero}');
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    final response = await http.put(
      url,
      body: {
        'label': savingPayee.text.trim(),
        'amount': amount.text.trim(),
        'note': savingNote.text.trim() ?? '',
        'allocation': widget.allocationid.toString(),
        'recuring': showRecurring == true ? one : zero,
        // 'date': savdateinput.text.trim(),
      },
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );
    var url2 = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=discretionary",
    );

    var response2 = await http.get(
      url2,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      if (response2.statusCode == 200) {
        var body = jsonDecode(response2.body);
        var data = body["data"]['budget_allocations'];
        List res = data;
        setState(() {
          data = res.map((data) => SavingAllserver.fromJson(data)).toList();
        });
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscretionaryAllocationSummary(data: data),
          ),
        );

        Fluttertoast.showToast(
          backgroundColor: Colors.green,
          msg: 'Record Spent has been updated',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        EasyLoading.dismiss();
      }
    } else {
      timer.cancel();
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: 'Error ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
