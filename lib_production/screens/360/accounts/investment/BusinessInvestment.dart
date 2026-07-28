import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/portfolio/braiditem.dart';
import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'package:http/http.dart' as http;

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class BusinessInvestment extends StatefulWidget {
  final Map data;
  final String type;
  const BusinessInvestment(this.data, this.type, {super.key});
  @override
  _BusinessInvestmentState createState() => _BusinessInvestmentState();
}

class _BusinessInvestmentState extends State<BusinessInvestment> {
  List existing = [];
  List desired = [];
  var currency = "";
  List<TableRow> existingTabs = [];
  List<TableRow> desiredTabs = [];
  @override
  void initState() {
    super.initState();
    existing = widget.data["existing"];
    desired = widget.data["desired"];
    for (var i = 0; i < existing.length; i++) {
      if (existing.isNotEmpty) {
        var parts = existing[i]["asset_currency"].toString().split(" ");
        currency = parts[0];
      }
      existingTabs.add(
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: [
            InkWell(
              onTap: () {
                getData(existing[i]["id"].toString());
              },
              child: Tabledata(text: '${existing[i]["name"]}', thick: false),
            ),
            Tabledata(
              thick: false,
              text: '$currency${existing[i]["asset_value"]}'.replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              ),
            ),
            Tabledata(
              thick: false,
              text: '$currency${existing[i]["monthly_roi"]}'.replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              ),
            ),
          ],
        ),
      );
    }
    for (var i = 0; i < desired.length; i++) {
      desiredTabs.add(
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: [
            InkWell(
              onTap: () {
                getData(desired[i]["id"].toString());
              },
              child: Tabledata(text: '${desired[i]["name"]}', thick: false),
            ),
            Tabledata(
              thick: false,
              text:
                  '${desired[i]["asset_currency"]}${desired[i]["asset_value"]}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
            ),
            Tabledata(
              thick: false,
              text:
                  '${desired[i]["asset_currency"]}${desired[i]["monthly_roi"]}'
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
            ),
          ],
        ),
      );
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Archived ${widget.type} Asset",
          style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(3),
      body: ListView(
        children: [
          SizedBox(height: height * .05),
          Center(
            child: Text(
              "Existing Assets",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: width * .05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: height * .01),
          existing.isEmpty
              ? Container(
                  color: Colors.grey[200],
                  height: height * .1,
                  child: Center(
                    child: Text(
                      "No Existing Assets Added Yet",
                      style: TextStyle(
                        fontSize: width * .05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: width * .01),
                      child: Table(
                        border: TableBorder.all(color: Colors.black, width: .3),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: const [
                              Tabledata(text: "Asset Name", thick: true),
                              Tabledata(text: "Current Value", thick: true),
                              Tabledata(text: "Average Income", thick: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: width * .01),
                      child: Table(
                        border: TableBorder.all(color: Colors.black, width: .3),
                        children: existingTabs,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: height * .05),
        ],
      ),
    );
  }

  getData(String id) async {
    var type = widget.type.toLowerCase();
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
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
              Braiditem(data: jsonDecode(response.body), archived: true),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }
}
