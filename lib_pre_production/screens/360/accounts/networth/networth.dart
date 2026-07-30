import 'dart:async';

import 'package:GapHub/screens/360/accounts/assetsAcc/assetdetails.dart';
import 'package:GapHub/screens/360/accounts/liabilities/liabilitydetails.dart';
import 'package:GapHub/screens/360/accounts/mortgage/mortgagedetails.dart';
import 'package:GapHub/screens/360/accounts/networth/networthdetails.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Networth extends StatefulWidget {
  final Map item;

  const Networth(this.item, {super.key});
  @override
  _NetworthState createState() => _NetworthState();
}

class _NetworthState extends State<Networth> {
  bool show = false;
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    // var assetValue = 0;
    double assetSum = double.parse(widget.item["net"]["asset"].toString());
    var mortSum = widget.item["net"]["mortgage"];
    var liaSum = widget.item["net"]["liability"];
    var equitySum =
        double.parse(widget.item["net"]["home"].toString()) -
        double.parse(widget.item["net"]["mortgage"].toString());
    var homeSum = widget.item["net"]["home"];

    double networth = 0;
    show == true
        ? networth = equitySum + assetSum - liaSum
        : networth = assetSum - liaSum;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Net Worths",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: height * .02,
            horizontal: width * .02,
          ),
          child: Column(
            children: [
              Text(
                "(Complete the form below to set your preference)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your current Asset Value:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Text(
                    "$currency ${assetSum.toStringAsFixed(2)}".replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * .03),
                  InkWell(
                    onTap: () {
                      assets();
                    },
                    child: Text(
                      "Go to Assets to edit",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        decoration: TextDecoration.underline,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Current Liabilities Value:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Text(
                    "$currency $liaSum".replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * .03),
                  InkWell(
                    onTap: () {
                      liability();
                    },
                    child: Text(
                      "Go to Liabilities to edit",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        decoration: TextDecoration.underline,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Current Home Value: ',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Text(
                    "$currency $homeSum".replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * .03),
                  InkWell(
                    onTap: () {
                      assets();
                    },
                    child: Text(
                      "Go to Assets to edit",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        decoration: TextDecoration.underline,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Current Mortgage Value:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Text(
                    "$currency$mortSum".replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * .03),
                  InkWell(
                    onTap: () {
                      mortgage();
                    },
                    child: Text(
                      "Go to Mortgage to edit",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Current Home Equity:  ',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Text(
                    "$currency$equitySum".replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add Home Equity to your Net Worth:',
                      style: TextStyle(
                        fontSize: width * .045,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch(
                    activeThumbColor: Theme.of(context).primaryColor,
                    value: show,
                    onChanged: (val) {
                      setState(() {
                        show = val;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: height * .03,
                child: const Divider(thickness: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Current Net Worth:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Row(
                children: [
                  Text(
                    "$currency${networth.toStringAsFixed(2)}".replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: TextStyle(
                      color: assetSum - liaSum < 0 && !show
                          ? Theme.of(context).primaryColor
                          : Colors.green,
                      fontSize: width * .045,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * .05,
                child: const Divider(thickness: 1.5),
              ),
              Text(
                "Are the figures above a true representation of your net worth? If yes, confirm below",
                style: TextStyle(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: height * .05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .01),
                  ),
                ),
                onPressed: () async {
                  dialogBox.waiting(context, "Loading");
                  var url = "$baseUrl/app/360/net";
                  final prefs = await SharedPreferences.getInstance();
                  var token = prefs.getString('tokenDB');
                  var response = await dio.post(
                    url,
                    data: 1,
                    options: Options(
                      headers: {"Authorization": 'Bearer $token'},
                    ),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Networthdetails(
                          item: widget.item,
                          currency: currency,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: width * .045,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  assets() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    var url = "$baseUrl/app/360/cash";
    var url2 = "$baseUrl/app/360/equity";
    var url3 = "$baseUrl/app/360/investment";

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

    if (response.statusCode == 200 && response2.statusCode == 200) {
      var equityList = response2.data["equity"];
      var equityListLite = response2.data["equity_detail"];
      var cashList = response.data["cash"];
      var cashListLite = response.data["cash_detail"];
      var seveng = response.data["seveng"];
      var bespokes = response.data["bespokes"];
      var invSum = response3.data["investment_sum"];
      print("invSum:$invSum");
      timer.cancel();
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
          ),
        ),
      );
    }
  }

  mortgage() async {
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/mortgage";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      var mapList = response.data["mortgages"];
      var seveng = response.data["seveng"];
      var mapListLite = response.data["mortgages_detail"];
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mortgagedetails(mapList, mapListLite, seveng),
        ),
      );
    }
  }

  liability() async {
    if (!mounted) return;
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
      var mapList = response.data["liabilities"];
      var seveng = response.data["seveng"];
      var mapListLite = response.data["liabilities_detail"];
      var isAllocated = response.data["audit"]["is_allocated"];
      var bespokes = response.data["bespokes"];
      var creditCurrent = "0";
      var info = jsonDecode(response2.body);
      Analyticsinfo analyticsinfo = Analyticsinfo.fromJson(info["data"]);
      creditCurrent = analyticsinfo.credit!["current"].toString();
      num total = 0;
      List real = [];
      if (seveng.isNotEmpty) {
        var a = seveng.map((e) => e["current"].round()).toList();

        for (var item in a) {
          real.add(int.parse(item.toString()));
        }

        for (var item in a) {
          total = total + item;
        }
      }
      if (mounted) Navigator.pop(context);

      if (isAllocated.toString() == "1") {
        if (mounted) {
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
      } else if (int.parse(creditCurrent.toString()) == 0) {
        if (mounted) {
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
      } else if (total != int.parse(creditCurrent.toString())) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Threesixty(
                unallocated: true,
                data: seveng,
                balance: seveng.isEmpty
                    ? int.parse(creditCurrent)
                    : (int.parse(creditCurrent) - total).toInt(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
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
        }
      }
    }
  }
}
