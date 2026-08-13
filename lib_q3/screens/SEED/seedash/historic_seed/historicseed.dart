import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'historicbarchart.dart';
import 'historicdate.dart';

// ignore: must_be_immutable
class HistoricSeed extends StatefulWidget {
  Map data;
  HistoricSeed({super.key, required this.data});

  @override
  State<HistoricSeed> createState() => _HistoricSeedState();
}

class _HistoricSeedState extends State<HistoricSeed> {
  final date = DateFormat("MMM, yyyy");
  TextEditingController editingController = TextEditingController();
  String cdate1 = '';
  Dio dio = Dio();
  Map<String, dynamic> duplicateItemss = {};
  List<Widget> itemss = <Widget>[];
  double balance = 0;
  String query = '';
  String currency = '';
  Map data = {};
  String historicdate = '';
  Map _data = {};
  var first;
  var last;
  var total;
  var saving;
  var education;
  var expenditure;
  var expenditureval;
  var discretionary;
  //double saving;
  List list = [];
  Map dashData = {};
  Map seedData = {};
  Map historicData = {};
  Map historicvalue = {};

  @override
  void initState() {
    dashData = context.read<Providers>().dashdata;
    seedData = context.read<Providers>().seedata;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var UserDatamodels = Provider.of<Providers>(context, listen: false);
      currency = UserDatamodels.snapshotmodel.currency;
    });
    super.initState();
    data = widget.data["data"]['periods'];
    _data = widget.data["data"]['periods'];
    total = widget.data["data"]["average_detail"]["total"];
    saving = widget.data['data']["average_detail"]["table"]["savings"];
    //totalSpent = widget.data['data']["average_detail"]["table"]["savings"];
    print("saving:$saving");
    // saving = double.parse(sav);
    education = widget.data['data']["average_detail"]["table"]["education"];
    print("education:$education");
    expenditure = widget.data['data']["average_detail"]["table"]["expenditure"];
    //expenditure = expenditure.toDouble();
    print("expenditure:${expenditure.toDouble()}");
    discretionary =
        widget.data['data']["average_detail"]["table"]["discretionary"];
    print("discretionary:$discretionary");
    first = _data.values.first;
    last = _data.values.last;
    list = _data.values.toList();
    print('data:${_data.values.toList()}');
    data.forEach((key, value) {
      itemss.add(Text(date.format(DateTime.parse(value))));
    });
  }

  @override
  Widget build(BuildContext context) {
    cdate1 = DateFormat("dd, EEEEE, yyyy").format(DateTime.now());
    print(cdate1);
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenWidth = MediaQuery.of(context).size.width;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(.05),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Average Seed',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.blue.withOpacity(.0),
              width: width,
              child: Column(
                children: [
                  SizedBox(height: height * .02),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Click any of the tiles to view details or ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * .03,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              EasyLoading.show(
                                status: 'Loading',
                                dismissOnTap: false,
                              );
                              var timer = Timer(
                                const Duration(milliseconds: 20000),
                                () {
                                  Navigator.pop(context);
                                  dialogBox.information(
                                    context,
                                    'Status',
                                    'Service timed out',
                                  );
                                  EasyLoading.dismiss();
                                  return;
                                },
                              );
                              String currency = splitit(
                                context.read<Providers>().currency,
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var token = prefs.getString('tokenDB');
                              var url = "$baseUrl/app/360/net";
                              var response = await dio.get(
                                url,
                                options: Options(
                                  headers: {"Authorization": 'Bearer $token'},
                                ),
                              );
                              if (response.statusCode == 200) {
                                historicData =
                                    seedData["data"]["historic_seed"];
                                historicData.forEach((key, value) {
                                  historicvalue = value["table"];
                                  historicvalue.forEach((key, value) {});
                                });
                                timer.cancel();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistoricBarChart(
                                      item: response.data,
                                      historicData: historicData,
                                      currency: currency,
                                    ),
                                  ),
                                );
                                EasyLoading.dismiss();
                                EasyLoading.dismiss();
                              }
                            },
                          text: 'click here ',
                          style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                            fontSize: width * .035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: 'to view charts',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * .03,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .02),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: width * .02,
                    right: width * .02,
                  ),
                  width: width,
                  margin: EdgeInsets.only(
                    left: width * .18,
                    right: width * .18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 196, 196, 196),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: Text(
                        '${date.format(DateTime.parse(first))} - ${date.format(DateTime.parse(last))}',
                        textAlign: TextAlign.right,
                      ),
                      value: _data.values.contains(historicdate)
                          ? historicdate
                          : null,
                      items: _data.values
                          .map(
                            (data) => DropdownMenuItem<String>(
                              value: data.toString(),
                              child: Text(
                                date.format(DateTime.parse(data.toString())),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        setState(() {
                          historicdate = value!;
                        });
                        var urlSA = Uri.parse(
                          "$baseUrl/app/seed/history/$historicdate",
                        );
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');
                        var response = await http.get(
                          urlSA,
                          headers: {
                            "Authorization": 'Bearer $token',
                            "Accept": "application/json",
                            "Content-Type": "application/x-www-form-urlencoded",
                          },
                        );
                        if (response.statusCode == 200) {
                          Map<String, dynamic> body = jsonDecode(response.body);
                          // print("object:$body");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoricDate(
                                historicdata: body,
                                date: historicdate,
                                list: list,
                              ),
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: 'No Data Found ',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * .03),
            Padding(
              padding: EdgeInsets.only(left: width * .05, bottom: height * .01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Total : $currency ${num.parse(total.toString()).toStringAsFixed(2)}"
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    style: TextStyle(
                      fontSize: width * .04,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .02),
            Center(
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    // checkSaving();
                  },
                  // onTap: () async {},
                  child: Card(
                    color: const Color(0xff00B050),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    // elevation: 5,
                    child: Container(
                      width: width * .90,
                      padding: EdgeInsets.all(width * .05),
                      child: Column(
                        children: [
                          Text(
                            'Savings',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width * .07,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$currency${num.parse(saving.toString()).toStringAsFixed(2)}'
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontSize: width * .05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .02),
            Center(
              child: GestureDetector(
                onTap: () async {
                  // checkEducation();
                },
                child: Card(
                  color: const Color(0xffE6C069),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  // elevation: 5,
                  child: Container(
                    width: width * .90,
                    padding: EdgeInsets.all(width * .05),
                    child: Column(
                      children: [
                        Text(
                          'Education',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .07,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${num.parse(education.toString()).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: width * .05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .02),
            Center(
              child: GestureDetector(
                onTap: () async {
                  // checkExpenditure();
                },
                child: Card(
                  color: const Color(0xffD13B56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  // elevation: 5,
                  child: Container(
                    width: width * .90,
                    padding: EdgeInsets.all(width * .05),
                    child: Column(
                      children: [
                        Text(
                          'Expenditure',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .07,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${num.parse(expenditure.toString()).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: width * .05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .02),
            Center(
              child: GestureDetector(
                onTap: () async {
                  //checkDiscretionary();
                },
                child: Card(
                  color: const Color.fromARGB(255, 77, 125, 153),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  // elevation: 5,
                  child: Container(
                    width: width * .90,
                    padding: EdgeInsets.all(width * .05),
                    child: Column(
                      children: [
                        Text(
                          'Discretionary',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: width * .07,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$currency${num.parse(discretionary.toString()).toStringAsFixed(2)}'
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: width * .05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
