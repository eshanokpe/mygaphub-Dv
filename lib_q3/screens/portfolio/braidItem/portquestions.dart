import 'package:GapHub/models/AssetTypeModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'dart:convert';

import '../assetclasses.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Portquestions extends StatefulWidget {
  final List data;
  final String name;
  const Portquestions(this.data, this.name, {super.key});
  @override
  _PortquestionsState createState() => _PortquestionsState();
}

class _PortquestionsState extends State<Portquestions> {
  String currency = '-Select-';
  late AssetType asset;

  int _radioValue = 1;
  Map currenciesSys = {};
  Map currencies = {};
  String prefix = "";

  String baseCurrency = "";
  String baseCurrency2 = "";

  String currencyShort = '';
  String currencyShort2 = '';
  // List<DropdownMenuItem<String>> _assetList = [];
  List<AssetType> tempList = [];

  final List<DropdownMenuItem<String>> _currency = currencyList.map((
    String value,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (currencyFlags.containsKey(value))
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x0ff00000)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.asset(
                    currencyFlags[value]!,
                    width: 26,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }).toList();

  var key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController worth = TextEditingController();
  TextEditingController monthly = TextEditingController();
  TextEditingController credit = TextEditingController();
  TextEditingController projected = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController other = TextEditingController();

  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  void dropdown() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Select(),
    );
  }

  late List<DropdownMenuItem<AssetType>> _assetList;
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
    baseCurrency = splitit1(baseCurrenc);
    baseCurrency2 = splitit1(baseCurrenc);

    _assetList = tempList.map((asset) {
      return DropdownMenuItem<AssetType>(
        value: asset,
        child: Text(
          asset.name,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      );
    }).toList();

    switch (widget.name) {
      case "business assets":
        tempList = Provider.of<Providers>(
          context,
          listen: false,
        ).businessAssetType;
        break;
      case "appreciating assets":
        tempList = Provider.of<Providers>(
          context,
          listen: false,
        ).appreciatingAssetType;
        break;
      case "depreciating":
        tempList = Provider.of<Providers>(
          context,
          listen: false,
        ).depreciatingAssetType;
        break;
      case "intellectual":
        tempList = Provider.of<Providers>(
          context,
          listen: false,
        ).intellectualAssetType;
        break;
      case "risk assets":
        tempList = Provider.of<Providers>(context, listen: false).riskAssetType;
        break;
    }

    // print("tempList:${tempList}");
    for (var value in tempList) {
      // print("value${value}");
      _assetList.add(
        DropdownMenuItem<AssetType>(
          value: value,
          child: Text(
            value.name,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    asset = _assetList[0].value!;
  }

  @override
  void dispose() {
    other.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Portfolio Management',
          style: TextStyle(
            fontSize: width * .045,
            color: const Color(0xff808080),
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(3),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: height * .01,
            horizontal: width * .03,
          ),
          child: Form(
            key: key,
            child: Column(
              children: [
                Text(
                  "Please provide answers to the following questions for your asset",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                    fontSize: width * .05,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Give your asset a name",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                CustomInputField(
                  labelText: false,
                  obscureText: false,
                  hintText: "Enter a fancy name of yours...",
                  keyboardType: TextInputType.text,
                  controller: name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What currency is your asset held in?",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
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
                    color: const Color(0xfff5f5f5),
                    border: Border.all(color: const Color(0xffEDEDED)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      focusColor: Theme.of(context).primaryColor,
                      value: currency,
                      items: _currency,
                      dropdownColor: Colors.white,
                      onChanged: (subval) {
                        setState(() {
                          currency = subval!;
                          prefix = splitit(currency);
                          currencyShort = splitit1(currency);
                          currencyShort2 = splitit(currency);
                          _radioValue = 1;
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                ),
                SizedBox(height: height * .01),
                Visibility(
                  visible:
                      currency != "-Select-" && baseCurrency != currencyShort,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        Visibility(
                          visible: _radioValue == 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/increment.png',
                                  height: 25.h,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "1 $baseCurrency2 = ${currenciesSys[currencyShort]} $currencyShort",
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: Colors.black,
                                    fontSize: width * .045,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Do you want to use the system\'s conversion rate?',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Pushes buttons to opposite ends
                          children: <Widget>[
                            // Yes Button - Wrap with Expanded to allow it to take up available space
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _radioValue == 1
                                      ? AppColors.primaryColor
                                      : Colors
                                            .grey[300], // Active color if selected
                                  foregroundColor: _radioValue == 1
                                      ? Colors.white
                                      : Colors.black54, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20.0,
                                    ), // Adjust as needed
                                  ),
                                  elevation: _radioValue == 1
                                      ? 0
                                      : 0, // More elevation if selected
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ), // Adjust padding for height/width
                                ),
                                onPressed: () {
                                  // Only update state if it's not already selected
                                  if (_radioValue != 1) {
                                    setState(() {
                                      _radioValue = 1;
                                      // Optionally clear the rate field if needed when switching back to 'Yes'
                                      // rate.clear();
                                    });
                                  }
                                },
                                child: Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _radioValue == 0
                                      ? AppColors.primaryColor
                                      : Colors.white,
                                  foregroundColor: _radioValue == 0
                                      ? Colors.white
                                      : Colors.black54,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  side: BorderSide(
                                    color: _radioValue == 0
                                        ? AppColors.primaryColor
                                        : Colors.grey[400]!,
                                    width: 1.0,
                                  ),
                                  elevation: _radioValue == 0 ? 0 : 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  if (_radioValue != 0) {
                                    setState(() {
                                      _radioValue = 0;
                                      rate.text =
                                          currencies[currencyShort]
                                              ?.toString() ??
                                          '';
                                    });
                                  }
                                },
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily:
                                        'Nunito', // Ensure font consistency
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * .015),
                        Visibility(
                          visible: _radioValue == 0,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Enter rate below: ',
                                      ),
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
                              SizedBox(height: height * .015),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
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
                                                "Authorization":
                                                    'Bearer $token',
                                              },
                                            ),
                                          );
                                          if (responseD.statusCode == 200) {
                                            context
                                                .read<Providers>()
                                                .setDashData(responseD.data);
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
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              msg: 'Gapproperties Hub is Down',
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                            );
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
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select the most suitable Asset Type",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: const Color(0xff272727),
                      fontWeight: FontWeight.w500,
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
                    color: const Color(0xfff5f5f5),
                    border: Border.all(color: const Color(0xffEDEDED)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AssetType>(
                      isExpanded: true,
                      focusColor: Theme.of(context).primaryColor,
                      value: asset, // The selected AssetType object
                      items: _assetList, // List of DropdownMenuItem<AssetType>
                      dropdownColor: Colors.white,
                      onChanged: (AssetType? subval) {
                        // Ensure the type is AssetType
                        print("Selected subval: ${subval?.name}");
                        if (subval != null) {
                          setState(() {
                            asset =
                                subval; // Update the selected AssetType object
                            print("Selected asset: ${asset.name}");
                          });
                        }
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                ),
                // Text("${asset?.name}"),
                if (asset.name == "Other" || asset.name == "Others")
                  Padding(
                    padding: EdgeInsets.only(top: height * .02),
                    child: CustomInputField(
                      labelText: false,
                      obscureText: false,
                      hintText: "Other",
                      keyboardType: TextInputType.text,
                      controller: other,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Describe your asset",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                CustomInputField(
                  labelText: false,
                  obscureText: false,
                  hintText: "Write a short description of your asset...",
                  keyboardType: TextInputType.text,
                  controller: details,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What is the current value of your asset?",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                CustomInputField(
                  labelText: false,
                  obscureText: false,
                  inputFormatters: [amountValidator],
                  keyboardType: TextInputType.number,
                  controller: worth,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "How much income does this asset generate monthly?",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                CustomInputField(
                  labelText: false,
                  obscureText: false,
                  inputFormatters: [amountValidator],
                  prefix: Text(currencyShort2),
                  keyboardType: TextInputType.number,
                  controller: monthly,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What amount of debt is secured against this asset?",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                CustomInputField(
                  labelText: false,
                  obscureText: false,
                  inputFormatters: [amountValidator],
                  prefix: Text(currencyShort2),
                  keyboardType: TextInputType.number,
                  controller: credit,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What was the total cost of acquiring this asset?",
                    style: TextStyle(
                      fontSize: width * .040,
                      fontFamily: 'Nunito',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                CustomInputField(
                  labelText: false,
                  obscureText: false,
                  inputFormatters: [amountValidator],
                  prefix: Text(currencyShort2),
                  keyboardType: TextInputType.number,
                  controller: projected,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PlusButton(
                      textColor: Colors.white,
                      iconsColor: Colors.white,
                      icons: Icons.upgrade_outlined,
                      color: AppColors.primaryColor,
                      text: 'Add Asset',
                      onPressed: () {
                        if (key.currentState!.validate()) {
                          // showSuccessDialog(context);
                          addAsset();
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: height * .02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addAsset2() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (currency == "-Select-") {
      dialogBox.information(
        context,
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }

    dialogBox.waiting(context, "Saving");

    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    var url = Uri.parse("$baseUrl/app/portfolio/asset");
    var urld = "$baseUrl/app/portfolio";
    print("Adding Asset ID: ${asset.id}");

    List<String> newAssetData = [
      currency.toString(),
      name.text.trim(),
      details.text.trim(),
      worth.text.trim(),
      monthly.text.trim(),
      credit.text.trim(),
      projected.text.trim(),
      asset.id.toString(),
      other.text.trim(),
    ];

    List<String> dat = List.from(widget.data);
    dat.add(widget.name);
    dat.addAll(newAssetData);

    print("Final Asset Data: $dat");

    Map<String, String> data = {
      "asset_category": dat[0],
      "asset_class": dat[1],
      "currency": dat[2],
      "asset_name": dat[3],
      "description": dat[4],
      "asset_value": dat[5],
      "monthly_roi": dat[6],
      "credit_value": dat[7],
      "projected_value": dat[8],
      "portfolio_type": dat[9],
      "other": dat[10],
      "automated_rate": "$_radioValue",
    };

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    try {
      var response = await http.post(
        url,
        body: data,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("Asset added successfully.");
        var response5 = await dio.get(
          urld,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (response5.statusCode == 200) {
          context.read<Providers>().setPortfolio(response5.data);
        }

        timer.cancel();
        Navigator.pop(context);
        dropdown();
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_LONG,
        );
        timer.cancel();
        Navigator.pop(context);
      }
    } catch (e) {
      print("Exception caught: $e");
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
      );
      timer.cancel();
      Navigator.pop(context);
    }
  }

  Future<void> addAsset() async {
    // Unfocus any currently focused input field
    FocusScope.of(context).unfocus();

    // Validate mandatory fields
    if (currency == "-Select-") {
      dialogBox.information(
        context,
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }

    // Show a waiting dialog
    dialogBox.waiting(context, "Saving");

    // Set a timeout timer
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context); // Close the waiting dialog
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    // Define API endpoints
    var url = Uri.parse("$baseUrl/app/portfolio/asset");
    var portfolioUrl = "$baseUrl/app/portfolio";

    print("Adding Asset ID: ${asset.id}");

    // Prepare asset data
    List<String> newAssetData = [
      currency.toString(),
      name.text.trim(),
      details.text.trim(),
      worth.text.trim(),
      monthly.text.trim(),
      credit.text.trim(),
      projected.text.trim(),
      asset.id.toString(),
      other.text.trim(),
    ];

    List<String> dat = List.from(widget.data);
    dat.add(widget.name);
    dat.addAll(newAssetData);

    // print("Final Asset Data: $dat");
    print("Request Data: ${dat[1]}");
    if (dat[1] == 'business assets') {
      dat[1] = 'business';
    } else if (dat[1] == 'appreciating assets') {
      dat[1] = 'appreciating';
    } else if (dat[1] == 'depreciating') {
      dat[1] = 'depreciating';
    } else if (dat[1] == 'intellectual') {
      dat[1] = 'intellectual';
    } else if (dat[1] == 'risk assets') {
      dat[1] = 'risk';
    }

    // Map data for the API request
    Map<String, String> requestData = {
      "asset_category": dat[0],
      "asset_class": dat[1],
      "currency": dat[2],
      "asset_name": dat[3],
      "description": dat[4],
      "asset_value": dat[5],
      "monthly_roi": dat[6],
      "credit_value": dat[7],
      "projected_value": dat[8],
      "portfolio_type": dat[9],
      "other": dat[10],
      "automated_rate": "$_radioValue",
    };
    // print("Request Data: $requestData");

    // Retrieve token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    if (token == null) {
      print("Error: Token not found");
      Fluttertoast.showToast(
        msg: "Authentication error. Please log in again.",
        toastLength: Toast.LENGTH_LONG,
      );
      timer.cancel();
      Navigator.pop(context);
      return;
    }

    try {
      // Send POST request to add asset
      var response = await http.post(
        url,
        body: requestData,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("Asset added successfully.");

        // Fetch updated portfolio data
        var portfolioResponse = await dio.get(
          portfolioUrl,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (portfolioResponse.statusCode == 200) {
          context.read<Providers>().setPortfolio(portfolioResponse.data);
        }

        timer.cancel();
        Navigator.pop(context); // Close the waiting dialog
        dropdown(); // Refresh dropdown or UI
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        Fluttertoast.showToast(
          msg: "Failed to add asset: ${response.body}",
          toastLength: Toast.LENGTH_LONG,
        );
        timer.cancel();
        Navigator.pop(context);
      }
    } catch (e) {
      print("Exception caught: $e");
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
      );
      timer.cancel();
      Navigator.pop(context);
    }
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
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      titlePadding: EdgeInsets.only(top: height * .02),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .04),
                    color: const Color(0xffFBFBFB),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/success.png",
                        height: height * .15,
                      ),
                      SizedBox(height: height * .01),
                    ],
                  ),
                ),
                SizedBox(height: height * .01),
                Text(
                  "Well done! You have added an asset to your Global Asset Portfolio (GAP)",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: height * .01),
                Row(
                  children: [
                    Text(
                      "Do you want to add another?",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: const Color(0xff494949),
                        fontWeight: FontWeight.w400,
                        fontSize: width * .04,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * .01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'No',
                        fontSize: 16,
                        borderRadius: 30,
                        borderColor: const Color(0xffefefef),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Dashboard(index: 3),
                            ),
                          );
                        },
                        color: Colors.white,
                        textColor: Colors.black,
                      ),
                    ),
                    SizedBox(width: width * .03),
                    Expanded(
                      child: CustomButton(
                        text: 'Yes',
                        fontSize: 16,
                        borderRadius: 30,
                        borderColor: const Color(0xffefefef),
                        onPressed: () {
                          getAssetClasses(context, () async {
                            context.read<Providers>().addAssetAcquisition(
                              context.read<Providers>().httpData,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AssetClasses(const ["existing"]),
                              ),
                            );
                          });
                        },
                        color: AppColors.primaryColor,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
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
