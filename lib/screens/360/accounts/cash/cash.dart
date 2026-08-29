import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/screens/360/accounts/cash/cashdetails.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class Cash extends StatefulWidget {
  const Cash({super.key});

  @override
  _CashState createState() => _CashState();
}

class _CashState extends State<Cash> {
  var key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController target = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController rate = TextEditingController();

  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  bool show = false;
  var dateDB = "";
  DateTime? datealert;
  int _radioValue = 1;
  Map currencies = {};
  Map currenciesSys = {};

  String baseCurrency = "";
  String baseCurrency2 = "";

  static const units1 = <String>[
    '-Select-',
    'Savings Account',
    'Term Deposit',
    'Fixed Deposit',
    'Others',
  ];
  String accountType = '-Select-';
  final List<DropdownMenuItem<String>> accountTypeList = units1
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

  static const units2 = <String>[
    '-Select-',
    'Investment Pool Fund',
    'Rainy-Day Fund',
    'Personal Project Fund',
    'Family Project Fund',
    'Holiday Fund',
    'Car Purchase Fund',
    'Children Education Fund',
    'Home Purchase Savings',
    'Others',
  ];
  String purpose = '-Select-';
  final List<DropdownMenuItem<String>> purposeList = units2
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
  String prefix = "";

  String currency = '-Select-';
  String currencyShort = '';
  // double baseVal = 0;
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

  @override
  void initState() {
    super.initState();
    currenciesSys = jsonDecode(
      context.read<Providers>().systemCurrency["currencies"],
    );
    currenciesSys.removeWhere((key, value) => !currencyListS.contains(key));

    currencies = jsonDecode(
      context.read<Providers>().manualCurrency["currencies"],
    );
    currencies.removeWhere((key, value) => !currencyListS.contains(key));

    var baseCurrenc = context.read<Providers>().currency;
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Account: Cash",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: width * .040,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
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
                        "(Complete the form below for your savings target)",
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
                              const TextSpan(text: 'Give your account a name:'),
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
                        controller: name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                          hintText: 'E.g. New Car',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
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
                                text:
                                    'What type of bank account is holding the cash:',
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
                          child: DropdownButton(
                            focusColor: Theme.of(context).primaryColor,
                            value: accountType,
                            items: accountTypeList,
                            onChanged: (subval) {
                              setState(() {
                                accountType = subval as String;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
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
                                text:
                                    'How would you categorise the purpose of this funds:',
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
                          child: DropdownButton(
                            focusColor: Theme.of(context).primaryColor,
                            value: purpose,
                            items: purposeList,
                            onChanged: (subval) {
                              setState(() {
                                purpose = subval as String;
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
                          'Details of what you will like to do with this savings:',
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
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E.g. Buy my wife a new car',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Where is the funds located:',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        controller: location,
                        keyboardType: TextInputType.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Name of bank; e.g. Barclays',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(fontSize: width * .03),
                          contentPadding: EdgeInsets.only(
                            left: width * .013,
                            right: width * .03,
                          ),
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
                                text: 'Which currency is the funds held in',
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
                          child: DropdownButton(
                            focusColor: Theme.of(context).primaryColor,
                            value: currency,
                            items: _currency,
                            onChanged: (subval) {
                              setState(() {
                                currency = subval as String;
                                prefix = splitit(currency);
                                currencyShort = splitit1(currency);
                                _radioValue = 1;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
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
                                  onChanged: (val) {
                                    setState(() {
                                      _radioValue = val as int;
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
                                  onChanged: (val) {
                                    setState(() {
                                      _radioValue = val as int;

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
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "Field cannot be empty";
                                      }
                                      return null;
                                    },
                                    controller: rate,
                                    inputFormatters: [amountValidator],
                                    keyboardType: TextInputType.number,
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
                                    icon: Icon(
                                      Icons.save,
                                      color: Theme.of(context).primaryColor,
                                    ),
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
                                text: 'How much are you targeting to save:',
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
                        controller: target,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [amountValidator],
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
                              fontSize: width * .042,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'How much do you have saved up as at today:',
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
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
                          if (value == null || value.trim().isEmpty) {
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
                          'What date will you like to achieve this goal by:',
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
                            activeThumbColor: Theme.of(context).primaryColor,
                            value: show,
                            onChanged: (val) {
                              setState(() {
                                show = val;
                              });
                            },
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
                      SizedBox(height: height * .05),
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

    if (accountType == "-Select-" ||
        currency == "-Select-" ||
        purpose == "-Select-") {
      dialogBox.information(
        context,
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }

    dialogBox.waiting(context, "Saving");

    var timer = Timer(const Duration(seconds: 40), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    try {
      var url = Uri.parse("$baseUrl/app/360/cash");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      Map<String, String> data = {
        "name": name.text,
        "cash": accountType,
        "purpose": purpose,
        "details": details.text,
        "fund": location.text,
        "currency": currency,
        "target": target.text,
        "current": current.text,
        "automated_rate": "$_radioValue",
        "analytics": show.toString(),
      };

      if (dateDB.isNotEmpty) {
        data["target_date"] = dateDB;
      }

      var postResponse = await http.post(
        url,
        body: data,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (postResponse.statusCode != 200) {
        timer.cancel();
        if (Navigator.canPop(context)) Navigator.pop(context);

        String errorMsg = "An error occurred";
        if (postResponse.body.isNotEmpty) {
          try {
            final decoded = jsonDecode(postResponse.body);
            errorMsg =
                decoded['message'] ?? decoded['error'] ?? postResponse.body;
          } catch (_) {
            errorMsg = postResponse.body;
          }
        }

        dialogBox.information(context, 'Status', errorMsg);
        return;
      }

      // Fetch updated cash data
      var getCashResponse = await dio.get(
        "$baseUrl/app/360/cash",
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      var mapList = getCashResponse.data["cash"];
      var seveng = getCashResponse.data["seveng"];
      var mapListLite = getCashResponse.data["cash_detail"];
      var bespokes = getCashResponse.data["bespokes"];

      // ✅ FIXED: Parallel fetching with explicit types
      final results = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/app/seveng'),
          headers: {"Authorization": 'Bearer $token'},
        ),
        http.get(
          Uri.parse('$baseUrl/app/snapshot'),
          headers: {"Authorization": 'Bearer $token'},
        ),
        dio.get(
          "$baseUrl/app/360/tiles",
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        ),
      ]);

      final sevengResponse = results[0] as http.Response;
      final snapshotResponse = results[1] as http.Response;
      final tilesResponse = results[2] as Response;

      Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
        jsonDecode(sevengResponse.body),
      );
      context.read<Providers>().setSevenGee(sevengeemodel);

      Snapshotmodel snapshotmodel = Snapshotmodel.fromJson(
        jsonDecode(snapshotResponse.body),
      );
      context.read<Providers>().setSnapshot(snapshotmodel);

      context.read<Providers>().setRecent(tilesResponse.data["tiles"]);

      timer.cancel();
      if (Navigator.canPop(context)) Navigator.pop(context);

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Cashdetails(mapList, mapListLite, seveng, bespokes),
        ),
      );

      Fluttertoast.showToast(msg: 'Account saved successfully');
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) Navigator.pop(context);
      dialogBox.information(
        context,
        'Status',
        'Network Error: ${e.toString()}',
      );
    }
  }
}
