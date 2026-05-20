import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/utils/dialog.dart';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ThousandSeparatedDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text;
    String cleanedText = newText.replaceAll(RegExp(r'[^\d.]'), '');

    if (cleanedText.split('.').length > 2) {
      return oldValue; // Prevent multiple decimal points
    }

    List<String> parts = cleanedText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1].padRight(0) : '';
    if (decimalPart.length > 2) decimalPart = decimalPart.substring(0, 2);

    if (integerPart.isEmpty && decimalPart.isEmpty && !newText.contains('.')) {
      return TextEditingValue.empty;
    }
    if (integerPart.isEmpty && newText.contains('.')) integerPart = "0";

    String formattedIntegerPart = integerPart.isNotEmpty
        ? NumberFormat('#,##0', 'en_US').format(int.tryParse(integerPart) ?? 0)
        : integerPart == "0"
        ? "0"
        : "";

    String resultText;
    if (newText.endsWith('.') && decimalPart.isEmpty) {
      resultText = '$formattedIntegerPart.';
    } else if (parts.length > 1) {
      resultText = '$formattedIntegerPart.$decimalPart';
    } else {
      resultText = formattedIntegerPart;
    }

    // Adjust cursor position
    int selectionOffset =
        newValue.selection.end + (resultText.length - newText.length);
    selectionOffset = selectionOffset.clamp(0, resultText.length);

    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

class Bespoke2 extends StatefulWidget {
  final int selected;
  const Bespoke2({super.key, required this.selected});
  @override
  _Bespoke2State createState() => _Bespoke2State();
}

class _Bespoke2State extends State<Bespoke2> {
  var key = GlobalKey<FormState>();
  TextEditingController savingscalc1 = TextEditingController();
  TextEditingController savingscalc2 = TextEditingController();
  TextEditingController savingsname = TextEditingController();
  TextEditingController savingsdetails = TextEditingController();
  final TextEditingController _strategy = TextEditingController();

  DialogBox dialogBox = DialogBox();

  TextEditingController debtcalc1 = TextEditingController();
  TextEditingController debtcalc2 = TextEditingController();
  TextEditingController debtname = TextEditingController();
  TextEditingController debtinterest = TextEditingController();
  TextEditingController debtdetails = TextEditingController();

