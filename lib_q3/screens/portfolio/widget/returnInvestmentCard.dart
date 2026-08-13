import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asset_rowWithTap.dart';

class ReturnInvestmentCard extends StatelessWidget {
  Map data;
  ReturnInvestmentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // print("trend:${data['data']["roi_trend"]}");
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: AppColors.cardColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: width * 05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  AssetRowWithTap(
                    imagePath: 'assets/images/business_icon.png',
                    title: 'Business Asset',
                    subtitleParts: const [
                      {
                        'text': 'B',
                        'color': Colors.black,
                        'fontWeight': true,
                        'underline': true,
                      },
                      {'text': 'AR', 'color': Colors.black54},
                    ],
                    trailing: true,
                    percentage:
                        '${data['data']["roi_watch"]["roi"][0].round()}%',
                    changeValue:
                        '${(data['data']["roi_trend"][0]["change"] ?? 0.0).toDouble().toStringAsFixed(1)}',
                    changeColor: const Color(0xffCE0001),
                    onTap: () {
                      getData("Business", "business", context);
                    },
                  ),
                  SizedBox(height: height * 0.01),
                  const Divider(
                    indent: 60.0,
                    thickness: 0.5,
                    color: Color(0xffE7E7E7),
                  ),
                  SizedBox(height: height * 0.01),
                  AssetRowWithTap(
                    imagePath: 'assets/images/appreciating_asset.png',
                    title: 'Appreciating Asset',
                    subtitleParts: const [
                      {'text': 'B', 'color': Colors.black54},
                      {
                        'text': 'A',
                        'color': Colors.black,
                        'fontWeight': true,
                        'underline': true,
                      },
                      {'text': 'R', 'color': Colors.black54},
                    ],
                    trailing: true,
                    percentage:
                        '${data['data']["roi_watch"]["roi"][2].round()}%',
                    changeValue:
                        '${(data['data']["roi_trend"][1]["change"] ?? 0).toDouble().toStringAsFixed(1)}',
                    changeColor: const Color(0xffce009933),
                    onTap: () {
                      getData("Appreciating", "appreciating", context);
                    },
                  ),
                  SizedBox(height: height * 0.01),
                  const Divider(
                    indent: 60.0,
                    thickness: 0.5,
                    color: Color(0xffE7E7E7),
                  ),
                  SizedBox(height: height * 0.01),
                  AssetRowWithTap(
                    imagePath: 'assets/images/risk_asset.png',
                    title: 'Risk Asset',
                    subtitleParts: const [
                      {'text': 'B', 'color': Colors.black54},
                      {'text': 'A', 'color': Colors.black54},
                      {
                        'text': 'R',
                        'color': Colors.black,
                        'fontWeight': true,
                        'underline': true,
                      },
                    ],
                    trailing: true,
                    percentage:
                        '${data['data']["roi_watch"]["roi"][1].round()}%',
                    changeValue:
                        '${(data['data']["roi_trend"][2]["change"] ?? 0).toDouble().toStringAsFixed(1)}',
                    changeColor: const Color(0xffCE0001),
                    onTap: () {
                      getData("Risk", "risk", context);
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getData(String cap, String small, BuildContext context) async {
    // Fluttertoast.showToast(msg: "Opening");
    Timer timer = Timer(const Duration(seconds: 40), () {
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
      var bus = jsonDecode(response.body);
      print("business:$bus");

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
