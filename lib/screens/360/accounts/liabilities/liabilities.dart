import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'liabilitydetails.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'dart:convert';

class Liabilities extends StatefulWidget {
  final bool unallocated;
  final int balance;

  const Liabilities({super.key, this.unallocated = false, this.balance = 0});

  @override
  _LiabilitiesState createState() => _LiabilitiesState();
}

class _LiabilitiesState extends State<Liabilities> {
  var key = GlobalKey<FormState>();
  TextEditingController creditor = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController baseline = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController interest = TextEditingController();
  TextEditingController period = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController rate = TextEditingController();

  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  bool unallocated = false;
  bool show = false;
  var dateDB = "";
  DateTime? datealert;

  static const creditTypeList = <String>[
    '-Select-',
    'Credit Card',
    'Overdraft',
    'Unsecured Loans',
    'Friends and Family',
    'Delayed Payment',
    'Hire Purchase',
    'Secured Loans',
    'Others',
  ];
  String creditType = '-Select-';
  final List<DropdownMenuItem<String>> _creditorType = creditTypeList
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  int _radioValue = 1;
  Map currencies = {};
  String baseCurrency = "";
  String currencyShort = '';
  Map currenciesSys = {};
  String baseCurrency2 = "";
  String prefix = "";
  String baseCurrenc = '';
  String currency = '-Select-';

