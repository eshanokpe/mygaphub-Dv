import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'assetclasses.dart';
import 'braidetails.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

import 'widget/asset_class_widget.dart';
import 'widget/bar_view_content.dart';
import 'widget/global_view_content.dart';
import 'widget/investment_performanceWidget.dart';
import 'widget/portfolio_income_widget.dart';
import 'widget/returnInvestmentCard.dart';
import 'widget/tabar_section.dart';

// ignore: must_be_immutable
class Portdashboard extends StatefulWidget {
  final bool investmentModal;
  const Portdashboard({super.key, this.investmentModal = false});

  @override
  _PortdashboardState createState() => _PortdashboardState();
}

class _PortdashboardState extends State<Portdashboard>
    with SingleTickerProviderStateMixin {
  final Key _pageStrKey4 = const PageStorageKey('pageFour');
  final Color leftBarColor = const Color(0xffE6C069);
  final Color rightBarColor = const Color(0xffED3237);
  final double width = 7;
  bool switcher = false;
  String c = '';
  Map data = {};
  List assetValue = [];
  List<BarChartGroupData> rawBarGroups = [];
  List<BarChartGroupData> showingBarGroups = [];

  Dio dio = Dio();
  bool a = false;
  int touchedGroupIndex = 0;
  TabController? _tabController;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final barGroup0 = makeGroupData(0, 0, 0);
    final barGroup1 = makeGroupData(1, 10, 8);
    final barGroup2 = makeGroupData(2, 7, 3);
    final barGroup3 = makeGroupData(3, 2, 9);
    final barGroup4 = makeGroupData(4, 7, 7);
    final barGroup5 = makeGroupData(5, 6, 9);
    final barGroup6 = makeGroupData(6, 0, 0);
    final items = [
      barGroup0,
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
    data = context.read<Providers>().portfolio;
    // print("data:${data['data']["roi_watch"]["braid_roi"]}");
    a = context.read<Providers>().newPort;
    c = splitit(context.read<Providers>().currency);
    _timer = Timer(const Duration(seconds: 5), () {
      context.read<Providers>().setNewPort(false);
    });

    // Timer.run(() {
    //   if (widget.investmentModal) {
    //     dropdown(context);
    //   }
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.investmentModal) {
        dropdown(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _tabController!.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void dropdown(BuildContext context) {
    showDialog(context: context, builder: (context) => Select());
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
        
    List dataList = data['data']["roi_watch"]["braid_roi"];
    
    DialogBox dialogBox = DialogBox();
    pop() {
      SystemNavigator.pop();
    }

    if (a) Future.delayed(Duration.zero, () => dropdown(context));
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          // Show a dialog and return the result
          return await dialogBox.options(
            context,
            'Exit',
            'Are you sure you want to exit?',
            pop,
          );
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header section
                      Text(
                        'Global Asset Portfolio Management',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          fontFamily: 'Nunito',
                          color: Colors.black,
                          height: 32 / 20,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Global Diversification',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: AppColors.grayColor,
                          fontFamily: 'Nunito',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 20.h),
                      TabarSection(tabController: _tabController!),
                      SizedBox(
                        height: height * 0.42,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Center(child: GlobalViewContent(data: data)),
                            Center(child: BarViewContent(dataList: dataList)),
                          ],
                        ),
                      ),

                      // SizedBox(height: 5.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Return on investment [roi%] watch'.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.h,
                            color: Colors.black,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      ReturnInvestmentCard(data: data),
                      SizedBox(height: 24.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'investment performance CHARTS'.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.h,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                      InvestmentPerformanceWidget(showingBarGroups),
                      SizedBox(height: height * 0.03),
                      PortfolioIncomeWidget(),
                    ],
                  ),
                ),
                const AssetCardWidget(),
                SizedBox(height: height * 0.06),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * .06),
                  child: const Text(
                    'Ready to onboard an existing asset or set an investment goal?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff808080),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                PlusButton(
                  color: Colors.white,
                  iconsColor: AppColors.primaryColor,
                  textColor: AppColors.blackColor,
                  icons: Icons.add,
                  text: 'Add Asset',
                  onPressed: () {
                    final provider = context.read<Providers>();

                    getAssetClasses(context, () async {
                      provider.addAssetAcquisition(provider.httpData);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AssetClasses(const ["existing"]),
                        ),
                      );
                    });
                  },
                ),
                SizedBox(height: height * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }

  getData(String cap, String small) async {
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

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y1,
          color: leftBarColor,
          width: width,
        ),
        BarChartRodData(
          borderRadius: BorderRadius.zero,
          toY: y2,
          color: rightBarColor,
          width: width,
        ),
      ],
    );
  }
}

class Tabledata extends StatelessWidget {
  const Tabledata({super.key, required this.text, required this.thick});

  final String text;
  final bool thick;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: width * .04,
          fontWeight: thick ? FontWeight.w700 : FontWeight.w300,
        ),
      ),
    );
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
                  onPressed: () {
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
                  onPressed: () {
                    getAssetClasses(context, () async {
                      context.read<Providers>().addAssetAcquisition(
                        context.read<Providers>().httpData,
                      );
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetClasses(const ["desired"]),
                        ),
                      );
                    });
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
