import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/acquisition/actionplan/actionplan.dart';
import 'package:GapHub/screens/homepage/assistance/assistant.dart';
import 'package:GapHub/screens/homepage/assistance/personal_assistant.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/actionplanserver.dart';
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/acquisition/opportunities.dart';
import 'package:flutter/material.dart';
import 'widget/acquisitionHeader.dart';
import 'widget/gradientimagecard.dart';

class Preacquisition extends StatefulWidget {
  const Preacquisition({super.key});
  @override
  _PreacquisitionState createState() => _PreacquisitionState();
}

class _PreacquisitionState extends State<Preacquisition> {
  DialogBox dialogBox = DialogBox();
  final Key _pageStrKey3 = const PageStorageKey('pageThree');
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        // appBar: CustomAppBarAcquisition(),
        backgroundColor: const Color(0XFFF6F6F6),
        body: SingleChildScrollView(
          key: _pageStrKey3,
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * .02),
                            Text(
                              'Asset Acquisition',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 20.sp,
                              ),
                            ),
                            Text(
                              'What asset class would you like to invest into today?',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                color: const Color(0xff808080),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .03),
                      GradientImageCard(
                        imagePath: 'assets/images/acquisition/bus_assets.jpeg',
                        title: 'Business Asset',
                        description:
                            'Buy an existing business currently generating revenue. An asset that can run without your physical presence',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Opportunities(value: 0),
                            ),
                          );
                        },
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(height: height * .03),
                      GradientImageCard(
                        imagePath:
                            'assets/images/acquisition/appreciating.jpeg',
                        title: 'Appreciating Asset',
                        description:
                            'Buy an existing business currently generating revenue. An asset that can run without your physical presence',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Opportunities(value: 1),
                            ),
                          );
                        },
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(height: height * .03),
                      GradientImageCard(
                        imagePath: 'assets/images/acquisition/risk.jpeg',
                        title: 'Risk Assets',
                        description:
                            'Explore the world of stocks and share. Many retirement plans in the world today are based on this vehicle.',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const Opportunities(value: 2),
                            ),
                          );
                        },
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(height: height * .05),
                      PersonalAssistant(width: width, height: height),
                      SizedBox(height: height * .05),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getactionp() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    try {
      dialogBox.waiting(context, 'Loading');
      var urlActionPlan = Uri.parse("$baseUrl/app/actionplan");
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      final response = await http.get(
        urlActionPlan,
        headers: {"Authorization": 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Actionplanserver actionplanserver = Actionplanserver.fromJson(
          jsonDecode(response.body),
        );

        var whatiwantB = actionplanserver.business;
        if (whatiwantB.isNotEmpty) {
          context.read<Providers>().popActionPlanB();
          for (var i = 0; i < whatiwantB.length; i++) {
            context.read<Providers>().addActionPlanB(
              Actionplanmodel(
                date: whatiwantB[i]["date"],
                note: whatiwantB[i]["note"],
              ),
            );
          }
        }

        var whatiwantR = actionplanserver.risk;
        if (whatiwantR.isNotEmpty) {
          context.read<Providers>().popActionPlanR();
          for (var i = 0; i < whatiwantR.length; i++) {
            context.read<Providers>().addActionPlanR(
              Actionplanmodel(
                date: whatiwantR[i]["date"],
                note: whatiwantR[i]["note"],
              ),
            );
          }
        }

        var whatiwantA = actionplanserver.appreciating;
        if (whatiwantA.isNotEmpty) {
          context.read<Providers>().popActionPlanA();
          for (var i = 0; i < whatiwantA.length; i++) {
            context.read<Providers>().addActionPlanA(
              Actionplanmodel(
                date: whatiwantA[i]["date"],
                note: whatiwantA[i]["note"],
              ),
            );
          }
        }

        var whatiwantI = actionplanserver.intellectual;
        if (whatiwantI.isNotEmpty) {
          context.read<Providers>().popActionPlanI();
          for (var i = 0; i < whatiwantI.length; i++) {
            context.read<Providers>().addActionPlanI(
              Actionplanmodel(
                date: whatiwantI[i]["date"],
                note: whatiwantI[i]["note"],
              ),
            );
          }
        }

        var whatiwantD = actionplanserver.depreciating;
        if (whatiwantD.isNotEmpty) {
          context.read<Providers>().popActionPlanD();
          for (var i = 0; i < whatiwantD.length; i++) {
            context.read<Providers>().addActionPlanD(
              Actionplanmodel(
                date: whatiwantD[i]["date"],
                note: whatiwantD[i]["note"],
              ),
            );
          }
        }

        Navigator.pop(context);
        timer.cancel();
        //Navigator.of(context).pushNamed('Actionplan');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Actionplan()),
        );
      } else {
        timer.cancel();
        Navigator.pop(context);
        dialogBox.information(context, 'Error', 'An error occured');
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error occured');
    }
  }
}
