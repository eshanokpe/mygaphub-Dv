// import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'dart:async';
import 'package:GapHub/screens/360/accounts/income/incomedash.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/screens/portfolio/assetclasses.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

final bucketGlobal = PageStorageBucket();

class Income extends StatefulWidget {
  final int? index;
  const Income({super.key, this.index});

  @override
  _IncomeState createState() => _IncomeState();
}

class _IncomeState extends State<Income>
    with AutomaticKeepAliveClientMixin<Income> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  var key = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController rate = TextEditingController();

  var associates = [];
  var mapAssets = [];

  var dateDB = "";
  var id = 0;
  static const subUnits1 = <String>[
    '-Select-',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Annually',
    'One-Off',
    'Others',
  ];
  String frequency = 'Monthly';
  final List<DropdownMenuItem<String>> frequencyList = subUnits1
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
  static const subUnits2 = <String>[
    '-Select-',
    'Primary Employment',
    'Side Hustle',
  ];
  String channel = '-Select-';
  final List<DropdownMenuItem<String>> channelList = subUnits2
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

  static const subUnits3 = <String>[
    'Asset Portfolio Income',
    'Non-Portfolio Income',
  ];
  String type = 'Asset Portfolio Income';
  final List<DropdownMenuItem<String>> typeList = subUnits3
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
  String prefix = "";

  int _radioValue = 1;
  Map currencies = {};
  String baseCurrency = "";
  String currencyShort = '';
  String currency = '-Select-';
  Map currenciesSys = {};
  String baseCurrency2 = "";

  final List<DropdownMenuItem<String>> currencyLista = currencyList
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
  static const subUnits5 = <String>[
    '-Select-',
    'Target Income',
    'Current Income',
  ];
  String status = '-Select-';
  final List<DropdownMenuItem<String>> statusList = subUnits5
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
  String associate = '-Select-';
  PageStorageKey key1 = const PageStorageKey<String>('key_app_text');

  @override
  void initState() {
    super.initState();
    associates = context.read<Providers>().assets;
    print(associates);
    mapAssets = context.read<Providers>().mapAsset;
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
    final state = PageStorage.of(
      context,
    ).readState(context, identifier: 'pageOne');
    // print("state:$state");
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final currency1 = splitit(context.watch<Providers>().currency);
    final portfolioDiff = context.watch<Providers>().portfolioDiff;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Account: Income",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: width * .040,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          key: key1,
          padding: EdgeInsets.symmetric(vertical: height * .02),
          color: Colors.grey[200],
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .04),
                child: Form(
                  key: key,
                  child: PageStorage(
                    bucket: PageStorageBucket(),
                    key: PageStorageKey(widget.index),
                    child: Column(
                      children: [
                        Text(
                          "(Complete the form below. You have $currency1$portfolioDiff more to allocate in your Asset Portfolio Income)",
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
                                const TextSpan(
                                  text: 'What type of income is it:',
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
                              value: type,
                              items: typeList,
                              onChanged: (subval) {
                                setState(() {
                                  type = subval as String;
                                  if (subval == "Non-Portfolio Income") {
                                    frequency = "-Select-";
                                    name.clear();
                                    amount.clear();
                                  } else {
                                    frequency = "Monthly";
                                  }
                                });
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: type == 'Non-Portfolio Income',
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
                                            'What is the currency of the income:',
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
                                  borderRadius: BorderRadius.circular(
                                    width * .01,
                                  ),
                                  color: Colors.white,
                                  border: Border.all(),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    focusColor: Theme.of(context).primaryColor,
                                    value: currency,
                                    items: currencyLista,
                                    onChanged: (subval) {
                                      setState(() {
                                        currency = subval as String;
                                        prefix = splitit(currency);

                                        currencyShort = splitit1(currency);
                                        _radioValue = 1;
                                      });
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(FocusNode());
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
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
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
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontSize: width * .045,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                        Radio(
                                          value: 0,
                                          groupValue: _radioValue,
                                          onChanged: (val) {
                                            setState(() {
                                              _radioValue = val as int;
                                              rate.text =
                                                  currencies[currencyShort]
                                                      .toString();
                                            });
                                          },
                                        ),
                                        Text(
                                          'No',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
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
                                            const TextSpan(
                                              text: 'Enter rate below: ',
                                            ),
                                            TextSpan(
                                              text:
                                                  '1$baseCurrency = $currencyShort',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
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
                                                  value.isEmpty) {
                                                return "Field cannot be empty";
                                              }
                                              return null;
                                            },
                                            controller: rate,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            inputFormatters: [amountValidator],
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(
                                                fontSize: width * .03,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding: EdgeInsets.all(
                                                width * .03,
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: width * .02),
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.save,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            onPressed: () async {
                                              String url =
                                                  "$baseUrl/app/tools/preference/exchange";

                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              var token = prefs.getString(
                                                'tokenDB',
                                              );

                                              var response = await dio.post(
                                                url,
                                                data: {
                                                  "currency": currencyShort,
                                                  "rate": rate.text,
                                                },
                                                options: Options(
                                                  headers: {
                                                    "Authorization":
                                                        'Bearer $token',
                                                  },
                                                ),
                                              );
                                              if (response.statusCode == 200) {
                                                var urld =
                                                    "$baseUrl/app/dashboard";
                                                var responseD = await dio.get(
                                                  urld,
                                                  options: Options(
                                                    headers: {
                                                      "Authorization":
                                                          'Bearer $token',
                                                    },
                                                  ),
                                                );
                                                if (responseD.statusCode ==
                                                    200) {
                                                  context
                                                      .read<Providers>()
                                                      .setDashData(
                                                        responseD.data,
                                                      );
                                                  context
                                                      .read<Providers>()
                                                      .setCurrency(
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
                                                    msg:
                                                        'Error saving currency rate',
                                                  );
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'Error saving currency rate',
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
                            ],
                          ),
                        ),
                        Visibility(
                          visible: type != "Non-Portfolio Income",
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
                                            'Associate this income to an asset:',
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
                                  borderRadius: BorderRadius.circular(
                                    width * .01,
                                  ),
                                  color: Colors.white,
                                  border: Border.all(),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    focusColor: Theme.of(context).primaryColor,
                                    value: associate,
                                    items: associates.map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (subval) {
                                      setState(() {
                                        int index = associates.indexOf(subval);
                                        if (index == 0) {
                                          name.text = "";
                                          amount.text = "";
                                        } else {
                                          name.text =
                                              mapAssets[index - 1]["name"]
                                                  .toString();
                                          amount.text =
                                              mapAssets[index -
                                                      1]["monthly_roi"]
                                                  .toString();
                                          id = int.parse(
                                            mapAssets[index - 1]["id"]
                                                .toString(),
                                          );
                                        }
                                        associate = subval as String;
                                      });
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(FocusNode());
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .005),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    Text(
                                      "You need to have added the asset under Portfolio.",
                                      style: TextStyle(fontSize: width * .025),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        getAssetClasses(context, () {
                                          context
                                              .read<Providers>()
                                              .addAssetAcquisition(
                                                context
                                                    .read<Providers>()
                                                    .httpData,
                                              );
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (ctx) => AssetClasses(
                                                const ["existing"],
                                              ),
                                            ),
                                          );
                                        });
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             Select()));
                                      },
                                      child: Text(
                                        " Add asset in Portfolio now",
                                        style: TextStyle(
                                          fontSize: width * .025,
                                          decoration: TextDecoration.underline,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                const TextSpan(text: 'How much is the income:'),
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
                          controller: amount,
                          inputFormatters: [amountValidator],
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          enabled: type == 'Non-Portfolio Income',
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
                                  text: 'Give this income a name:',
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
                          controller: name,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          enabled: type == 'Non-Portfolio Income',
                          decoration: InputDecoration(
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
                                  text:
                                      'How frequently do you receive the income:',
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
                        Visibility(
                          visible: type != "Non-Portfolio Income",
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                initialValue: "Monthly",
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabled: false,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: width * .03),
                                  filled: true,
                                  fillColor: Colors.grey[10],
                                  contentPadding: EdgeInsets.all(width * .03),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: height * .03),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: type == "Non-Portfolio Income",
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  left: width * .015,
                                  right: width * .015,
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
                                  child: DropdownButton(
                                    focusColor: Theme.of(context).primaryColor,
                                    value: frequency,
                                    items: frequencyList,
                                    onChanged: (subval) {
                                      setState(() {
                                        frequency = subval as String;
                                      });
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(FocusNode());
                                    },
                                  ),
                                ),
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
                                  text: 'What is the income channel:',
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
                        Visibility(
                          visible: type != "Non-Portfolio Income",
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabled: false,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: width * .03),
                                  filled: true,
                                  fillColor: Colors.grey[10],
                                  contentPadding: EdgeInsets.all(width * .03),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: height * .03),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: type == "Non-Portfolio Income",
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: width * .015,
                                  right: width * .015,
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
                                  child: DropdownButton(
                                    focusColor: Theme.of(context).primaryColor,
                                    value: channel,
                                    items: channelList,
                                    onChanged: (subval) {
                                      setState(() {
                                        channel = subval as String;
                                      });
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(FocusNode());
                                    },
                                  ),
                                ),
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
                                  text: 'When was this income earned:',
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
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            // var datez = DateTime.parse(start.text);
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now().subtract(
                                const Duration(days: 1),
                              ), // Set the initial date to the previous day

                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            ).then((value) {
                              setState(() {
                                if (value != null) {
                                  dateDB = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(value);
                                  var d = DateFormat.yMMMMd();
                                  var dd = d.format(value);
                                  date.text = dd;
                                }
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                          },
                          child: TextFormField(
                            controller: date,
                            enabled: false,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: Icon(
                                Icons.date_range,
                                color: Theme.of(context).primaryColor,
                              ),
                              hintStyle: TextStyle(fontSize: width * .03),
                              contentPadding: EdgeInsets.only(
                                left: width * .013,
                                right: width * .03,
                              ),
                              border: const OutlineInputBorder(),
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
                                  text: 'What is the status of the income:',
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
                              value: status,
                              items: statusList,
                              onChanged: (subval) {
                                setState(() {
                                  status = subval as String;
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
                ),
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
                  //||(associate == "-Select-")
                  if (status == "-Select-" || frequency == "-Select-") {
                    dialogBox.information(
                      context,
                      "Status",
                      "Please provide all necessary details",
                    );

                    return;
                  }

                  if (channel == "-Select-" &&
                      type != "Asset Portfolio Income") {
                    return;
                  }
                  addIncome();
                },
                child: Text(
                  "Save",
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
      bottomNavigationBar: const BottomNav(4),
    );
  }

  addIncome() async {
    FocusScope.of(context).requestFocus(FocusNode());

    dialogBox.waiting(context, "Saving");

    var urlInc = "$baseUrl/app/360/income";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map data = {
      "income_type": type == 'Non-Portfolio Income'
          ? "non_portfolio"
          : "portfolio",
      "amount": amount.text,
      "channel": channel,
      "income_name": name.text,
      "income_frequency": frequency,
      "status": status,
      "income_date": dateDB,
      "automated_rate": "$_radioValue",
    };

    if (type == 'Non-Portfolio Income') {
      data["currency"] = currency;
    } else {
      data["portfolio_asset"] = id;
    }
    try {
      var response = await dio.post(
        urlInc,
        data: data,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        var response = await dio.get(
          urlInc,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        List incomeData = response.data["incomes"];
        var incomeDataLite = response.data["income_detail"];
        num currentPortfolio = int.parse(
          response.data["income_info"]["current_portfolio"].round().toString(),
        );

        // List<num> amounts =
        //     incomeData.map<num>((item) => item["amount"]).toList();

        num allocated = response.data["income_audit"] != null
            ? num.tryParse(
                    response.data["income_audit"]["income_allocated"]
                        .toString(),
                  ) ??
                  1
            : 1;

        print('data');

        num portfolioDiff = response.data["income_info"]["portfolio_diff"];
        context.read<Providers>().setPortfolioDiff(portfolioDiff.toDouble());
        context.read<Providers>().setCurrentPortfolio(currentPortfolio);
        Navigator.pop(context);
        Navigator.pop(context);
        if (response.data["income_info"]["portfolio_diff"] > 0) {
          Fluttertoast.showToast(
            backgroundColor: const Color(0xff00B050),
            msg: 'New Income Account has been Saved Successfully ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          get360Data();
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => Decider("Income")));
        } else {
          var incomes = response.data["incomes"] ?? [];
          var channels = response.data["income_channels"] ?? {};
          Fluttertoast.showToast(msg: 'Income has been added successfully');
          // print('incomeData:$incomeData');
          print('channels:$channels');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Incomedash(
                incomeData,
                incomeDataLite,
                allocated,
                incomes: incomes,
                channels: channels,
              ),
            ),
          );
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'An error occured');
      }
    } catch (e) {
      print('exception:$e');
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Something went wrong, try again $e');
    }
  }

  get360Data() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var urlr = "$baseUrl/app/360/tiles";
    var urlInc = "$baseUrl/app/360/income";

    var responseInc = await dio.get(
      urlInc,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (responseInc.statusCode == 200) {
      List assets = responseInc.data["portfolio_asset"];

      List<String> listofassets = ['-Select-'];

      for (var i = 0; i < assets.length; i++) {
        if (assets[i]["isArchive"] != 1) {
          listofassets.add(
            "${assets[i]["name"]} (${assets[i]["asset_currency"]}${assets[i]["monthly_roi"].toStringAsFixed(2)})"
                .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
          );
        }
      }

      List incomeData = responseInc.data["incomes"];

      num currentPortfolio = 0; // Default value in case of null

      if (responseInc.data["income_info"]["current_portfolio"] != null) {
        currentPortfolio = num.parse(
          responseInc.data["income_info"]["current_portfolio"].toString(),
        );
      }

      List amounts = [];
      for (var i = 0; i < incomeData.length; i++) {
        amounts.add(incomeData[i]["amount"].round());
      }
      num total = 0;
      for (var i = 0; i < amounts.length; i++) {
        total = total + amounts[i];
      }

      context.read<Providers>().setAssets(listofassets);
      context.read<Providers>().setMapAsset(assets);
      num incomeInfo = responseInc.data["income_info"]["portfolio_diff"];
      print('dat2:$incomeInfo');
      context.read<Providers>().setPortfolioDiff(incomeInfo.toDouble());
      print('dat:${responseInc.statusCode}');

      if (responseInc.statusCode == 200) {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        Map titles = response.data['titles'];
        print("360:$titles");

        context.read<Providers>().setRecent(response.data["tiles"]);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Threesixty(),
            maintainState: true,
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Something went wrong");
      }
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  @override
  bool get wantKeepAlive => true;

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }
}

class Select extends StatelessWidget {
  const Select({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.only(top: width * .01),
      elevation: 5,
      title: Image.asset("assets/images/plus.png", height: height * .06),
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () async {
                    getAssetClasses(context, () {
                      context.read<Providers>().addAssetAcquisition(
                        context.read<Providers>().httpData,
                      );
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => AssetClasses(const ["existing"]),
                        ),
                      );
                    });
                  },
                  child: Text(
                    "Existing Asset (Currently Owned)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                    ),
                  ),
                ),
                SizedBox(height: height * .01),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () async {
                    var url = Uri.parse("$baseUrl/app/portfolio/information");
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');
                    var response = await http.get(
                      url,
                      headers: {"Authorization": 'Bearer $token'},
                    );
                    if (response.statusCode == 200) {
                      var dat = jsonDecode(response.body);
                      print('dattttt:$dat');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetClasses(const ["desired"]),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Desired Asset (Investment Goal)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }
}
