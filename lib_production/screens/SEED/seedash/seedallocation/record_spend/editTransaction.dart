import 'dart:convert';

import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/seed_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditTransactionSummary extends StatefulWidget {
  var amount;
  final String label;
  final String date;
  final String note;
  final int id;
  EditTransactionSummary({
    super.key,
    this.amount,
    required this.label,
    required this.date,
    required this.note,
    required this.id,
  });

  @override
  State<EditTransactionSummary> createState() => _EditTransactionSummaryState();
}

class _EditTransactionSummaryState extends State<EditTransactionSummary> {
  final _key = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();
  TextEditingController savingNote = TextEditingController();
  TextEditingController savdateinput = TextEditingController();
  TextEditingController savingPayee = TextEditingController();
  final _controller = ValueNotifier<bool>(false);
  //recurring
  bool showrecurring = false;
  bool _checked = true;

  @override
  void initState() {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    EasyLoading.dismiss();
    setState(() {
      super.initState();
      // id = widget.id.toString();
      print('id:${widget.id}');
      amount.text = widget.amount.toString();
      savingPayee.text = widget.label.toString();
      savdateinput.text = widget.date.toString();
      savingNote.text = widget.note.toString();
    });

    //fectchAllocation();
    EasyLoading.dismiss();
    _controller.addListener(() {
      setState(() {
        if (_controller.value) {
          _checked = true;
        } else {
          _checked = false;
        }
        if (_checked == true) {
          showrecurring = true;
        } else {
          showrecurring = false;
        }
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
                  controller: savingNote,
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
    // bool result = await isInternetAvailable();
    // if (!result) {
    //   dialogBox.information(
    //       context, 'Status', 'Check your Internet Connection');
    //   EasyLoading.dismiss();
    //   return;
    // }
    var userid = widget.id;
    // print('id:$id');
    var url = Uri.parse("$baseUrl/app/seed/allocate/budget/$userid");
    const one = "1";
    const zero = "0";
    print('recuring: ${_checked == true ? one : zero}');
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    final response = await http.put(
      url,
      body: {
        'label': savingPayee.text.trim(),
        'amount': amount.text.trim(),
        'note': savingNote.text.trim() ?? '',
        'allocation': widget.id.toString(),
        'recuring': showrecurring == true ? one : zero,
        // 'date': savdateinput.text.trim(),
      },
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        msg: 'Record Spent has been updated',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: 'Error ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
