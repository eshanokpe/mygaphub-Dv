import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:http/http.dart' as http;

class Investdash extends StatefulWidget {
  final sums;
  const Investdash({super.key, this.sums});

  @override
  _InvestdashState createState() => _InvestdashState(sums);
}

class _InvestdashState extends State<Investdash> {
  final sums;

  _InvestdashState(this.sums);

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    DialogBox dialogBox = DialogBox();
    List<String> assets = [
      'Business Asset',
      'Risk Asset',
      'Appreciating Asset',
      'Intellectual Asset',
      'Depreciating Asset',
    ];
    String currenc = context.watch<Providers>().currency;
    String currency1 = splitit(currenc);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Global Investment Summary',
          style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: context.height() * .01),
            Center(
              child: Text(
                "Investment: $currency1${sums.toStringAsFixed(2)}"
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: TextStyle(
                  fontSize: context.width() * .06,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: context.height() * .01),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * .02,
                  vertical: height * .02,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .01),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    "Here is an aggregation of all your debt that secured against properties.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: height * 0.9,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Image.asset(
                    'assets/images/bridge.jpg',
                    height: height,
                    width: width,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    height: double.infinity,
                    width: width,
                    // color: Colors.black.withOpacity(.8),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: height * .03,
                      horizontal: width * .03,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          // height: height * .8,
                          // child: ListView.builder(
                          // itemCount: assets.length,
                          // itemBuilder: (context, index) =>
                          child: ListView(
                            children: <Widget>[
                              Card(
                                margin: EdgeInsets.zero,
                                color: const Color(0xffF3F3F3),
                                child: ListTile(
                                  onTap: () async {
                                    return getData("Business", "business");
                                  },
                                  title: Text(
                                    "Business",
                                    style: TextStyle(
                                      fontSize: width * .045,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  trailing: Image.asset(
                                    'assets/images/chevron_right.png',
                                    height: height * .04,
                                    width: width * .04,
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .01),
                              Card(
                                margin: EdgeInsets.zero,
                                color: const Color(0xffF3F3F3),
                                child: ListTile(
                                  onTap: () async {
                                    return getData("Risk", "risk")();
                                  },
                                  title: Text(
                                    "Risk",
                                    style: TextStyle(
                                      fontSize: width * .045,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  trailing: Image.asset(
                                    'assets/images/chevron_right.png',
                                    height: height * .04,
                                    width: width * .04,
                                  ),
                                ),
                              ),
                              SizedBox(height: height * .01),
                              Card(
                                margin: EdgeInsets.zero,
                                color: const Color(0xffF3F3F3),
                                child: ListTile(
                                  onTap: () async {
                                    return getData(
                                      "Appreciating",
                                      "appreciating",
                                    )();
                                  },
                                  title: Text(
                                    "Appreciating",
                                    style: TextStyle(
                                      fontSize: width * .045,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  trailing: Image.asset(
                                    'assets/images/chevron_right.png',
                                    height: height * .04,
                                    width: width * .04,
                                  ),
                                ),
                              ),
                              // Card(
                              //     margin: EdgeInsets.zero,
                              //     color: Color(0xffF3F3F3),
                              //     child: ListTile(
                              //       onTap: () async {
                              //         return getData(
                              //             "Intellectual", "intellectual")();
                              //       },
                              //       title: Text("Intellectual",
                              //           style: TextStyle(
                              //               fontSize: width * .045,
                              //               fontWeight: FontWeight.w400)),
                              //       trailing: Image.asset(
                              //         'assets/images/chevron_right.png',
                              //         height: height * .04,
                              //         width: width * .04,
                              //       ),
                              //     )),
                              // Card(
                              //     margin: EdgeInsets.zero,
                              //     color: Color(0xffF3F3F3),
                              //     child: ListTile(
                              //       onTap: () async {
                              //         return getData(
                              //             "Depreciating", "depreciating")();
                              //       },
                              //       title: Text("Depreciating",
                              //           style: TextStyle(
                              //               fontSize: width * .045,
                              //               fontWeight: FontWeight.w400)),
                              //       trailing: Image.asset(
                              //         'assets/images/chevron_right.png',
                              //         height: height * .04,
                              //         width: width * .04,
                              //       ),
                              //     )),
                            ],
                          ),
                        ),
                      ],
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

  getData(String cap, String small) async {
    // Fluttertoast.showToast(msg: "Opening");
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/portfolio/$small");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Braidetails(cap, jsonDecode(response.body), false),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }
}
