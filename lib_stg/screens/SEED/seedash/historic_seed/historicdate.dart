import 'dart:convert';
import 'package:GapHub/models/historicReportExpenditure.dart';
import 'package:GapHub/models/historicseddReport.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'reports/discretionary/discretionary_report.dart';
import 'reports/education/education_report.dart';
import 'reports/expenditure/expenditure_report.dart';
import 'reports/periodicData.dart';
import 'reports/savings/savings_report.dart';
import 'transaction_details.dart';

// ignore: must_be_immutable
class HistoricDate extends StatefulWidget {
  Map historicdata;
  String date;
  List list;
  HistoricDate({
    super.key,
    required this.historicdata,
    required this.date,
    required this.list,
  });

  @override
  State<HistoricDate> createState() => _HistoricDateState();
}

class _HistoricDateState extends State<HistoricDate> {
  int savings = 0;
  var total = 0;
  var totalactual;
  int education = 0;
  int expenditure = 0;
  int discretionary = 0;
  Map data = {};
  Map actual = {};
  String historicdate = '';
  Dio dio = Dio();
  Map seedData = {};
  Map dashData = {};
  Map historicData22 = {};
  Map historicvalue22 = {};

  @override
  void initState() {
    dashData = context.read<Providers>().dashdata;
    seedData = context.read<Providers>().seedata;
    super.initState();
    totalactual = widget.historicdata["data"]['record_seed'];
    data = widget.historicdata["data"]["monthly_seed"];
    savings = data["seed"]["savings"];
    education = data["seed"]["education"];
    expenditure = data["seed"]["expenditure"];
    discretionary = data["seed"]["discretionary"];
    //print("savings:$savings");
    total = data["total"];
    //print("data:$data");
    // print("total:$total");
  }

