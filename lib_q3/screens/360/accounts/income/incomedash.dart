import 'dart:async';
import 'package:GapHub/screens/360/accounts/income/incomedetails.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/screens/portfolio/charts/dashmaps.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'charts/channels.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'charts/linegraph.dart';
import 'charts/incometab.dart';
import 'package:GapHub/models/IncomeChannels.dart';
import 'package:GapHub/models/IncomeChartModel.dart';

import 'income.dart';

class Incomedash extends StatefulWidget {
  final List incomeData;
  final Map incomeDataLite;
  final num allocated;
  final List incomes;
  final Map<String, dynamic> channels;

  const Incomedash(
    this.incomeData,
    this.incomeDataLite,
    this.allocated, {
    required this.incomes,
    required this.channels,
    super.key,
  });

  @override
  _IncomedashState createState() => _IncomedashState();
}

class _IncomedashState extends State<Incomedash> {
  late Map channelsValues;
  late Map channelsPercent;
  late IncomeChartModel incomeChart;

  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();

  @override
  void initState() {
    super.initState();
    channelsValues = widget.channels["values"];
    channelsPercent = widget.channels["percentages"];
    print('channelsValues:$channelsValues');

    setState(() {
      incomeChart =
          context.read<Providers>().incomeChart ??
          IncomeChartModel(hasImprove: false);
    });
    print('incomeChart:${incomeChart.hasImprove}');
  }

