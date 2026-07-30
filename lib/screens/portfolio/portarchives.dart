import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'braiditem.dart';
import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'package:http/http.dart' as http;

import 'widget/archived_asset_card.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Portarchives extends StatefulWidget {
  final Map data;
  final String type;
  const Portarchives(this.data, this.type, {super.key});
  @override
  _PortarchivesState createState() => _PortarchivesState();
}

class _PortarchivesState extends State<Portarchives> {
  List existing = [];
  List desired = [];
  var currency = "";
  List<TableRow> existingTabs = [];
  List<TableRow> desiredTabs = [];
  @override
  void initState() {
    super.initState();
    print("type:${widget.type}");
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
                getData(existing[i]["id"].toString(), widget.type);
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
                getData(desired[i]["id"].toString(), widget.type);
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
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Archived ${widget.type} Asset",
          style: TextStyle(
            fontSize: width * .04,
            color: AppColors.grayColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(3),
      body: existing.isEmpty
          ? Container(
              color: AppColors.cardColor,
              height: height * .1,
              padding: EdgeInsets.symmetric(vertical: height * .02),
              margin: EdgeInsets.symmetric(horizontal: width * .04),
              child: Center(
                child: Text(
                  "Nothing to see here!",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: width * .04,
                  ),
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .04,
                vertical: height * .02,
              ),
              child: ListView.builder(
                itemCount: existing.length,
                itemBuilder: (context, i) {
                  var parts = existing[i]["asset_currency"].toString().split(
                    " ",
                  );
                  var currency = parts[0];
                  var assetValue = existing[i]["asset_value"];
                  var monthlyROI = existing[i]["monthly_roi"];
                  var createdAt = existing[i]["created_at"];
                  var photo = existing[i]["photo_url"];

                  return InkWell(
                    onTap: () {
                      getData(existing[i]["id"].toString(), widget.type);
                    },
                    child: Card(
                      elevation: 0,
                      color: AppColors.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: Color(0xffD8D8D8),
                          width: 0.8,
                        ),
                      ),
                      child: ArchivedAssetCard(
                        photo: photo,
                        name: existing[i]["name"],
                        assetValue: "$currency$assetValue",
                        monthlyROI: "$currency$monthlyROI",
                        createdAt: "$createdAt",
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  getData(String id, String type) async {
    var type = widget.type.toLowerCase();
    Timer timer = Timer(const Duration(seconds: 40), () {
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
          builder: (context) => Braiditem(
            data: jsonDecode(response.body),
            archived: true,
            type: widget.type,
            id: id,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }
}