  final List<DropdownMenuItem<String>> _currency = currencyList
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
  int? balance;
  @override
  void initState() {
    super.initState();
    setState(() => balance = context.read<Providers>().liabilitiesbalance);
    setState(
      () => unallocated = context.read<Providers>().liabilitiesunallocated,
    );
    currenciesSys = jsonDecode(
      context.read<Providers>().systemCurrency["currencies"],
    );
    currenciesSys.removeWhere((key, value) => !currencyListS.contains(key));
    currencies = jsonDecode(
      context.read<Providers>().manualCurrency["currencies"],
    );
    currencies.removeWhere((key, value) => !currencyListS.contains(key));

    baseCurrenc = context.read<Providers>().currency;
    baseCurrency = splitit(baseCurrenc);
    baseCurrency2 = splitit1(baseCurrenc);
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

    return Scaffold(
      appBar: unallocated
          ? AppBar(
              centerTitle: true,
              title: Text(
                "Add Account: Liabilities",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: width * .040,
                ),
              ),
            )
          : null,
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height * .02),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .04),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      Text(
                        "(Complete the form below for your credit reduction target)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * .035,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(text: 'Who is the creditor:'),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: creditor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. Barclaycard',
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'What type of credit account is this:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      Container(
                        padding: EdgeInsets.only(
                          left: width * .015,
                          right: width * .015,
                        ),
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * .01),
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            focusColor: Theme.of(context).primaryColor,
                            value: creditType,
                            items: _creditorType,
                            onChanged: (subval) {
                              setState(() {
                                creditType = subval!;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Details of what you did with the money: ',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: details,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. Carried out major car repairs',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Visibility(
                        visible: !unallocated,
                        child: Column(
                          children: [
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: width * .045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Which currency is the money borrowed:',
                                    ),
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        fontSize: width * .045,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * .015,
                              ),
                              width: width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                                color: Colors.white,
                                border: Border.all(),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  focusColor: Theme.of(context).primaryColor,
                                  value: currency,
                                  items: _currency,
                                  onChanged: (subval) {
                                    setState(() {
                                      currency = subval!;
                                      currencyShort = splitit1(currency);
                                      prefix = splitit(currency);

                                      _radioValue = 1;
                                    });
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Visibility(
                        visible:
                            currency != "-Select-" &&
                            baseCurrency2 != currencyShort,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: width * .045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Use the system\'s conversion rate?',
                                    ),
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(
                                        fontSize: width * .045,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * .015),
                            Visibility(
                              visible: _radioValue == 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "1 $baseCurrency2 = ${currenciesSys[currencyShort]} $currencyShort",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: width * .045,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Radio(
                                  value: 1,
                                  groupValue: _radioValue,
                                  onChanged: (int? val) {
                                    setState(() {
                                      _radioValue = val!;
                                    });
                                  },
                                ),
                                Text(
                                  'Yes',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                Radio(
                                  value: 0,
                                  groupValue: _radioValue,
                                  onChanged: (int? val) {
                                    setState(() {
                                      _radioValue = val!;

                                      rate.text = currencies[currencyShort]
                                          .toString();
                                    });
                                  },
                                ),
                                Text(
                                  'No',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                            SizedBox(height: height * .015),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: _radioValue == 0,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: width * .045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Enter rate below: '),
                                    TextSpan(
                                      text: '1$baseCurrency = $currencyShort',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    inputFormatters: [amountValidator],
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Field cannot be empty";
                                      }
                                      return null;
                                    },
                                    controller: rate,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        fontSize: width * .03,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.all(
                                        width * .03,
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: width * .02),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () async {
                                      String url =
                                          "$baseUrl/app/tools/preference/exchange";

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      var token = prefs.getString('tokenDB');

                                      var response = await dio.post(
                                        url,
                                        data: {
                                          "currency": currencyShort,
                                          "rate": rate.text,
                                        },
                                        options: Options(
                                          headers: {
                                            "Authorization": 'Bearer $token',
                                          },
                                        ),
                                      );
                                      if (response.statusCode == 200) {
                                        var urld = "$baseUrl/app/dashboard";
                                        var responseD = await dio.get(
                                          urld,
                                          options: Options(
                                            headers: {
                                              "Authorization": 'Bearer $token',
                                            },
                                          ),
                                        );
                                        if (responseD.statusCode == 200) {
                                          context.read<Providers>().setDashData(
                                            responseD.data,
                                          );
                                          context.read<Providers>().setCurrency(
                                            responseD
                                                .data["gap_currencies"]["user_currency"],
                                          );
                                          context
                                              .read<Providers>()
                                              .setManualCurrency(
                                                responseD
                                                    .data["gap_currencies"]["manual_currencies"],
                                              );
                                          context
                                              .read<Providers>()
                                              .setSystemCurrency(
                                                responseD
                                                    .data["gap_currencies"]["system_currencies"],
                                              );
                                          Fluttertoast.showToast(
                                            msg: "${response.data[1]}",
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: 'Error saving currency rate',
                                          );
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Error saving currency rate',
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * .03),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'How much did you borrow originally:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: baseline,
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          prefixText: prefix,
                          prefixStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text: 'How much do you have left to pay:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        controller: current,
                        inputFormatters: [amountValidator],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: prefix,
                          prefixStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'What is the interest rate on the amount borrowed:',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: interest,
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          suffixText: '%',
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'How much do you pay back periodically:',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: period,
                        inputFormatters: [amountValidator],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          prefixText: prefix,
                          prefixStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'When will you like to close this credit account:',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: dateDB.isNotEmpty,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Text(
                                dateDB,
                                style: TextStyle(
                                  fontSize: width * .045,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              DateTime now = DateTime.now();
                              showDatePicker(
                                context: context,
                                initialDate: now.add(const Duration(days: 1)),
                                firstDate: now.add(const Duration(days: 1)),
                                lastDate: DateTime(2100),
                              ).then((value) {
                                setState(() {
                                  if (value != null) {
                                    dateDB = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(value);

                                    datealert = value;
                                  }
                                });
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                              });
                            },
                            child: Text(
                              "Pick a date",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor,
                                fontSize: width * .045,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      /*  Visibility(
                            visible: !widget.unallocated,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: height * .03,
                                ),
                                Row(
                                  children: [
                                    Text("Show account in Analytics",
                                        style: TextStyle(
                                            fontSize: width * .045,
                                            fontWeight: FontWeight.w700)),
                                    Switch(
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        value: show,
                                        onChanged: (val) {
                                          setState(() {
                                            show = val;
                                          });
                                        })
                                  ],
                                ),
                              ],
                            )), */
                      Column(
                        children: [
                          SizedBox(height: height * .03),
                          Row(
                            children: [
                              Text(
                                "Show account in Analytics",
                                style: TextStyle(
                                  fontSize: width * .045,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Switch(
                                activeThumbColor: Theme.of(
                                  context,
                                ).primaryColor,
                                value: show,
                                onChanged: (val) {
                                  setState(() {
                                    show = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: height * .05),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width * .01),
                          ),
                        ),
                        onPressed: () {
                          if (key.currentState!.validate()) {
                            saveCash();
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: width * .045,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .01),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: width * .035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: "* ",
                                style: TextStyle(
                                  fontSize: width * .035,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const TextSpan(text: 'Fields are mandatory'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * .02),
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

  saveCash() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (creditType == "-Select-" || (currency == "-Select-" && !unallocated)) {
      dialogBox.information(
        context,
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }

    dialogBox.waiting(context, "Saving");

    var url = Uri.parse("$baseUrl/app/360/liability");
    var url2 = "$baseUrl/app/360/liability";
    var urlr = "$baseUrl/app/360/tiles";
    var url3 = Uri.parse('$baseUrl/app/seveng/edit');
    var url7G = Uri.parse('$baseUrl/app/seveng');

    Map data = {
      "lcreditor": creditor.text,
      "credit_type": creditType,
      "lia_detail": details.text,
      "interest": interest.text,
      "baseline": baseline.text,
      "current": current.text,
      "period_pay": period.text,
      "automated_rate": "$_radioValue",
      // "target_date": date.text,
    };

    if (dateDB.isNotEmpty) {
      data["target_date"] = dateDB;
    }
    if (unallocated) {
      data["credit"] = "ajknsjkndjckndcjknjksdncjmdnc";
      data["currency"] = baseCurrenc;
    } else {
      data["analytics"] = show.toString();
      data["currency"] = currency;
    }
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    try {
      var response = await http
          .post(url, body: data, headers: {"Authorization": 'Bearer $token'})
          .timeout(const Duration(seconds: 50));
      if (response.statusCode == 400) {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', response.body);
        return null;
      }
      print("statusCode:${response.statusCode}");

      if (response.statusCode == 200) {
        final response4 = await http.get(
          url7G,
          headers: {"Authorization": 'Bearer $token'},
        );
        Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
          jsonDecode(response4.body),
        );
        context.read<Providers>().setSevenGee(sevengeemodel);

        var response2 = await dio.get(
          url2,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        var response3 = await http.get(
          url3,
          headers: {"Authorization": 'Bearer $token'},
        );

        var mapList = response2.data["liabilities"];
        var mapListLite = response2.data["liabilities_detail"];
        var seveng = response2.data["seveng"];
        var bespokes = response2.data["bespokes"];
        var isAllocated = response2.data["audit"]["is_allocated"];

        var cu = jsonDecode(response3.body);
        //print("current:$cu");

        // Analyticsinfo analyticsinfo =
        //     Analyticsinfo.fromJson(jsonDecode(response3.body));
        num creditCurrent = 0;
        print("liabilities");

        creditCurrent =
            num.tryParse(cu['data']['credit']["current"].toString()) ?? 0;

        num total = 0;
        List real = [];
        if (seveng.isNotEmpty) {
          var a = seveng.map((e) => e["current"]).toList();

          for (var item in a) {
            real.add(int.parse(item.toString()));
          }

          for (var item in a) {
            total += num.parse(item);
          }
        }

        var response = await dio
            .get(
              urlr,
              options: Options(headers: {"Authorization": 'Bearer $token'}),
            )
            .timeout(const Duration(seconds: 50));
        context.read<Providers>().setRecent(response.data["tiles"]);
        if (isAllocated.toString() == "1") {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Liabilities Account saved successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Liabilitydetails(
                liabilityData: mapList,
                liabilityDataLite: mapListLite,
                seveng: seveng,
                bespokes: bespokes,
              ),
            ),
          );
        } else if (int.parse(creditCurrent.toString()) == 0) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Liabilities Account saved successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Liabilitydetails(
                liabilityData: mapList,
                liabilityDataLite: mapListLite,
                seveng: seveng,
                bespokes: bespokes,
              ),
            ),
          );
        } else if (total != int.parse(creditCurrent.toString())) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Liabilities Account saved successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Threesixty(
                unallocated: true,
                data: seveng,
                balance: seveng.isEmpty
                    ? creditCurrent.toInt()
                    : (creditCurrent - total).toInt(),
              ),
            ),
          );
        } else {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Liabilities Account saved successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Liabilitydetails(
                liabilityData: mapList,
                liabilityDataLite: mapListLite,
                seveng: seveng,
                bespokes: bespokes,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Error:$e");
      // Handle timeout or other errors
      Navigator.pop(context);
      dialogBox.information(
        context,
        'Status',
        'Service timed out, check your connection',
      );
    }
  }
}