  static const subUnits1 = <String>[
    'Select',
    'Savings Account',
    'Term Deposit',
    'Fixed Deposit',
    'Others',
  ];
  String sub1 = 'Select';
  final List<DropdownMenuItem<String>> _wheretoSave = subUnits1
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15.sp,
              color: const Color(0xff808080),
            ),
          ),
        ),
      )
      .toList();
  static const subUnits2 = <String>[
    'Select',
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
  String sub2 = 'Select';
  final List<DropdownMenuItem<String>> _savingsType = subUnits2
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14.sp,
              color: const Color(0xff808080),
            ),
          ),
        ),
      )
      .toList();

  static const subUnits3 = <String>[
    'Select',
    'Credit Card',
    'Overdraft',
    'Loans',
    'Friends and Family',
    'Delayed Payment',
    'Hire Purchase',
    'Others',
  ];
  String sub3 = 'Select';
  final List<DropdownMenuItem<String>> _whoYouOwe = subUnits3
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: const Color(0xff808080),
            ),
          ),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    var currency = context.watch<Providers>().snapshotmodel.currency;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          widget.selected == 1
              ? TextButton(
                  onPressed: () async {
                    print("sub1: ${savingscalc2.text.replaceAll(',', '')}");
                    print("sub2: ${savingscalc1.text.replaceAll(',', '')}");
                    if (savingsname.text.isEmpty ||
                        savingsdetails.text.isEmpty ||
                        savingscalc1.text.isEmpty ||
                        savingscalc2.text.isEmpty ||
                        sub1 == "-Select-" ||
                        sub2 == "-Select") {
                      dialogBox.information(
                        context,
                        "Status",
                        "Please provide all details",
                      );
                    }
                    FocusScope.of(context).requestFocus(FocusNode());
                    dialogBox.waiting(context, 'Saving');
                    var url = Uri.parse("$baseUrl/app/bespoke");
                    var url7G = Uri.parse('$baseUrl/app/seveng');
                    Map data = {
                      "kpi_name": savingsname.text,
                      "purpose": sub2,
                      "cash": sub1,
                      "details": savingsdetails.text,
                      "strategy": _strategy.text,
                      "current": savingscalc2.text.replaceAll(',', ''),
                      "target": savingscalc1.text.replaceAll(',', ''),
                      "bespoke": "samnbvsjhnbvsnhbvsnvsjhsvnxjhxnvhbnvx",
                    };
                    final prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('tokenDB');
                    var response = await http.post(
                      url,
                      body: data,
                      headers: {
                        "Authorization": 'Bearer $token',
                        "Accept": "application/json",
                      },
                    );

                    final response4 = await http.get(
                      url7G,
                      headers: {"Authorization": 'Bearer $token'},
                    );
                    Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
                      jsonDecode(response4.body),
                    );
                    context.read<Providers>().setSevenGee(sevengeemodel);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * .035,
                      color: const Color(0xff009933),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (double.parse(debtcalc2.text) <
                        double.parse(debtcalc1.text)) {
                      Fluttertoast.showToast(
                        msg:
                            'The amount you currently owe cannot be greater than the amount you borrowed',
                      );
                      return;
                    }
                    if (debtname.text.isEmpty ||
                        debtinterest.text.isEmpty ||
                        debtcalc1.text.isEmpty ||
                        debtcalc2.text.isEmpty ||
                        debtdetails.text.isEmpty ||
                        sub3 == '-Select-') {
                      dialogBox.information(
                        context,
                        "Status",
                        "Please provide all details",
                      );
                      return;
                    }
                    dialogBox.waiting(context, "Saving");
                    var url = Uri.parse("$baseUrl/app/bespoke");
                    var url7G = Uri.parse('$baseUrl/app/seveng');

                    Map data = {
                      "kpi_name": debtname.text,
                      "interest": debtinterest.text,
                      "dept_type": sub3,
                      "details": debtdetails.text,
                      "current": debtcalc1.text,
                      "baseline": debtcalc2.text,
                      "bespoke": "dejhiojdnoijdnsnvhbnvxjhxnvsjhsvnxshyg",
                    };
                    final prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('tokenDB');
                    var response = await http.post(
                      url,
                      body: data,
                      headers: {
                        "Authorization": 'Bearer $token',
                        "Accept": "application/json",
                      },
                    );
                    final response4 = await http.get(
                      url7G,
                      headers: {"Authorization": 'Bearer $token'},
                    );
                    Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
                      jsonDecode(response4.body),
                    );
                    context.read<Providers>().setSevenGee(sevengeemodel);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * .035,
                      color: const Color(0xff009933),
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: const BottomNav(1),
      body: widget.selected == 1
          ? SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * .01),
                        Text(
                          'Saving Up Target',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Complete the form below',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .0),
                      child: Form(
                        key: key,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Give your KPI a name',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              controller: savingsname,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Enter a fancy name of yours...',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Where will the cash be kept?',
                                style: TextStyle(
                                  fontSize: width * .04,
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
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                                color: Colors.grey[100],
                                border: Border.all(
                                  color: const Color(0xffEDEDED),
                                  width: 0.5,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  focusColor: Theme.of(context).primaryColor,
                                  value: sub1,
                                  items: _wheretoSave,
                                  dropdownColor: Colors.white,
                                  onChanged: (subval) {
                                    setState(() {
                                      sub1 = subval!;
                                    });
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Purpose of savings target',
                                style: TextStyle(
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Container(
                              padding: EdgeInsets.only(
                                top: width * .015,
                                bottom: width * .015,
                                left: width * .015,
                                right: width * .015,
                              ),
                              width: width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                                color: const Color(0xffF5F5F5),
                                border: Border.all(
                                  color: const Color(0xffEDEDED),
                                  width: 0.5,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  focusColor: Theme.of(context).primaryColor,
                                  value: sub2,
                                  items: _savingsType,
                                  dropdownColor: Colors.white,
                                  onChanged: (subval) {
                                    setState(() {
                                      sub2 = subval!;
                                    });
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Details of your savings target',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff272727),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              maxLines: 6,
                              controller: savingsdetails,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText:
                                    'Give a description of your target...',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xff808080),
                                ),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'How much is your savings target',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      Text(
                                        currency,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 28.sp,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Flexible(
                                        child: TextFormField(
                                          controller: savingscalc1,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter a value';
                                            }
                                            final String unformattedValue =
                                                value.replaceAll(',', '');
                                            final numValue = double.tryParse(
                                              unformattedValue,
                                            );
                                            if (numValue == null ||
                                                numValue < 0) {
                                              return 'Enter a valid positive value';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            ThousandSeparatedDecimalFormatter(),
                                          ],
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: width * 0.06,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            hintStyle: TextStyle(
                                              fontSize: 28.sp,
                                              color: const Color(0xFFCACACA),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            contentPadding: EdgeInsets
                                                .zero, // Minimize padding
                                            isDense:
                                                true, // Reduces vertical padding
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'How much have you saved up now?',
                                style: TextStyle(
                                  fontSize: 14.h,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  currency,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28.sp,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Flexible(
                                  // Wrap TextFormField with Flexible
                                  child: TextFormField(
                                    controller: savingscalc2,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        // Same validation as savingscalc1
                                        return 'Enter a value';
                                      }
                                      final String unformattedValue = value
                                          .replaceAll(',', '');
                                      final numValue = double.tryParse(
                                        unformattedValue,
                                      );
                                      if (numValue == null || numValue < 0) {
                                        return 'Enter a valid positive value';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      ThousandSeparatedDecimalFormatter(), // Apply same formatter
                                    ],
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: width * 0.06,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(
                                        fontSize: 28.sp,
                                        color: const Color(0xFFCACACA),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      contentPadding:
                                          EdgeInsets.zero, // Minimize padding
                                      isDense: true, // Reduces vertical padding
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Personal Strategy',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              maxLines: 6,
                              controller: _strategy,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Outline your strategy clearly...',
                                hintStyle: TextStyle(fontSize: width * .04),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
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
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        Text(
                          'Debt Elimination Target',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Complete the form below',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .0),
                      child: Form(
                        key: key,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Give your KPI a name',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              controller: debtname,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Enter the creditors name...',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Interest on the amount owed',
                                style: TextStyle(
                                  fontSize: 14.h,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: TextFormField(
                                          controller: debtinterest,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter a value';
                                            }
                                            final numValue = int.tryParse(
                                              value,
                                            );
                                            if (numValue == null ||
                                                numValue < 0 ||
                                                numValue > 100) {
                                              return 'Enter a value between 0-100';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            // FilteringTextInputFormatter
                                            //     .digitsOnly,
                                            // LengthLimitingTextInputFormatter(
                                            //     3),
                                            ThousandSeparatedDecimalFormatter(),
                                          ],
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: width * 0.06,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            hintStyle: TextStyle(
                                              fontSize: 28.sp,
                                              color: const Color(0xFFCACACA),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            contentPadding: EdgeInsets
                                                .zero, // Minimize padding
                                            isDense:
                                                true, // Reduces vertical padding
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '%',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 28.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What type of debt is this?',
                                style: TextStyle(
                                  fontSize: 14.sp,
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
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                                color: const Color(0xffF5F5F5),
                                border: Border.all(
                                  color: const Color(0xffEDEDED),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  focusColor: Theme.of(context).primaryColor,
                                  value: sub3,
                                  items: _whoYouOwe,
                                  dropdownColor: Colors.white,
                                  onChanged: (subval) {
                                    setState(() {
                                      sub3 = subval!;
                                    });
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Details of your debt',
                                style: TextStyle(
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              maxLines: 6,
                              controller: debtdetails,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Give a description of your debt...',
                                hintStyle: TextStyle(fontSize: width * .04),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'How much do you currently owe?',
                                style: TextStyle(
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      Text(
                                        currency,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 28.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Flexible(
                                        child: TextFormField(
                                          controller: debtcalc1,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter a value';
                                            }
                                            final numValue = int.tryParse(
                                              value,
                                            );
                                            if (numValue == null ||
                                                numValue < 0 ||
                                                numValue > 100) {
                                              return 'Enter a value between 0-100';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            ThousandSeparatedDecimalFormatter(),
                                          ],
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: width * 0.06,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            hintStyle: TextStyle(
                                              fontSize: 28.sp,
                                              color: const Color(0xFFCACACA),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            contentPadding: EdgeInsets
                                                .zero, // Minimize padding
                                            isDense:
                                                true, // Reduces vertical padding
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'How much did you borrow originally?',
                                style: TextStyle(
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IntrinsicWidth(
                                  child: Row(
                                    children: [
                                      Text(
                                        currency,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 28.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Flexible(
                                        child: TextFormField(
                                          controller: debtcalc2,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Enter a value';
                                            }
                                            final numValue = int.tryParse(
                                              value,
                                            );
                                            if (numValue == null ||
                                                numValue < 0 ||
                                                numValue > 100) {
                                              return 'Enter a value between 0-100';
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            // amountValidator
                                            ThousandSeparatedDecimalFormatter(),
                                          ],
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: width * 0.06,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            hintStyle: TextStyle(
                                              fontSize: 28.sp,
                                              color: const Color(0xFFCACACA),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            contentPadding: EdgeInsets
                                                .zero, // Minimize padding
                                            isDense:
                                                true, // Reduces vertical padding
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Personal Strategy',
                                style: TextStyle(
                                  fontSize: width * .04,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: height * .005),
                            TextFormField(
                              maxLines: 6,
                              controller: savingsdetails,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Outline your strategy clearly...',
                                hintStyle: TextStyle(fontSize: width * .04),
                                contentPadding: EdgeInsets.all(width * .03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
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
}
