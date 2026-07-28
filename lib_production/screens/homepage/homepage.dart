import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/equity/equitydetails.dart';
import 'package:GapHub/screens/360/accounts/income/incomedash.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/screens/homepage/assistance/assistant.dart';
import 'package:GapHub/screens/homepage/incomecard.dart';
import 'package:GapHub/screens/others/dashboards/sort.dart';
import 'package:GapHub/screens/others/dashboards/seveng.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../others/dashboards/acquisition/acquisitioncard.dart';
import '../others/dashboards/dashboard.dart';
import '../others/dashboards/average_seed/averageSeed.dart';
import '../others/dashboards/homequitydash.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/ficard.dart';
import 'package:dio/dio.dart';

import '../others/dashboards/networkcard.dart';
import 'financial_intelligence_hub/financialIntelligenceHub_slider.dart';
import 'marketplace/market_place.dart';
import 'widget/row_view_details.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
    required this.width,
    required this.height,
    required this.newUserAnalytics,
    required this.analyticsInfo,
    required this.sliderKey,
    required this.realColors,
  });

  final double width;
  final double height;
  final bool newUserAnalytics;
  final Analyticsinfo analyticsInfo;
  final List<int> realColors;
  final GlobalKey sliderKey;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<charts.Series<Homequity, String>> _seriesPieData = [];
  final List<charts.Series<Networths, String>> _seriesBarData = [];
  DialogBox dialogBox = DialogBox();
  final Key _pageStrKey1 = const PageStorageKey('pageOne');

  Map alpha = {};
  Map beta = {};
  Map credit = {};
  Map debt = {};
  Map education = {};
  Map freedom = {};
  Map grand = {};
  Map residential = {};

  Dio dio = Dio();

  void _generatePieData(List values) {
    try {
      // Ensure values has at least 2 elements to avoid index errors
      final safeValues = values.length >= 2 ? values : [0, 0];

      // Convert values to integers (rounding if necessary)
      int homeValue = safeValues[1] is double
          ? safeValues[1].round()
          : (safeValues[1] is int ? safeValues[1] : 0);

      int mortgageValue = safeValues[0] is double
          ? safeValues[0].round()
          : (safeValues[0] is int ? safeValues[0] : 0);

      var data = [
        Homequity(name: 'Home Value', value: homeValue, colorVal: '0XFF56EC6F'),
        Homequity(
          name: 'Mortgage',
          value: mortgageValue,
          colorVal: '0XFFF8373C',
        ),
      ];

      _seriesPieData.add(
        charts.Series(
          data: data,
          domainFn: (Homequity home, _) => home.name,
          measureFn: (Homequity home, _) => home.value,
          colorFn: (Homequity home, _) =>
              charts.ColorUtil.fromDartColor(Color(int.parse(home.colorVal))),
          id: 'Finance Snapshot',
        ),
      );
    } catch (e) {
      print("Error generating pie data: $e");
      // Add empty/default series on error
      _seriesPieData.add(
        charts.Series(
          data: [],
          domainFn: (_, __) => '',
          measureFn: (_, __) => 0,
          id: 'Error',
        ),
      );
    }
  }

  _generateBarData(List? values, String currency) {
    // Ensure values is not null and has at least 2 elements
    List safeValues = [];

    if (values == null || values.isEmpty) {
      safeValues = [0.0, 0.0];
    } else if (values.length == 1) {
      safeValues = [values[0] ?? 0.0, 0.0];
    } else {
      safeValues = [values[0] ?? 0.0, values[1] ?? 0.0];
    }

    // Convert to double values
    double assetValue = safeValues[0] is int
        ? (safeValues[0] as int).toDouble()
        : (safeValues[0] as num?)?.toDouble() ?? 0.0;

    double liabilityValue = safeValues[1] is int
        ? (safeValues[1] as int).toDouble()
        : (safeValues[1] as num?)?.toDouble() ?? 0.0;

    var data = [
      Networths(
        name: 'Total Assets',
        value: assetValue,
        colorVal: '0XFF105068',
      ),
      Networths(
        name: 'Total Liabilities',
        value: liabilityValue,
        colorVal: '0XFFCCD3CA',
      ),
    ];

    _seriesBarData.add(
      charts.Series(
        data: data,
        domainFn: (Networths net, _) => net.name,
        measureFn: (Networths net, _) => net.value,
        colorFn: (Networths net, _) =>
            charts.ColorUtil.fromDartColor(Color(int.parse(net.colorVal))),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: 'Finance Snapshot',
        labelAccessorFn: (Networths net, _) =>
            '$currency${net.value.toStringAsFixed(2)}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
      ),
    );
  }

  Map dashData = {};
  Map seeData = {};
  Map netData = {};
  Map sortDash = {};
  int unseenNotifications = 0;

  @override
  void initState() {
    super.initState();
    fetchProperties();
    Loginusermodel loginDetails = context.read<Providers>().loginDetails;
    unseenNotifications = loginDetails.unseenNotifications!;
    dashData = context.read<Providers>().dashdata;
    alpha = context.read<Providers>().analyticsinfo.alpha!;
    beta = context.read<Providers>().analyticsinfo.beta!;
    credit = context.read<Providers>().analyticsinfo.credit!;
    debt = context.read<Providers>().analyticsinfo.dept!;
    education = context.read<Providers>().analyticsinfo.education!;
    freedom = context.read<Providers>().analyticsinfo.freedom!;
    grand = context.read<Providers>().analyticsinfo.grand!;

    seeData = dashData["average_detail"] ?? {};
    netData = dashData["net_detail"] ?? {};
    sortDash = dashData["dashboard"] ?? {};
    residential = dashData["residential"]?["primary"] ?? {};

    _seriesPieData = [];

    // Safely access nested data with null checks and provide empty List fallback
    final values = residential["chart"]?["values"] ?? [];
    _generatePieData(values is List ? values : []);
    // _seriesBarData = [];
    String currency = splitit(context.read<Providers>().currency);
    // print("currency:$currency");
    _generateBarData(netData["values"], currency);
  }

  List<PropertyModel> properties = [];
  @override
  Widget build(BuildContext context) {
    context.watch<Providers>().supportData;

    var sorts = sortDash.values.toList();
    List<num> indices = [];

    for (var i = 0; i < sorts.length; i++) {
      if (sorts[i]) {
        indices.add(i);
      }
    }

    String date = DateFormat.d().format(DateTime.now());
    int day = int.parse(date);
    String currency = context.watch<Providers>().snapshotmodel.currency;

    List<Widget> sortWidgets = [
      Homequitydash(
        currency: currency,
        residential: residential,
        height: widget.height,
        width: widget.width,
      ),
      Networthcard(
        currency: currency,
        height: widget.height,
        width: widget.width,
        netData: netData,
        seriesBarData: _seriesBarData,
      ), 
      AverageSeed(
        currency: currency,
        height: widget.height,
        width: widget.width,
        seeData: seeData,
      ),
      Seveng(
        data: grand,
        title: "Grand",
        subtitle: "A measure of your benevolence",
      ),
      Seveng(
        data: freedom,
        title: "Freedom",
        subtitle:
            "A measure of your progress on your path to financial freedom",
      ),
      Seveng(
        data: education,
        title: "Education",
        subtitle:
            "A measure of how much you have saved up for your kids university education",
      ),
      Seveng(
        data: debt,
        title: "Debt",
        subtitle:
            "A measure of what you owe on your primary place of residence - own home",
      ),
      Seveng(
        data: credit,
        title: 'Credit',
        subtitle: 'Loans, Credit cards, HPIs, all unsecured debt.',
      ),
      Seveng(
        data: beta,
        title: 'Beta',
        subtitle: 'A measure of your house purchase funds saved up.',
      ),
      Seveng(
        data: alpha,
        title: "Alpha",
        subtitle: "A measure of your Rainy Day funds saved up",
      ),
    ];
    // Get the widgets to display based on indices
    List<Widget> displayedWidgets = [];

    if (indices.isEmpty) {
      // If no indices are selected, show default widgets (e.g., first 3)
      displayedWidgets = [
        sortWidgets[0], // Homequitydash
        sortWidgets[1], // Networthcard
        sortWidgets[2], // Donutdash
      ];
    } else {
      // Add widgets based on indices, with bounds checking
      for (var index in indices) {
        int intIndex = index.toInt();
        if (intIndex >= 0 && intIndex < sortWidgets.length) {
          displayedWidgets.add(sortWidgets[intIndex]);
        }
      }

      // If after filtering we have no widgets, show defaults
      if (displayedWidgets.isEmpty) {
        displayedWidgets = [sortWidgets[0], sortWidgets[1], sortWidgets[2]];
      }
    }

    pop() {
      SystemNavigator.pop();
    }

    final scrollController = ScrollController();
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // return Container();
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return await dialogBox.options(
            context,
            'Exit',
            'Are you sure you want to exit?',
            pop,
          );
        },
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Theme.of(context).primaryColor,
          strokeWidth: 2,
          onRefresh: () {
            return refresh();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Container(
              key: _pageStrKey1,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hi ${context.watch<Providers>().details[0]} 👋🏽',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.sp,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      greetings[day],
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  RowViewDetails(
                    arrowTap: true,
                    mainText: 'Current GAP Income',
                    detailText: 'View Details',
                    onTap: () async {
                      dialogBox.waiting(context, "Loading");

                      try {
                        var url = "$baseUrl/app/360/income";
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');

                        var response = await dio.get(
                          url,
                          options: Options(
                            headers: {"Authorization": 'Bearer $token'},
                          ),
                        );

                        if (response.statusCode == 200) {
                          var data = response.data;
                          var assets = data["portfolio_asset"];
                          var incomeData = data["incomes"];

                          var currentPortfolio =
                              data["income_info"]["current_portfolio"].round();
                          context.read<Providers>().setCurrentPortfolio(
                            currentPortfolio,
                          );

                          var amounts = incomeData
                              .map((item) => item["amount"])
                              .toList();
                          var total = amounts.fold(
                            0,
                            (prev, amount) => prev + amount.round(),
                          );

                          var incomeDataLite = data["income_detail"];
                          var listofassets = ['-Select-'];

                          var incomeAudit = data["income_audit"];
                          var allocated = incomeAudit != null
                              ? num.parse(
                                  incomeAudit["income_allocated"].toString(),
                                )
                              : 1;

                          for (var asset in assets) {
                            if (asset["isArchive"] != 1) {
                              listofassets.add(
                                "${asset["name"]} (${asset["asset_currency"]}${asset["monthly_roi"].toStringAsFixed(2)})"
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (match) => '${match[1]},',
                                    ),
                              );
                            }
                          }

                          var incomeInfo =
                              data["income_info"]["portfolio_diff"];

                          context.read<Providers>().setAssets(listofassets);
                          context.read<Providers>().setPortfolioDiff(
                            incomeInfo.toDouble(),
                          );
                          context.read<Providers>().setMapAsset(assets);
                          context.read<Providers>().setincomeDataLite(
                            incomeDataLite,
                          );

                          if (incomeInfo > 0) {
                            Navigator.pop(context);
                            navigateWithSlideTransition(
                              context: context,
                              destinationScreen: Decider("Income"),
                              transitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                            );
                          } else {
                            var incomes = data["incomes"] ?? [];
                            var channels = data["income_channels"] ?? {};
                            context.read<Providers>().addIncomeChart(
                              data["income_chart"],
                            );
                            Navigator.pop(context);
                            navigateWithSlideTransition(
                              context: context,
                              destinationScreen: Incomedash(
                                incomeData,
                                incomeDataLite,
                                allocated,
                                incomes: incomes,
                                channels: channels,
                              ),
                              transitionDuration: const Duration(
                                milliseconds: 200,
                              ),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(msg: 'Failed to fetch data');
                        }
                      } catch (error) {
                        Fluttertoast.showToast(
                          msg: 'Check your internet connection',
                        );

                        print("Error: $error");
                        // Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),

                  Incomecard(),
                  SizedBox(height: widget.height * 0.02),

                  FiCard(
                    width: widget.width,
                    height: widget.height,
                    yes: false,
                  ),
                  SizedBox(height: widget.height * .02),
                  // Display the filtered widgets
                  ...displayedWidgets,

                  // indices[2] != null
                  //     ? sortWidgets[indices[2].toInt()]
                  //     : Container(),
                  // DONUT
                  Acquisitioncard(properties: properties),
                  SizedBox(height: widget.height * .02),
                  Container(
                    key: widget.sliderKey,
                    child: const FinancialIntelligenceHubSlider(),
                  ),
                  SizedBox(height: widget.height * .02),
                  const MarketPlace(),
                  SizedBox(height: widget.height * .02),
                  Builder(
                    builder: (context) {
                      try {
                        return Assistant(
                          newUserAnalytics: widget.newUserAnalytics,
                          analyticsInfo: widget.analyticsInfo,
                          realColors: widget.realColors,
                        );
                      } catch (e) {
                        print("Error loading Assistant: $e");
                        return SizedBox(height: widget.height * .02);
                      }
                    },
                  ),

                  SizedBox(height: widget.height * .02),
                  PlusButton(
                    color: Colors.white,
                    iconsColor: AppColors.primaryColor,
                    textColor: AppColors.blackColor,
                    icons: Icons.edit,
                    text: 'Manage Snapshot View',
                    onPressed: () {
                      navigateWithSlideTransition(
                        context: context,
                        destinationScreen: Sort(),
                        transitionDuration: const Duration(milliseconds: 200),
                      );
                    },
                  ),
                  SizedBox(height: height * .02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * .04),
                    child: RichText(
                      text: TextSpan(
                        text:
                            '“Personal finance is only 20% head knowledge. It’s 80% behavior!” ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff808080),
                          fontFamily: 'Nunito',
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '- Dave Ramsey',
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Nunito',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      textAlign:
                          TextAlign.center, // Optional: Align text to center
                    ),
                  ),

                  SizedBox(height: widget.height * .08),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  refresh() async {
    var urld = "$baseUrl/app/dashboard";
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('tokenDB');
    var responseD = await dio.get(
      urld,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (responseD.statusCode == 200) {
      context.read<Providers>().setDashData(responseD.data);
      context.read<Providers>().setCurrency(
        responseD.data["gap_currencies"]["user_currency"],
      );
      context.read<Providers>().setManualCurrency(
        responseD.data["gap_currencies"]["manual_currencies"],
      );
      context.read<Providers>().setSystemCurrency(
        responseD.data["gap_currencies"]["system_currencies"],
      );
      context.read<Providers>().setAssistance(responseD.data["assistance"]);

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
      );
    }
  }

  Future<void> fetchProperties() async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(
        Uri.parse('$assetBaseUrl/propery-listing'),
      );
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final body = jsonDecode(responseBody);
        final List<PropertyModel> loadedProperties = [];

        for (var propertyJson in body['properties_list']) {
          loadedProperties.add(PropertyModel.fromJson(propertyJson));
        }

        setState(() {
          properties = loadedProperties;
        });
      } else {
        print('Failed to load properties. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out');
    } on SocketException catch (e) {
      print('Network error: $e');
    } catch (e) {
      print('Unexpected error: $e');
    } finally {
      client.close();
    }
  }

  toHomeEquity() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    var url2 = "$baseUrl/app/360/equity";
    var url3 = "$baseUrl/app/360/investment";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Dio dio = Dio();
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response3 = await dio.get(
      url3,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200 &&
        response2.statusCode == 200 &&
        response3.statusCode == 200) {
      var equityList = response2.data["equity"];
      var equityListLite = response2.data["equity_detail"];
      var cashList = response.data["cash"];
      var cashListLite = response.data["cash_detail"];
      var seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var invSum = response3.data["investment_sum"];

      Navigator.pop(context);
      //Navigator.pop(context);
      timer.cancel();
      navigateWithSlideTransition(
        context: context,
        destinationScreen: Equitydetails(equityList, equityListLite),
        transitionDuration: const Duration(milliseconds: 200),
      );
    }
    timer.cancel();
  }
}
