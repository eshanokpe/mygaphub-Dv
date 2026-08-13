import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'presentation/retiredash.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Retirement extends StatefulWidget {
  final bool treesisty;
  const Retirement({super.key, this.treesisty = false});
  @override
  _RetirementState createState() => _RetirementState();
}

class _RetirementState extends State<Retirement> {
  var key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController provider = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController generate = TextEditingController();
  TextEditingController monthly = TextEditingController();
  TextEditingController retire = TextEditingController();
  TextEditingController date = TextEditingController();
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  var dateDB = "";
  var endDB = "";

  static const units1 = <String>[
    '-Select-',
    'Private Pension',
    'Company Pension',
    'State Pension',
    'Others',
  ];
  String type = '-Select-';
  final List<DropdownMenuItem<String>> typeList = units1
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.black,
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Account: Retirement (Pension) ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: width * .035,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(
            vertical: height * .02,
            horizontal: width * .01,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .02),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      Text(
                        "(Complete the form below to record details of your pension)",
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
                                text: 'Give your pension plan a name:',
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
                          hintText: 'E.g. My Plan',
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
                                    'What is the name of the pension provider:',
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
                        controller: provider,
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
                                text: 'What type of pension is it:',
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
                            value: type,
                            items: typeList,
                            onChanged: (subval) {
                              setState(() {
                                type = subval!;
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
                                text: 'What is the current balance: ',
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
                        controller: current,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                                    'How much income will this balance generate now:',
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
                        controller: generate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                                text: 'How much do you contribute monthly: ',
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
                        controller: monthly,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                                    'What is the retirement age in your country:',
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
                        controller: retire,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: width * .03),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(width * .03),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Visibility(
                        visible:
                            Provider.of<Providers>(
                                  context,
                                  listen: false,
                                ).details.length >=
                                5
                            ? false
                            : false,
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
                                      text: 'What is your date of birth:',
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
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                                // var datez = DateTime.parse(start.text);
                                _showDatePicker(context);
                              },
                              child: TextFormField(
                                controller: date,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Field cannot be empty";
                                  }
                                  return null;
                                },
                                enabled: false,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.date_range,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  hintStyle: TextStyle(fontSize: width * .03),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(width * .03),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              ElevatedButton(
                onPressed: () {
                  if (key.currentState!.validate()) {
                    retirement();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .01),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    date.text = DateFormat('yyyy-MM-dd').format(selectedDate ?? now);
  }

  retirement() async {
    var url = Uri.parse("$baseUrl/app/360/retirement");
    var url1 = "$baseUrl/app/360/retirement/roi";
    var url2 = "$baseUrl/app/360/retirement";
    var urlr = "$baseUrl/app/360/tiles";

    FocusScope.of(context).requestFocus(FocusNode());
    if (type == "-Select-") {
      dialogBox.information(
        context,
        'Status',
        "Please select an option for all mandatory fields",
      );
      return;
    }
    dialogBox.waiting(context, "Saving");
    var timer = Timer(const Duration(milliseconds: 40000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var providDOB = Provider.of<Providers>(context, listen: false).details;
    print('date:$providDOB');

    if (providDOB.length >= 5) {
      print('date:${providDOB[4]}');
      if (providDOB[4] != 'null') {
        setState(() {
          dateDB = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.parse(providDOB[4].toString()));
        });
      }
    }

    Map data = {
      "pension_name": name.text,
      "pension_type": type,
      "pension_provider": provider.text,
      "monthly_cont": monthly.text,
      "current": current.text,
      "assured_income": generate.text,
      "retire_age": retire.text,
      "dob": date.text.isNotEmpty ? date.text : dateDB,
    };

    var response = await http.post(
      url,
      body: data,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var response = await dio.get(
        url1,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      var response2 = await dio.get(
        url2,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response2.statusCode == 200) {
        var response3 = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response3.data["tiles"]);
        final roiData = response.data['data'] as Map? ?? {};
        final retirementData = response2.data['data'] as Map? ?? {};
        context.read<Providers>()
          ..setretiredata(roiData)
          ..setpensions(retirementData);
        print('done');
        timer.cancel();
        Navigator.pop(context);
        Fluttertoast.showToast(
          backgroundColor: const Color(0xff00B050),
          msg: 'New Pension Account saved successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Retiredash()),
        );
      } else {
        timer.cancel();
        Navigator.pop(context);
      }
    } else {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(
        context,
        'Status',
        'Input a correct date of birth: GAPhub user must be at least 18 years of age.',
      );
    }
  }
}
