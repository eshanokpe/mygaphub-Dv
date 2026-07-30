import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/screens/acquisition/ganp/ganpdetails.dart';
import 'package:GapHub/screens/acquisition/reap/reapdetails.dart';
import 'package:GapHub/screens/analytics/edits/alpha.dart';
import 'package:GapHub/screens/analytics/edits/beta.dart';
import 'package:GapHub/screens/analytics/edits/credit.dart';
import 'package:GapHub/screens/analytics/edits/debt.dart';
import 'package:GapHub/screens/analytics/edits/education.dart';
import 'package:GapHub/screens/analytics/edits/freedom.dart';
import 'package:GapHub/screens/analytics/edits/grand.dart';
import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/screens/homepage/widget/search/search_content.dart';
import 'package:GapHub/screens/homepage/widget/search/search_widget.dart';
import 'package:GapHub/screens/more/viewProfile/view_profile.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analytics/edits/editpage.dart';

class Assistant extends StatefulWidget {
  final bool newUserAnalytics;
  final Analyticsinfo analyticsInfo;
  final List<int> realColors;

  const Assistant({
    super.key,
    required this.newUserAnalytics,
    required this.analyticsInfo,
    required this.realColors,
  });

  @override
  _AssistantState createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> {
  Map assistance = {};
  String empty = "";
  List payments = [];
  DialogBox dialogBox = DialogBox();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          assistance = context.read<Providers>().assistance ?? {};
          payments = assistance["payments"]?["reminders"] ?? [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes - this will auto-update when Provider changes
    assistance = context.watch<Providers>().assistance;

    // Safe access with null checks
    int dueday = 0;
    if (assistance["priority"] != null &&
        assistance["priority"]["dueday"] != null) {
      dueday = assistance["priority"]["dueday"];
    }

    // Update payments when assistance changes
    payments = assistance["payments"]?["reminders"] ?? [];

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PersonallAssitance(),

        Visibility(
          visible: assistance["priority"] == null,
          child: SizedBox(height: height * .02),
        ),
        Card(
          elevation: 0,
          color: const Color(0xffFDFDFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffF1F1F1), width: 0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: assistance["priority"] == null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12,
                  ),
                  child: RowViewDetails(
                    mainText: 'Priority Actions',
                    detailText: 'View all',
                    onTap: () {
                      if (assistance["personal"]?["type"] == 'profile') {
                        _handleProfileTap();
                      } else if (assistance["personal"]?["type"] == '7g') {
                        _handlePersonalSetupTap();
                      }
                    },
                    arrowTap: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 0,
                  color: const Color(0xffF7F7F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(
                      color: Color(0xffEAECF0),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // ONLY ONE item for personal setup (handles both '7g' and 'profile')
                      Visibility(
                        visible: assistance["personal"]?["setup"] != null,
                        child: InkWell(
                          onTap: () {
                            if (assistance["personal"]?["type"] == 'profile') {
                              _handleProfileTap();
                            } else if (assistance["personal"]?["type"] ==
                                '7g') {
                              _handlePersonalSetupTap();
                            }
                          },
                          child: ListTile(
                            title: Text(
                              'Complete your profile',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                fontSize: width * .040,
                              ),
                            ),
                            subtitle: Builder(
                              builder: (context) {
                                String subtitleText = empty;
                                if (assistance["personal"] != null &&
                                    assistance["personal"]?["setup"] != null) {
                                  dynamic rawName =
                                      assistance["personal"]?["setup"];
                                  if (rawName != null) {
                                    String nameStr = rawName.toString();
                                    const String prefixToOmit =
                                        "Complete your profile: ";
                                    if (nameStr.startsWith(prefixToOmit)) {
                                      subtitleText = nameStr.substring(
                                        prefixToOmit.length,
                                      );
                                    } else {
                                      subtitleText = nameStr;
                                    }
                                  }
                                }
                                return Text(
                                  subtitleText,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * .040,
                                  ),
                                );
                              },
                            ),
                            trailing: InkWell(
                              onTap: () {
                                if (assistance["personal"]?["type"] ==
                                    'profile') {
                                  _handleProfileTap();
                                } else if (assistance["personal"]?["type"] ==
                                    '7g') {
                                  _handlePersonalSetupTap();
                                }
                              },
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Acquisition item (GANP/REAP)
                      Visibility(
                        visible: assistance["acquisition"]?["asset"] != null,
                        child: InkWell(
                          onTap: () {
                            _handleAcquisitionTap();
                          },
                          child: ListTile(
                            title: Text(
                              'Complete your profile',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            subtitle: Builder(
                              builder: (context) {
                                String subtitleText = empty;
                                if (assistance["acquisition"] != null &&
                                    assistance["acquisition"]?["asset"] !=
                                        null) {
                                  dynamic rawName =
                                      assistance["acquisition"]?["asset"]["name"];
                                  if (rawName != null) {
                                    String nameStr = rawName.toString();
                                    const String prefixToOmit =
                                        "Complete your profile:";
                                    if (nameStr.startsWith(prefixToOmit)) {
                                      subtitleText = nameStr.substring(
                                        prefixToOmit.length,
                                      );
                                    } else {
                                      subtitleText = nameStr;
                                    }
                                  }
                                }
                                return Text(
                                  subtitleText,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * .040,
                                  ),
                                );
                              },
                            ),
                            trailing: InkWell(
                              onTap: () {
                                _handleAcquisitionTap();
                              },
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Hspace(height * .0075),
        Visibility(
          visible: assistance["priority"] == null,
          child: Row(
            children: [
              Text(
                '${assistance["priority"] == null ? empty : assistance["priority"]["name"]}',
                style: const TextStyle(),
              ),
              Wspace(width * .02),
              Visibility(
                visible: (dueday ?? 0) <= 3 && assistance["priority"] != null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).primaryColor,
                      size: width * .045,
                    ),
                    Text(
                      dueday == 0
                          ? "Today is the Due Date"
                          : "$dueday Day(s) to Due Date",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Hspace(height * .0075),
        // SizedBox(
        //   child: ListView.builder(
        //     itemCount: payments.length,
        //     shrinkWrap: true,
        //     physics:
        //         const NeverScrollableScrollPhysics(), // Changed to NeverScrollableScrollPhysics
        //     itemBuilder: (context, index) => Container(
        //       child: Text(
        //         "${payments[index]["name"]}: $currency${payments[index]["amount"]}",
        //         style: const TextStyle(color: Color(0xfff3f3f4)),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void _handlePersonalSetupTap() {
    dialogBox.waiting(context, 'Loading');
    String text = "${assistance["personal"]?["setup"]}";

    // Store the setup text in Provider for later use
    context.read<Providers>().setPersonalSetup(text);
    final storedSetup = context.read<Providers>().personalSetup;
    print("Stored setup: $storedSetup");

    var a = text
        .replaceAll("Validate ", '')
        .replaceAll('your ', '')
        .replaceAll('7G assumption', '')
        .trim();

    if (assistance["personal"]?["type"] == 'profile') {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewProfile()),
      );
    } else if (assistance["personal"]?["type"] == '7g') {
      Navigator.of(context).pop();
      seveng(a);
    }
  }

  void _handleAcquisitionTap() {
    dialogBox.waiting(context, 'Loading');
    if (assistance["acquisition"]?["type"] == 'ganp') {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Ganpdetails(assistance["acquisition"]?["asset"]),
        ),
      );
    } else {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Reapdetails(assistance["acquisition"]?["asset"]),
        ),
      );
    }
  }

  Future<void> seveng(String text) async {
    print("text:$text");
    var timer = Timer(const Duration(seconds: 40), () {
      if (mounted) {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
      }
      return;
    });

    dialogBox.waiting(context, 'Loading');
    var url = Uri.parse('$baseUrl/app/seveng/edit');

    final prefs = await SharedPreferences.getInstance();
    String? finalToken = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $finalToken'},
    );

    timer.cancel();

    if (response.statusCode == 200 && mounted) {
      var data = jsonDecode(response.body);
      Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(data['data']);
      context.read<Providers>().setAnalyticsInfo(analyticsinfo);

      Navigator.pop(context); // Pop loading dialog

      switch (text) {
        case 'Grand':
          final mainValue = analyticsinfo.grand?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("mainValueGrand:$mainValue");
          print("newUserGrand:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Grand(
                grandInfo: analyticsinfo,
                contains: widget.newUserAnalytics,
                newUser: newUser,
                fromSave: true,
              ),
            ),
          );
          break;
        case 'Freedom':
          final mainValue = analyticsinfo.freedom?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("mainValueFreedom:$mainValue");
          print("newUserFreedom:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Freedom(
                freedomInfo: analyticsinfo,
                newUser: newUser,
                fromSave: true,
              ),
            ),
          );
          break;
        case 'Education':
          final mainValue = analyticsinfo.education?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("mainValueEducation:$mainValue");
          print("newUserEducation:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Education(
                educationInfo: analyticsinfo,
                newUser: newUser,
                contains: widget.newUserAnalytics,
                fromSave: true,
              ),
            ),
          );
          break;
        case 'Debt':
          final mainValue = analyticsinfo.dept?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("newUserDebt:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Debt(
                debtInfo: analyticsinfo,
                newUser: newUser,
                contains: widget.newUserAnalytics,
                fromSave: true,
              ),
            ),
          );
          break;
        case 'Credit':
          final mainValue = analyticsinfo.credit?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("newUserCredit:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Credit(
                creditInfo: analyticsinfo,
                newUser: newUser,
                contains: widget.newUserAnalytics,
                fromSave: true,
              ),
            ),
          );
          break;
        case 'Beta':
          final mainValue = analyticsinfo.beta?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("newUserBeta:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Beta(
                betaInfo: analyticsinfo,
                newUser: newUser,
                contains: widget.newUserAnalytics,
                fromSave: true,
              ),
            ),
          );
          break;
        case 'Alpha':
          final mainValue = analyticsinfo.alpha?['main']?.toString() ?? '';
          final newUser = mainValue == '1';
          print("newUserAlpha:$newUser");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Alpha(
                newUser: newUser,
                alphaInfo: analyticsinfo,
                contains: widget.newUserAnalytics,
                fromSave: true,
              ),
            ),
          );
          break;
        default:
      }
    } else if (mounted) {
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'Failed to load data');
    }
  }

  Future<void> _refreshAssistanceData() async {
    setState(() {});

    try {
      final prefs = await SharedPreferences.getInstance();
      String? finalToken = prefs.getString('tokenDB');

      // Update this endpoint to the correct one for fetching assistance data
      var url = Uri.parse('$baseUrl/app/dashboard');

      var response = await http.get(
        url,
        headers: {"Authorization": 'Bearer $finalToken'},
      );
      print("assistance:$assistance");
      print("payments:$payments");
      if (response.statusCode == 200 && mounted) {
        var data = jsonDecode(response.body);
        // Update the assistance data in your Provider
        context.read<Providers>().setAssistance(data['assistance']);

        // Update local state
        setState(() {
          assistance = data['assistance'] ?? {};
          payments = assistance['assistance']["payments"]?["reminders"] ?? [];
        });
      }
    } catch (e) {
      print('Error refreshing assistance: $e');
      // if (mounted) {
      //   dialogBox.information(context, 'Error', 'Failed to refresh data');
      // }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleProfileTap() {
    dialogBox.waiting(context, 'Loading');
    String text = "${assistance["personal"]?["setup"]}";

    // Store the setup text in Provider for later use
    context.read<Providers>().setPersonalSetup(text);

    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewProfile()),
    );
  }
}

class PersonallAssitance extends StatelessWidget {
  const PersonallAssitance({super.key});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchContent()),
        );
      },
      child: Card(
        elevation: 0,
        color: const Color(0xffFDFDFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(
            color: Color.fromARGB(255, 241, 241, 241),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: height * .01),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 22.h,
                      backgroundColor: AppColors.grayColor2,
                      backgroundImage: const AssetImage(
                        'assets/images/personal_avatar.png',
                      ),
                    ),
                  ),
                  SizedBox(width: width * .03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Hi ${context.watch<Providers>().details[0]}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito',
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '!',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "I'm Samantha, your personal AI \nassistant. How can I help you today?",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: height * .01),
                      ],
                    ),
                  ),
                ],
              ),
              const SearchWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