  @override
  Widget build(BuildContext context) {
    var incomeData = widget.incomeData;
    var incomeDataLite = widget.incomeDataLite;
    // Check if incomeDataLite is null or empty before using it
    if (incomeDataLite.isEmpty) {
      // Return a widget indicating that income data is not available
      return const Center(
        child: Text(
          'Income data is not available',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    // var incomeDataLite = widgeincomeDataLite;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String currency(int index, List list) {
      if (list.isNotEmpty) {
        return list[index]["currency"].toString();
      }
      return "";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Income Universe in 360',
          style: TextStyle(fontSize: width * .040, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: height * .02),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .04),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * .04,
                          vertical: height * .01,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * .02),
                          gradient: const LinearGradient(
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xff671012), Color(0xffed3237)],
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${context.watch<Providers>().snapshotmodel.currency}${incomeDataLite["sum"].toStringAsFixed(2)}'
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xfff3f3f4),
                                fontSize: width * .08,
                              ),
                            ),
                            SizedBox(height: height * .01),
                            Text(
                              "Average Total Income",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xfff3f3f4),
                                fontSize: width * .065,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    incomeChart.hasImprove!
                                        ? Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.green[700],
                                            size: 45,
                                          )
                                        : const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.red,
                                            size: 45,
                                          ),
                                    const Text(
                                      "vs last month",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * .03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .04),
                      child: Linechart(model: incomeChart),
                    ),
                    SizedBox(height: height * .02),
                    Dashmaps(),
                    SizedBox(height: height * .03),

                    Channels(
                      channelsPercent: IncomeChannelsPercent.fromJson(
                        Map<String, dynamic>.from(channelsPercent),
                      ),
                      channelsValues: IncomeChannelsValues.fromJson(
                        Map<String, dynamic>.from(channelsValues),
                      ),
                    ),
                    SizedBox(height: height * .04),
                    Incometab(widget.incomes),
                    SizedBox(height: height * .04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .04),
                      child: Material(
                        child: Container(
                          width: double.infinity,
                          height: height * .07,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(width * .04),
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Incomedetails(
                                      incomeData,
                                      incomeDataLite,
                                    ),
                                  ),
                                );
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/viewDoc.png",
                                      scale: 5,
                                    ),
                                    Text(
                                      "View Income List",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xfff3f3f4),
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
                    ),
                    SizedBox(height: height * .02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .04),
                      child: Material(
                        child: Container(
                          height: height * .07,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * .04),
                            gradient: const LinearGradient(
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xff671012), Color(0xffed3237)],
                            ),
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed('Income');
                                /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Decider("Income"))); */
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: height * .05,
                                  ),
                                  SizedBox(width: width * .01),
                                  Text(
                                    "Add Income to track it here",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xfff3f3f4),
                                      fontSize: width * .045,
                                    ),
                                  ),
                                ],
                              ),
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
          Visibility(
            visible: widget.allocated == 0,
            child: Container(
              height: height,
              width: width,
              color: Colors.black.withOpacity(.8),
            ),
          ),
          Visibility(
            visible: widget.allocated == 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: height * .02),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Portfolio Allocation: ${context.watch<Providers>().snapshotmodel.currency}${incomeDataLite["sum"].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: width * .05,
                      ),
                    ),
                    Text(
                      "(Confirm you have allocated your Portfolio Income)",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: width * .035,
                      ),
                    ),
                    Hspace(height * .01),
                    SizedBox(
                      height: height * incomeData.length / 11,
                      child: ListView.builder(
                        itemCount: incomeData.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * .02,
                          ),
                          child: Card(
                            elevation: 3,
                            color: const Color(0xff989898),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * .03,
                              ),
                              height: height * .07,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${incomeData[index]["income_name"]} - ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "${currency(index, incomeData)}${incomeData[index]["amount"]}"
                                                  .replaceAllMapped(
                                                    RegExp(
                                                      r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                    ),
                                                    (Match m) => '${m[1]},',
                                                  ),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        dialogBox.waiting(context, "Saving");

                        var timer = Timer(const Duration(seconds: 50), () {
                          Navigator.pop(context);
                          dialogBox.information(
                            context,
                            'Status',
                            'Service timed out',
                          );
                          return;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');
                        var url =
                            "$baseUrl/app/360/income?crd=ajkmzxjkcnkfsnznnjksxnjnkcnjc&alo=azsjkhbdjcbjszbhjbxjhcbjbhhbjghdx";
                        var response = await dio.get(
                          url,
                          options: Options(
                            headers: {"Authorization": 'Bearer $token'},
                          ),
                        );

                        if (response.statusCode == 200) {
                          Navigator.pop(context);

                          timer.cancel();
                          getData();
                          Fluttertoast.showToast(
                            msg: "Income has been submitted successfully",
                          );
                          // income();
                        } else {
                          Navigator.pop(context);
                          timer.cancel();
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * .04,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  income() async {
    dialogBox.waiting(context, "Loading");

    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    try {
      var url = "$baseUrl/app/360/income";

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var response = await dio.get(
        url,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print("Response data: ${response.data}");
        List assets = response.data["portfolio_asset"];
        List incomeData = response.data["incomes"];

        num currentPortfolio =
            response.data["income_info"]["current_portfolio"];
        print("Current portfolio: $currentPortfolio");
        context.read<Providers>().setCurrentPortfolio(currentPortfolio);

        List<num> amounts = [];
        for (var i = 0; i < incomeData.length; i++) {
          num amount = incomeData[i]["amount"];
          print("Income amount [$i]: $amount");
          amounts.add(amount);
        }
        num total = 0;
        for (var i = 0; i < amounts.length; i++) {
          total += amounts[i];
        }
        num allocated = response.data["income_audit"] != null
            ? response.data["income_audit"]["income_allocated"]
            : 1;
        print("Allocated: $allocated");

        var incomeDataLite = response.data["income_detail"];
        List<String> listofassets = ['-Select-'];

        for (var i = 0; i < assets.length; i++) {
          if (assets[i]["isArchive"] != 1) {
            listofassets.add(
              "${assets[i]["name"]} (${assets[i]["asset_currency"]}${assets[i]["monthly_roi"].toStringAsFixed(2)})"
                  .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
            );
          }
        }
        context.read<Providers>().setAssets(listofassets);
        context.read<Providers>().setPortfolioDiff(
          response.data["income_info"]["portfolio_diff"],
        );
        context.read<Providers>().setMapAsset(assets);
        Navigator.pop(context);

        timer.cancel();
        if (response.data["income_info"]["portfolio_diff"] > 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Income()),
          );
        } else {
          var incomes = response.data["incomes"] ?? [];
          var channels = response.data["income_channels"] ?? {};
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Incomedash(
                incomeData,
                incomeDataLite,
                allocated,
                incomes: incomes,
                channels: channels,
              ),
            ),
          );
        }
      } else {
        Navigator.pop(context);
        timer.cancel();
      }
    } catch (e) {
      print('exception:$e');
      Fluttertoast.showToast(msg: 'An error occurred $e');
    }
  }

  getData() async {
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var urlr = "$baseUrl/app/360/tiles";
    var urlInc = "$baseUrl/app/360/income";

    var responseInc = await dio.get(
      urlInc,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (responseInc.statusCode == 200) {
      List assets = responseInc.data["portfolio_asset"];

      List<String> listofassets = ['-Select-'];

      for (var i = 0; i < assets.length; i++) {
        if (assets[i]["isArchive"] != 1) {
          listofassets.add(
            "${assets[i]["name"]} (${assets[i]["asset_currency"]}${assets[i]["monthly_roi"].toStringAsFixed(2)})"
                .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
          );
        }
      }

      List incomeData = responseInc.data["incomes"];
      int currentPortfolio = int.parse(
        responseInc.data["income_info"]["current_portfolio"].round().toString(),
      );

      List<int> amounts = [];
      for (var i = 0; i < incomeData.length; i++) {
        amounts.add(incomeData[i]["amount"].round());
      }
      int total = 0;
      for (var i = 0; i < amounts.length; i++) {
        total = total + amounts[i];
      }

      context.read<Providers>().setAssets(listofassets);
      context.read<Providers>().setMapAsset(assets);
      num incomeInfo = responseInc.data["income_info"]["portfolio_diff"];
      print('dat2:$incomeInfo');
      context.read<Providers>().setPortfolioDiff(incomeInfo.toDouble());
      print('dat:${responseInc.statusCode}');

      if (responseInc.statusCode == 200) {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        Map titles = response.data['titles'];
        print("360:$titles");

        context.read<Providers>().setRecent(response.data["tiles"]);
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Threesixty(),
            maintainState: true,
          ),
        );
      } else {
        timer.cancel();
        Fluttertoast.showToast(msg: "Something went wrong");
      }
    } else {
      timer.cancel();
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }
}
