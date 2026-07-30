import 'dart:async';
import 'dart:convert';

import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/assetdetails.dart';
import 'package:GapHub/screens/360/accounts/retirement/retiredash.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import '../../components/addAccountBtn.dart';
import '../liabilities/liabilitydetails.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/equity/equitydetails.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:GapHub/models/chartsmodel.dart';

// ignore: must_be_immutable
class Networthdetails extends StatefulWidget {
  final String currency;
  final Map item;
  var equity;

  Networthdetails({
    super.key,
    required this.currency,
    required this.item,
    this.equity,
  });

  @override
  _NetworthdetailsState createState() => _NetworthdetailsState();
}

class _NetworthdetailsState extends State<Networthdetails> {
  final List<charts.Series<Kpi, String>> _seriesData = [];

  addData(Map item, String currency) {
    _seriesData.add(
      charts.Series(
        data: [
          Kpi(
            kpi: const Text("Assets"),
            value: double.parse(item["net_detail"]["values"][0].toString()),
            gradientColors: [const Color(0xff01F201), const Color(0xff01F201)],
          ),
          Kpi(
            kpi: const Text("Liabilities"),
            value: double.parse(item["net_detail"]["values"][1].toString()),
            gradientColors: [const Color(0xffFF0100), const Color(0xffFF0100)],
          ),
          Kpi(
            kpi: const Text("Pensions"),
            value: double.parse(item["net_detail"]["values"][2].toString()),
            gradientColors: [const Color(0xff0000ff), const Color(0xff0000ff)],
          ),
          Kpi(
            kpi: const Text("Home Equity"),
            value: double.parse(item["net_detail"]["values"][3].toString()),
            gradientColors: [const Color(0xffe5e5e5), const Color(0xffe5e5e5)],
          ),

          // Kpi(kpi: '', value: 100, colorVal: 0xfffffff)
        ],
        domainFn: (Kpi kpi, _) => kpi.kpi.data!,
        // domainFn: (Kpi kpi, int a) => kpi.kpi.data,
        measureFn: (Kpi kpi, _) => kpi.value,
        colorFn: (Kpi kpi, _) =>
            charts.ColorUtil.fromDartColor(kpi.gradientColors.first),
        // outsideLabelStyleAccessorFn: (Kpi kpi, _) =>
        //     charts.TextStyleSpec(color: charts.MaterialPalette.red.shadeDefault),
        // fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: 'Expenditure',
        domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Kpi kpi, _) =>
            '$currency${(kpi.value).toInt()}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
      ),
    );
  }

  bool show2 = false;
  final _controller = ValueNotifier<bool>(false);
  Dio dio = Dio();
  bool _checked = true;
  String? totalnet;
  DialogBox dialogBox = DialogBox();
  @override
  void initState() {
    super.initState();
    addData(widget.item, widget.currency);
  }

  @override
  Widget build(BuildContext context) {
    var values = widget.item["net_detail"]["values"];
    int pension = values[2];
    int homeEquiry = values[3];
    bool addequity = true;
    _controller.addListener(() {
      setState(() {
        if (_controller.value) {
          _checked = true;
          // print('recurr:$_checked');
        } else {
          _checked = false;
          //print('recurr:$_checked');
        }
        if (_checked == true) {
          addequity = true;
          totalnet = (widget.equity + widget.item["net_detail"]["sum"])
              .toStringAsFixed(2);
          print('recurr: 1');
        } else {
          addequity = false;
          totalnet = (0 + widget.item["net_detail"]["sum"]).toStringAsFixed(2);
          print('recurr: 0');
        }
      });
    });

    print(addequity);
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Net Worth ',
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: width * .01),
            Center(
              child: Text(
                "Net Worth: $currency${totalnet ?? widget.item["net_detail"]["sum"]}"
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: TextStyle(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: height * .01),
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
                    "Here is the difference between what you own and what you owe financially.",
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
            SizedBox(height: height * .02),
            Center(
              child: Text(
                "Assets vs Liabilities",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                elevation: 3,
                color: const Color(0xff989898),
                child: ListTile(
                  onTap: () => goToAssetsDetails(),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Current Asset Value: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text:
                              "$currency${widget.item["net_detail"]["values"][0].toStringAsFixed(2)}"
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                elevation: 3,
                color: const Color(0xff989898),
                child: ListTile(
                  onTap: () => liability(),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Current Liability Value: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text:
                              "$currency${widget.item["net_detail"]["values"][1].toStringAsFixed(2)}"
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                elevation: 3,
                color: const Color(0xff989898),
                child: ListTile(
                  onTap: () => retirement(),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Current Pensions:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "$currency${pension.toStringAsFixed(2)}"
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                elevation: 3,
                color: const Color(0xff989898),
                child: ListTile(
                  onTap: equity,
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Current Home Equity: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text:
                              //"$currency${home_equiry.toStringAsFixed(2)}"
                              "$currency${widget.item["net_detail"]["values"][3].toStringAsFixed(2)}"
                                  .replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .03),
              child: SizedBox(
                height: height * .08,
                child: Card(
                  elevation: 3,
                  color: const Color(0xff989898),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Home Equity: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        AdvancedSwitch(
                          inactiveColor: Colors.white,
                          activeChild: const Text('On'),
                          inactiveChild: const Text('Off'),
                          width: 70.0,
                          height: 30.0,
                          controller: _controller,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            Center(
              child: Text(
                "Net Worth Distribution",
                style: TextStyle(
                  // decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Container(
              height: height * .4,
              padding: const EdgeInsets.all(8),
              child: charts.BarChart(
                _seriesData,
                animate: true,
                vertical: true,
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                animationDuration: const Duration(milliseconds: 1000),
              ),
            ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            const ClockWidget(1),
            Padding(
              padding: EdgeInsets.all(width * .2),
              child: Addaccountbtn(width: width, index: ""),
            ),
          ],
        ),
      ),
    );
  }

  equity() async {
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/equity";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      var mapList = response.data["equity"];
      var mapListLite = response.data["equity_detail"];
      Navigator.pop(context);
      // Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Equitydetails(mapList, mapListLite),
        ),
      );
    }
  }

  retirement() async {
    var timer = Timer(const Duration(milliseconds: 40000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/retirement/roi";
    var url2 = "$baseUrl/app/360/retirement";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    context.read<Providers>().setretiredata(response.data);
    context.read<Providers>().setpensions(response2.data);
    if (response.statusCode == 200 && response2.statusCode == 200) {
      Navigator.pop(context);
      timer.cancel();
      //Navigator.of(context).pushNamed('Retiredash');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Retiredash(response.data, response2.data),
        ),
      );
    }
    timer.cancel();
  }

  Future<void> goToAssetsDetails() async {
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";
    var url2 = "$baseUrl/app/360/equity";
    var url3 = "$baseUrl/app/360/investment";
    var url4 = "$baseUrl/app/360/retirement";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
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
    var response4 = await dio.get(
      url4,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200 &&
        response2.statusCode == 200 &&
        response3.statusCode == 200 &&
        response4.statusCode == 200) {
      var equityList = response2.data["equity"];
      var equityListLite = response2.data["equity_detail"];
      var cashList = response.data["cash"];
      var cashListLite = response.data["cash_detail"];
      var seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var invSum = response3.data["investment_sum"];
      var pensions = response4.data["retirement_detail"];

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Assetdetails(
            cashData: cashList,
            cashDataLite: cashListLite,
            seveng: seveng,
            equityData: equityList,
            equityDataLite: equityListLite,
            bespokes: bespokes,
            invSum: invSum,
            pensions: pensions,
          ),
        ),
      );
    }
  }

  liability() async {
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url2 = Uri.parse('$baseUrl/app/seveng/edit');
    var url = "$baseUrl/app/360/liability";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await http.get(
      url2,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200 && response2.statusCode == 200) {
      List mapList = response.data["liabilities"];
      // print("mapList:$mapList");
      var mapListLite = response.data["liabilities_detail"];
      List seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var isAllocated = response.data["audit"]["is_allocated"];
      var creditCurrent = "0";
      int creditCurrentInt = int.tryParse(creditCurrent) ?? 0;
      var cc = jsonDecode(response2.body);
      Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(cc["data"]);
      creditCurrent = analyticsinfo.credit!["current"].toString();
      num total = 0;
      List real = [];
      if (seveng.isNotEmpty) {
        List<num> a = seveng
            .map((e) => num.parse(e["current"].toString()))
            .toList();

        for (var item in a) {
          real.add(int.parse(item.toString()));
        }
        for (var item in a) {
          total = total + item;
        }
      }
      Navigator.pop(context);
      timer.cancel();

      if (isAllocated.toString() == "1") {
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (int.parse(creditCurrent.toString()) == 0) {
        timer.cancel();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (total != int.parse(creditCurrent.toString())) {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Threesixty(
              unallocated: true,
              data: seveng,
              balance: seveng.isEmpty
                  ? creditCurrentInt
                  : (creditCurrentInt - total).toInt(),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        // print("mapList:$mapList");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      }
    }
    timer.cancel();
  }
}
