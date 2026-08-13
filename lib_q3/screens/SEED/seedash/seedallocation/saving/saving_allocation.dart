import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/seed_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'saving_allocation_summary.dart';

class SavingAllocation extends StatefulWidget {
  const SavingAllocation({super.key});

  @override
  State<SavingAllocation> createState() => _SavingAllocationState();
}

class _SavingAllocationState extends State<SavingAllocation> {
  TextEditingController savingAmount = TextEditingController();
  TextEditingController savingNote = TextEditingController();
  TextEditingController newlabel = TextEditingController();
  final _key = GlobalKey<FormState>();
  Map data = {};
  // int allocationamount;
  var d = DateFormat.yMMMM();
  var datez = "";
  var currentmonth = "";
  Map dat = {};
  var budget_amount;
  final List<SavingAllserver> _data = [];

  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
    DateTime date = DateTime.parse(data['data']["current_seed"]["period"]);
    datez = d.format(date);
    //DateTime month = DateTime.parse(dat['period']);
    //currentmonth = d.format(month);
    //budget_amount = data['data']["current_seed"]["budget_amount"];
    //print(budget_amount);
  }

  static const assets = <String>[
    '-Select-',
    'Investment Pool Fund',
    'Personal Project Fund',
    'Emergency and Holiday Savings',
    'Others',
  ];
  String val = "-Select-";
  String other = "Others";
  bool _showTextField = false;
  String dropdownError = '';
  bool isValid = false;
  String newlabell = '';

  String option = '-Select-';
  static const subUnits1 = <String>[
    '-Select-',
    'Investment Pool Fund',
    'Personal Project Fund',
    'Emergency and Holiday Savings',
    'Others',
  ];
  final List<DropdownMenuItem<String>> optionList = subUnits1
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  @override
  Widget build(BuildContext context) {
    var allocationamount = data['data']["current_seed"]["budget_amount"];
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(.05),
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Savings Allocation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: width * .035,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            children: [
              SizedBox(height: height * .02),
              Padding(
                padding: EdgeInsets.only(left: width * .08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Savings Category",
                      style: TextStyle(
                        fontSize: width * .04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * .01),
              Container(
                padding: EdgeInsets.only(left: width * .02, right: width * .08),
                width: width,
                margin: EdgeInsets.only(left: width * .08, right: width * .08),
                //width: width * .9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 196, 196, 196),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    focusColor: Theme.of(context).primaryColor,
                    value: val,
                    items: optionList,
                    onChanged: (value) {
                      if (value == null) return; // Prevent null errors

                      setState(() {
                        val = value;
                        if (val == assets[0]) {
                          dropdownError = ((val == assets[0]) ? null : '')!;
                          isValid = false;
                        }

                        if (val != assets[0]) {
                          dropdownError = '';
                          isValid = true;
                        }

                        print(value);
                        if (value == assets[4]) {
                          _showTextField = true;
                        } else {
                          _showTextField = false;
                        }
                      });

                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: width * .08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      dropdownError ?? "",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _showTextField,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width * .08,
                    top: width * .05,
                    right: width * .08,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: newlabel,
                    //maxLines: maxLines,
                    onTap: () {},
                    style: TextStyle(
                      fontSize: width * .04,
                      fontWeight: FontWeight.w300,
                    ),
                    // ignore: missing_return
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your Label';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      // prefix: Text(currency),
                      filled: true,
                      hintText: 'Create a new label',
                      contentPadding: EdgeInsets.only(
                        top: width * .05,
                        left: width * .02,
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 196, 196, 196),
                        ),
                        borderRadius: BorderRadius.circular(width * .02),
                      ),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(width * .01),
                      ),
                    ),
                  ),
                ),
              ),
              SeedForm(
                name: "Amount",
                hintText: ' 0.00',
                controller: savingAmount,
                inputFormatters: [amountValidator],
                symbol: currency,
                // ignore: missing_return
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Amount';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SeedForm(
                name: "Note",
                hintText: '',
                controller: savingNote,
                keyboardType: TextInputType.text,
                symbol: '',
                maxLines: 4,
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
                  var timer = Timer(const Duration(seconds: 30), () {
                    Navigator.pop(context); // Close any active dialog
                    dialogBox.information(
                      context,
                      'Status',
                      'Service timed out',
                    );
                  });
                  try {
                    bool isValid = _key.currentState!.validate();
                    if (val == '-Select-') {
                      timer.cancel();
                      setState(() => dropdownError = "Please select an option");
                      isValid = false;
                    } else {
                      dialogBox.waiting(context, 'Loading');
                      FocusScope.of(context).requestFocus(FocusNode());

                      int amun = int.parse(savingAmount.text);

                      if (num.parse(allocationamount) < amun) {
                        timer.cancel();
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            187,
                            51,
                          ),
                          textColor: Colors.black,
                          msg:
                              'You have used up all Available Allocation or Your Saving amount is more than your Availabel Allocation  , Please Set Budget Amount ',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                        return;
                      }

                      setState(() => dropdownError = " ");
                      isValid = true;

                      if (val == 'Others') {
                        setState(() {
                          newlabell = newlabel.text.trim();
                        });
                      } else {
                        setState(() {
                          newlabell = val.toString();
                        });
                      }

                      var url = Uri.parse("$baseUrl/app/seed/allocate/budget");
                      var url2 = Uri.parse(
                        "$baseUrl/app/seed/allocate/budget?category=savings",
                      );
                      var url3 = Uri.parse("$baseUrl/app/seed/");
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');

                      var urlbudget = Uri.parse(
                        "$baseUrl/app/seed/store/budget",
                      );

                      int all = int.parse(allocationamount.toString());
                      var setbudget = (all - amun);
                      print("Setbudget: $setbudget");
                      final responsebudget = await http.post(
                        urlbudget,
                        body: {'budget': setbudget.toString()},
                        headers: {
                          "Authorization": 'Bearer $token',
                          "Accept": "application/json",
                          "Content-Type": "application/x-www-form-urlencoded",
                        },
                        encoding: Encoding.getByName("utf-8"),
                      );
                      if (responsebudget.statusCode == 200) {
                        final response = await http.post(
                          url,
                          body: {
                            'category': 'savings',
                            'label': newlabell,
                            'amount': savingAmount.text.trim(),
                            'note': savingNote.text.trim() ?? '',
                          },
                          headers: {
                            "Authorization": 'Bearer $token',
                            "Accept": "application/json",
                            "Content-Type": "application/x-www-form-urlencoded",
                          },
                          encoding: Encoding.getByName("utf-8"),
                        );

                        if (response.statusCode == 200) {
                          var body = jsonDecode(response.body);
                          var response3 = await http.get(
                            url3,
                            headers: {"Authorization": 'Bearer $token'},
                          );
                          if (response3.statusCode == 200) {
                            var body = jsonDecode(response3.body);

                            var response2 = await http.get(
                              url2,
                              headers: {"Authorization": 'Bearer $token'},
                            );
                            if (response2.statusCode == 200) {
                              var body = jsonDecode(response2.body);
                              var savingsdata =
                                  body["data"]['budget_allocations'] ?? [];

                              if (savingsdata.isNotEmpty) {
                                List<SavingAllserver> data = savingsdata
                                    .map<SavingAllserver>(
                                      (data) => SavingAllserver.fromJson(data),
                                    )
                                    .toList();
                                EasyLoading.dismiss();
                                Navigator.pop(context);

                                Fluttertoast.showToast(
                                  backgroundColor: const Color(0xff00B050),
                                  msg: 'Savings Allocation has been created',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SavingAllocationSummary(data: data),
                                  ),
                                );
                              }
                            } else {
                              timer.cancel();
                              Navigator.pop(context);
                              var savingsbody = jsonDecode(response2.body);

                              var dataMessage = savingsbody["data"]['message'];
                              Fluttertoast.showToast(
                                backgroundColor: Colors.red,
                                //textColor: Colors.white,
                                msg: '$dataMessage',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          } else {
                            timer.cancel();
                            Navigator.pop(context);
                            var dataMessage = body["data"]['message'];
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              //textColor: Colors.white,
                              msg: '$dataMessage',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        }
                      } else {
                        timer.cancel();
                        Navigator.pop(context);

                        Fluttertoast.showToast(
                          backgroundColor: Colors.red,
                          //textColor: Colors.white,
                          msg: 'Amount is greater than Available allocation',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    }
                  } catch (e) {
                    print(e);
                    timer.cancel();
                    Navigator.pop(context);
                    //Navigator.pop(context);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: width * .04,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class SavAllocation {
  String token;
  SavAllocation(this.token);

  factory SavAllocation.fromJSON(dynamic json) {
    //return Token(json['access_token'] as String);
    return SavAllocation(json['data']['access_token'] as String);
  }

  @override
  String toString() {
    return ' { ${token} } ';
  }
}