  String cdate1 = '';
  List<HistoricSeedReport> _data = [];
  List<HistoricReportExpenditure> _dataExpen = [];
  var emoji = false;
  bool smileEmoji = false;
  bool angryEmoji = false;
  bool equalEmoji = false;
  void checkSaving() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var urlSA = Uri.parse("$baseUrl/app/seed/history/${widget.date}/savings");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response2 = await http.get(
      urlSA,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    if (response2.statusCode == 200) {
      var body = jsonDecode(response2.body);
      List data = body['data']['allocations'];
      List res = data;
      setState(() {
        _data = res.map((data) => HistoricSeedReport.fromJson(data)).toList();
      });
      print('body:$data');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavingsReport(
            data: _data,
            list: widget.list,
            historicdate: historicdate,
            date: widget.date,
          ),
        ),
      );
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Something went Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void checkEducation() async {
    //print("date:${widget.date}");
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var urlSA = Uri.parse("$baseUrl/app/seed/history/${widget.date}/education");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response2 = await http.get(
      urlSA,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    if (response2.statusCode == 200) {
      var body = jsonDecode(response2.body);
      List data = body['data']['allocations'];
      setState(() {
        _data = data
            .map<HistoricSeedReport>(
              (data) => HistoricSeedReport.fromJson(data),
            )
            .toList();
      });
      // setState(() {
      //   _data = data.map((e) => HistoricSeedReport.fromJson(e)).toList();
      // });
      // print('body:$data');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EducationReport(
            data: _data,
            list: widget.list,
            historicdate: historicdate,
            date: widget.date,
          ),
        ),
      );
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Something went Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void checkDiscretionary() async {
    //print("date:${widget.date}");
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var urlSA = Uri.parse(
      "$baseUrl/app/seed/history/${widget.date}/discretionary",
    );
    var urlSeed = Uri.parse("$baseUrl/app/seed/");

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      urlSeed,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    var response2 = await http.get(
      urlSA,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    if (response2.statusCode == 200) {
      var body = jsonDecode(response2.body);
      List data = body['data']['allocations'];

      setState(() {
        _data = data.map((e) => HistoricSeedReport.fromJson(e)).toList();
      });
      print('body:$data');
      if (response.statusCode == 200) {
        //var body = jsonDecode(response.body);
        //svar average = body['data']['average_detail'];
        Map<String, dynamic> seeddata = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscretionaryReport(
              data: _data,
              list: widget.list,
              historicdate: historicdate,
              date: widget.date,
            ),
          ),
        );
        EasyLoading.dismiss();
      }
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Something went Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  //Check Expenditure Allocation Summary
  checkExpenditure() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var urlhistoric = Uri.parse(
      "$baseUrl/app/seed/history/${widget.date}/expenditure",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      urlhistoric,
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var dataExpen = body["data"]['allocations'];
      print("exp:$dataExpen");
      List res = dataExpen;
      setState(() {
        _dataExpen = res
            .map((dataExpen) => HistoricReportExpenditure.fromJson(dataExpen))
            .toList();
      });
      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenditureReport(
            data: _dataExpen,
            list: widget.list,
            historicdate: historicdate,
            date: widget.date,
          ),
        ),
      );
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Something went Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (total > totalactual) {
      smileEmoji = true;
    } else if (total < totalactual) {
      angryEmoji = true;
    } else if (total == totalactual) {
      equalEmoji = true;
    }
    final date = DateFormat("MMM, yyyy");
    cdate1 = DateFormat("dd, EEEEE, yyyy").format(DateTime.now());
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
          'My Historic Seed ',
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
                  Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  'Click any of the tiles to view details or ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * .03,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                // ..onTap = () async {
                                //   Map item;
                                //   String currency =
                                //       splitit(context.read<Providers>().currency);
                                //   final prefs =
                                //       await SharedPreferences.getInstance();
                                //   var token = prefs.getString('tokenDB');
                                //   var url = "$baseUrl/app/360/net";
                                //   var response = await dio.get(url,
                                //       options: Options(headers: {
                                //         "Authorization": 'Bearer $token'
                                //       }));
                                //   if (response.statusCode == 200) {
                                //     historicData22 =
                                //         seedData["data"]["historic_seed"];
                                //     int number = historicData22.length;
                                //     print("hisnumbertoricData:$number");
                                //     historicData22.forEach((key, value) {
                                //       historicvalue22 = value["table"];
                                //       historicvalue22.forEach((key, value) {
                                //         print('value is ${value}');
                                //       });
                                //     });
                                //     item = response.data;
                                //     //item = body['net_detail'];
                                //     // print("network:$netData");
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) => HistoricBarChart(
                                //               item: response.data,
                                //               historicData: historicData22,
                                //               currency: currency),
                                //         ));
                                //   }
                                // },
                                ..onTap = () async {
                                  var urlSA = Uri.parse(
                                    "$baseUrl/app/seed/history/${widget.date}/diffrences",
                                  );
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  var token = prefs.getString('tokenDB');
                                  var response = await http.get(
                                    urlSA,
                                    headers: {
                                      "Authorization": 'Bearer $token',
                                      "Accept": "application/json",
                                      "Content-Type":
                                          "application/x-www-form-urlencoded",
                                    },
                                  );
                                  if (response.statusCode == 200) {
                                    Map<String, dynamic> body = jsonDecode(
                                      response.body,
                                    );
                                    List<dynamic> data =
                                        body['data']['allocations'];
                                    print("datas:$data");

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionDetials(
                                              transdata: data,
                                              date: widget.date,
                                              historicdate: historicdate,
                                              list: widget.list,
                                            ),
                                      ),
                                    );
                                  } else {
                                    print("Error");
                                  }
                                },
                              text: 'click here ',
                              style: TextStyle(
                                color: Colors.red,
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
                      SizedBox(height: height * .01),
                      smileEmoji == true
                          ? Column(
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/greensmile.png',
                                  ), // Repla
                                ),
                                SizedBox(height: height * .01),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'You were',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            var urlSA = Uri.parse(
                                              "$baseUrl/app/seed/history/${widget.date}/diffrences",
                                            );
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            var token = prefs.getString(
                                              'tokenDB',
                                            );
                                            var response = await http.get(
                                              urlSA,
                                              headers: {
                                                "Authorization":
                                                    'Bearer $token',
                                                "Accept": "application/json",
                                                "Content-Type":
                                                    "application/x-www-form-urlencoded",
                                              },
                                            );
                                            if (response.statusCode == 200) {
                                              Map<String, dynamic> body =
                                                  jsonDecode(response.body);
                                              List<dynamic> data =
                                                  body['data']['allocations'];
                                              print("datas:$data");

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionDetials(
                                                        transdata: data,
                                                        date: widget.date,
                                                        historicdate:
                                                            historicdate,
                                                        list: widget.list,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              print("Error");
                                            }
                                          },
                                        text:
                                            ' $currency${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')} ', // Format and add a comma
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'under your budget',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      angryEmoji == true
                          ? Column(
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/redangry.png', // Replace with your local image path
                                  ), // Repla
                                ),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'You were',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            var urlSA = Uri.parse(
                                              "$baseUrl/app/seed/history/${widget.date}/diffrences",
                                            );
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            var token = prefs.getString(
                                              'tokenDB',
                                            );
                                            var response = await http.get(
                                              urlSA,
                                              headers: {
                                                "Authorization":
                                                    'Bearer $token',
                                                "Accept": "application/json",
                                                "Content-Type":
                                                    "application/x-www-form-urlencoded",
                                              },
                                            );
                                            if (response.statusCode == 200) {
                                              Map<String, dynamic> body =
                                                  jsonDecode(response.body);
                                              List<dynamic> data =
                                                  body['data']['allocations'];
                                              print("datas:$data");

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionDetials(
                                                        transdata: data,
                                                        date: widget.date,
                                                        historicdate:
                                                            historicdate,
                                                        list: widget.list,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              print("Error");
                                            }
                                          },
                                        text:
                                            ' $currency${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')} ', // Format and add a comma
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'over your budget',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      equalEmoji == true
                          ? Column(
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/neutral.png',
                                  ), // Repla
                                ),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'You were ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            var urlSA = Uri.parse(
                                              "$baseUrl/app/seed/history/${widget.date}/diffrences",
                                            );
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            var token = prefs.getString(
                                              'tokenDB',
                                            );
                                            var response = await http.get(
                                              urlSA,
                                              headers: {
                                                "Authorization":
                                                    'Bearer $token',
                                                "Accept": "application/json",
                                                "Content-Type":
                                                    "application/x-www-form-urlencoded",
                                              },
                                            );
                                            if (response.statusCode == 200) {
                                              Map<String, dynamic> body =
                                                  jsonDecode(response.body);
                                              List<dynamic> data =
                                                  body['data']['allocations'];
                                              print("datas:$data");

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionDetials(
                                                        transdata: data,
                                                        date: widget.date,
                                                        historicdate:
                                                            historicdate,
                                                        list: widget.list,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              print("Error");
                                            }
                                          },
                                        text: total == 0.00
                                            ? 'spot '
                                            : '$currency${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')} ', // Format and add a comma
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'on with your budget',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width * .04,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(height: height * .02),
                      PeriodicData(
                        date: widget.date,
                        historicdate: historicdate,
                        list: widget.list,
                      ),
                    ],
                  ),
                  SizedBox(height: height * .02),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * .05,
                      bottom: height * .01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Total Budget: $currency ${num.parse(total.toString()).toStringAsFixed(2)}"
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
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * .05,
                      bottom: height * .01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Total Actual: $currency${totalactual.toStringAsFixed(2)}"
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
                      child: InkWell(
                        onTap: () async {
                          checkSaving();
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
                                  '$currency$savings'.replaceAllMapped(
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
                        checkEducation();
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
                                '$currency$education'.replaceAllMapped(
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
                        checkExpenditure();
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
                                '$currency$expenditure'.replaceAllMapped(
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
                        checkDiscretionary();
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
                                '$currency${discretionary.toStringAsFixed(2)}'
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
          ],
        ),
      ),
    );
  }
}
