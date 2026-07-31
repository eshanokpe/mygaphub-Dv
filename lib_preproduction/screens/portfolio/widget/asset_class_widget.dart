import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../braidetails.dart';
import 'asset_rowWithTap.dart';

class AssetCardWidget extends StatefulWidget {
  const AssetCardWidget({super.key});

  @override
  _AssetCardWidgetState createState() => _AssetCardWidgetState();
}

class _AssetCardWidgetState extends State<AssetCardWidget> {
  Map data1 = {};
  Map data2 = {};
  Map data = {};
  String c = '';

  @override
  void initState() {
    super.initState();

    data = context.read<Providers>().portfolio;
    data1 = data['data']["existing_report"];
    data2 = data['data']["desired_report"];
  }

  @override
  Widget build(BuildContext context) {
    c = context.watch<Providers>().snapshotmodel.currency;
    double totExistVal = 0;
    double totExistInc = 0;
    double totDesiredVal = 0;
    double totDesiredInc = 0;

    for (var i = 0; i < data1["values"].length; i++) {
      totExistVal += data1["values"][i];
    }
    for (var i = 0; i < data1["incomes"].length; i++) {
      totExistInc += data1["incomes"][i];
    }
    for (var i = 0; i < data2["values"].length; i++) {
      totDesiredVal += data2["values"][i];
    }
    for (var i = 0; i < data2["incomes"].length; i++) {
      totDesiredInc += data2["incomes"][i];
    }

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.0), // Asset Class - 40% width
                1: FlexColumnWidth(1.5), // Value - 30% width
                2: FlexColumnWidth(1.5), // Income - 30% width
              },
              border: TableBorder.all(
                color: Colors.white,
                width: .3,
                borderRadius: BorderRadius.circular(12.0),
              ),
              children: [
                // Header Row
                TableRow(
                  children: [
                    Tabledata2(
                      text: 'Asset Class',
                      thick: false,
                      boxColor: 0xfffafafa,
                      onPressed: () => _showBottomSheet(context),
                    ),
                    Tabledata2(
                      text: 'Value',
                      thick: true,
                      onPressed: () => _showBottomSheet(context),
                    ),
                    Tabledata2(
                      text: 'Income',
                      thick: true,
                      onPressed: () => _showBottomSheet(context),
                    ),
                  ],
                ),
                // Business Row
                TableRow(
                  children: [
                    _buildAssetClassCell(
                      context: context,
                      firstLetter: 'B',
                      remainingText: 'usiness',
                      onTap: () => getData("Business", "business", context),
                    ),
                    Tabledata3(
                      text: '$c${data1["values"][0].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: false,
                    ),
                    Tabledata3(
                      text: '$c${data1["incomes"][0].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: false,
                    ),
                  ],
                ),
                // Appreciating Row
                TableRow(
                  children: [
                    _buildAssetClassCell(
                      context: context,
                      firstLetter: 'A',
                      remainingText: 'ppreciating',
                      onTap: () =>
                          getData("Appreciating", "appreciating", context),
                    ),
                    Tabledata3(
                      text: '$c${data1["values"][2].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: false,
                    ),
                    Tabledata3(
                      text: '$c${data1["incomes"][2].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: false,
                    ),
                  ],
                ),
                // Risk Row
                TableRow(
                  children: [
                    _buildAssetClassCell(
                      context: context,
                      firstLetter: 'R',
                      remainingText: 'isk',
                      onTap: () => getData("Risk", "risk", context),
                    ),
                    Tabledata3(
                      text: '$c${data1["values"][1].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: false,
                    ),
                    Tabledata3(
                      text: '$c${data1["incomes"][1].toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: false,
                    ),
                  ],
                ),
                // Total Row
                TableRow(
                  children: [
                    const Tabledata3(
                      text: 'TOTAL',
                      thick: true,
                      boxColor: 0xfffafafa,
                    ),
                    Tabledata3(
                      text: '$c${totExistVal.toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: true,
                    ),
                    Tabledata3(
                      text: '$c${totExistInc.toStringAsFixed(2)}'
                          .replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          ),
                      thick: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: height * .03),
        ],
      ),
    );
  }

  Widget _buildAssetClassCell({
    required BuildContext context,
    required String firstLetter,
    required String remainingText,
    required VoidCallback onTap,
  }) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: const Color(0xfffafafa),
        padding: const EdgeInsets.all(5.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: firstLetter,
                style: TextStyle(
                  fontSize: width * .04,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: remainingText,
                style: TextStyle(
                  fontSize: width * .04,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

class Tabledata2 extends StatelessWidget {
  const Tabledata2({
    super.key,
    required this.text,
    required this.thick,
    required this.onPressed,
    this.boxColor = 0xffffffff,
  });

  final String text;
  final bool thick;
  final int boxColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      color: Color(boxColor),
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: width * .04,
            color: const Color(0xff808080),
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w300,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

class Tabledata3 extends StatelessWidget {
  const Tabledata3({
    super.key,
    required this.text,
    required this.thick,
    this.onPressed,
    this.backgroundColor,
    this.boxColor = 0xffffffff,
  });

  final String text;
  final bool thick;
  final int boxColor;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Container(
      color: Color(boxColor),
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: width * .04,
          fontFamily: 'Nunito',
          fontWeight: thick ? FontWeight.w600 : FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.start,
      ),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      Orientation orientation = MediaQuery.of(context).orientation;
      final height = orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.width;
      final width = orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.height;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Divider(
                  color: const Color(0xffcdcdcd),
                  height: height * .02,
                  thickness: 5,
                  indent: width * .38,
                  endIndent: width * .38,
                ),
              ),
              SizedBox(height: height * .02),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Pick your preferred asset",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * .05,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AssetRowWithTap(
                imagePath: 'assets/images/business_icon.png',
                title: 'Business Asset',
                subtitleParts: const [
                  {'text': 'B', 'color': Colors.black, 'underline': true},
                  {'text': 'AR', 'color': Colors.black54},
                ],
                trailing: false,
                percentage: '0%',
                changeValue: '-0.0',
                changeColor: const Color(0xffCE0001),
                onTap: () {
                  getData("Business", "business", context);
                },
              ),
              SizedBox(height: height * 0.01),
              const Divider(indent: 60.0, thickness: 1.0),
              SizedBox(height: height * 0.01),
              AssetRowWithTap(
                imagePath: 'assets/images/appreciating_asset.png',
                title: 'Appreciating Asset',
                subtitleParts: const [
                  {'text': 'B', 'color': Colors.black54},
                  {'text': 'A', 'color': Colors.black, 'underline': true},
                  {'text': 'R', 'color': Colors.black54},
                ],
                trailing: false,
                percentage: '0%',
                changeValue: '-0.0',
                changeColor: const Color(0xffce009933),
                onTap: () {
                  getData("Appreciating", "appreciating", context);
                },
              ),
              SizedBox(height: height * 0.01),
              const Divider(indent: 60.0, thickness: 1.0),
              SizedBox(height: height * 0.01),
              AssetRowWithTap(
                imagePath: 'assets/images/risk_asset.png',
                title: 'Risk Asset',
                subtitleParts: const [
                  {'text': 'B', 'color': Colors.black54},
                  {'text': 'A', 'color': Colors.black54},
                  {'text': 'R', 'color': Colors.black, 'underline': true},
                ],
                trailing: false,
                percentage: '0%',
                changeValue: '-0.0',
                changeColor: const Color(0xffCE0001),
                onTap: () {
                  getData("Risk", "risk", context);
                },
              ),
              SizedBox(height: height * 0.03),
              CustomButton(
                text: 'Close',
                fontSize: 16,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: height * 0.09),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> getData(String cap, String small, BuildContext context) async {
  final timeoutTimer = Timer(const Duration(seconds: 40), () {
    EasyLoading.dismiss();
    Fluttertoast.showToast(msg: "Request timed out. Please try again.");
  });

  EasyLoading.show(status: 'Loading', dismissOnTap: false);

  try {
    var url = Uri.parse("$baseUrl/app/portfolio/$small");
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
              Braidetails(cap, jsonDecode(response.body), false),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Error: ${response.statusCode}. Something went wrong.",
      );
    }
  } catch (error) {
    Fluttertoast.showToast(msg: "An error occurred: ${error.toString()}");
  } finally {
    timeoutTimer.cancel();
    EasyLoading.dismiss();
  }
}
