import 'dart:convert';

import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/seed_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'discretionary_allocation_summary.dart';

class FSDiscretionaryAllocation extends StatefulWidget {
  const FSDiscretionaryAllocation({super.key});

  @override
  State<FSDiscretionaryAllocation> createState() =>
      _DiscretionaryAllocationState();
}

class _DiscretionaryAllocationState extends State<FSDiscretionaryAllocation> {
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
  int budget_amount = 0;
  List<SavingAllserver> _data = [];

  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
    DateTime date = DateTime.parse(data['data']["current_seed"]["period"]);
    datez = d.format(date);
  }

  static const assets = <String>[
    '-Select-',
    'Charitable Giving',
    'Extended Family Support',
    'Personal Conviction Commitments',
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
    'Charitable Giving',
    'Extended Family Support',
    'Personal Conviction Commitments',
    'Others',
  ];
  final List<DropdownMenuItem<String>> optionList = subUnits1
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  navigateToPopPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> lastRoute = prefs.remove('last_route');
    // if (lastRoute.isNotEmpty && lastRoute != '/') {
    Navigator.of(context).pop(context);
    //}
  }

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
          'Discretionary Allocationdd',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.050),
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
                      "Discretionary Category",
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
                      setState(() {
                        val = value!;
                        if (val == assets[0]) {
                          dropdownError = "Please select a valid option";
                          isValid = false;
                        } else {
                          dropdownError = '';
                          isValid = true;
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
                      style: TextStyle(color: Colors.red),
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
                      if (value!.trim().isEmpty) {
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
                symbol: currency,
                inputFormatters: [amountValidator],
                validator: (value) {
                  if (value!.trim().isEmpty) {
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
                  try {
                    bool isValid = _key.currentState!.validate();
                    if (val == '-Select-') {
                      setState(() => dropdownError = "Please select an option");
                      isValid = false;
                    } else {
                      EasyLoading.show(status: 'Loading', dismissOnTap: false);
                      FocusScope.of(context).requestFocus(FocusNode());

                      // bool result = await isInternetAvailable();
                      // if (!result) {
                      //   dialogBox.information(context, 'Status',
                      //       'Check your Internet Connection');
                      //   EasyLoading.dismiss();
                      //   return;
                      // }
                      int amun = int.parse(savingAmount.text);

                      if (num.parse(allocationamount) < amun) {
                        EasyLoading.dismiss();
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
                        "$baseUrl/app/seed/allocate/budget?category=discretionary",
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
                            'category': 'discretionary',
                            'label': newlabell,
                            'code': 'rjkhbhfhdhbd',
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

                            //context.read<Providers>().setSeeData(body);
                            var response2 = await http.get(
                              url2,
                              headers: {"Authorization": 'Bearer $token'},
                            );
                            if (response2.statusCode == 200) {
                              //context.read<Providers>().setSeedshot(body);
                              //print('send');
                              //print(body);
                              var discretionarybody = jsonDecode(
                                response2.body,
                              );

                              var data =
                                  discretionarybody["data"]['budget_allocations'];
                              List res = data;
                              setState(() {
                                _data = res
                                    .map(
                                      (data) => SavingAllserver.fromJson(data),
                                    )
                                    .toList();
                              });
                              EasyLoading.dismiss();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FSDiscretionaryAllocationSummary(
                                        data: _data,
                                      ),
                                ),
                              );
                              Fluttertoast.showToast(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  77,
                                  125,
                                  153,
                                ),
                                msg:
                                    'Discretionary Allocation has been created',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          }
                        }
                      } else {
                        EasyLoading.dismiss();

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
                    EasyLoading.dismiss();
                    //Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Submit",
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
