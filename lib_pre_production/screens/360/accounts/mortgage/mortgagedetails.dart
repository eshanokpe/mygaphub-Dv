import 'dart:convert';

import 'package:GapHub/screens/360/accounts/mortgage/mortgageitem.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/dialog.dart';
import 'mortarchives.dart';
import 'package:http/http.dart' as http;

import 'mortgage.dart';

class Mortgagedetails extends StatefulWidget {
  final List mortgageData;
  final Map mortgageDataLite;
  final List seveng;

  const Mortgagedetails(
    this.mortgageData,
    this.mortgageDataLite,
    this.seveng, {
    super.key,
  });
  @override
  _MortgagedetailsState createState() => _MortgagedetailsState();
}

class _MortgagedetailsState extends State<Mortgagedetails> {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  List<String> colors = [
    "0XFF581845",
    "0XFFFF5733",
    "0XFFFFC300",
    "0XFFDAF7A6",
    "0XFF2471A3",
    "0XFF148F77",
    "0XFF7D6608",
    "0XFF17202A",
    "0XFFFFC300",
    '0xffED3237',
    '0xff494949',
    '0xff000000',
  ];

  @override
  Widget build(BuildContext context) {
    Widget popUpMenu() => PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text('View Archived Accounts')),
      ],
      icon: const Icon(Icons.list),
      onSelected: (value) async {
        dialogBox.waiting(context, "Opening");
        var url = "$baseUrl/app/360/mortgage?archive=1";
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        var response = await dio.get(
          url,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Mortarchives(response.data),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
    // var mortgageData = widget.mortgageData;
    // var mortgageDataLite = widget.mortgageDataLite;
    // var seveng = widget.seveng;
    String currency1 = context.watch<Providers>().snapshotmodel.currency;
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
          'Mortgage',
          style: TextStyle(fontSize: width * .04, fontWeight: FontWeight.w700),
        ),
        actions: [popUpMenu()],
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: height * .01),
            Center(
              child: Text(
                "Mortgages: $currency1${widget.mortgageDataLite["sum"].toStringAsFixed(2)}"
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: TextStyle(
                  fontSize: width * .06,
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
                    "Here is an aggregation of all your debt that are secured against properties.",
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
            SizedBox(height: height * .03),
            Center(
              child: Text(
                "List of Mortgage Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Visibility(
              visible: widget.seveng.isEmpty && widget.mortgageData.isEmpty,
              child: SizedBox(
                height: height * .08,
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                      "No Liability Account added yet",
                      style: TextStyle(
                        fontSize: width * .055,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: widget.seveng.length,
              itemBuilder: (context, index) {
                if (widget.seveng[index]['isArchive'] == 1) {
                  return const SizedBox();
                }

                final item = widget.seveng[index];
                final creditorName = item['creditor_name'] ?? 'Debt';
                final securedAgainst = item['secured_against'] ?? '';
                final accountCurrency = item['account_currency'] ?? '';
                final currentAmount = item['current'] ?? 0;
                final isZeroBalance = currentAmount == 0;

                // Format the amount with commas
                final formattedAmount = currentAmount
                    .toString()
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    );

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * .02),
                  child: Card(
                    color: const Color(0xff989898),
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        if (isZeroBalance) {
                          dialogBox.information(
                            context,
                            "Attention",
                            "Please archive this account in order to be able to create a new one",
                            no: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Mortgageitem(
                                    item: item,
                                    seven: true,
                                    zeroBalance: isZeroBalance,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Mortgageitem(
                                item: item,
                                seven: false,
                                zeroBalance: isZeroBalance,
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: height * .07,
                              color: Color(
                                int.parse(colors[index % colors.length]),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 40,
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
                                              text: '$creditorName - ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            if (securedAgainst
                                                .toString()
                                                .isNotEmpty)
                                              TextSpan(
                                                text: '$securedAgainst - ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: width * .04,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            TextSpan(
                                              text:
                                                  '${splitit(accountCurrency)}$formattedAmount',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/chevron_right.png',
                                      height: width * .035,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            widget.mortgageData.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: widget.mortgageData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .02),
                      child: Card(
                        color: const Color(0xff989898),
                        elevation: 3,
                        child: InkWell(
                          onTap: () async {
                            var zeroBalance =
                                widget.mortgageData[index]['current_balance'] ==
                                    0
                                ? true
                                : false;
                            if (zeroBalance) {
                              dialogBox.information(
                                context,
                                "Attention",
                                "Please archive this account in order to be able to create a new one",
                                no: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Mortgageitem(
                                        item: widget.mortgageData[index],
                                        seven: false,
                                        zeroBalance: zeroBalance,
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Mortgageitem(
                                    item: widget.mortgageData[index],
                                    seven: false,
                                    zeroBalance: zeroBalance,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: height * .07,
                                  color: Color(
                                    int.parse(
                                      colors[index + widget.seveng.length],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 40,
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
                                                      "${widget.mortgageData[index]['creditor_name']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${widget.mortgageData[index]['secured_against']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "$currency1${widget.mortgageData[index]['current_balance']}"
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
                                        Image.asset(
                                          'assets/images/chevron_right.png',
                                          height: width * .05,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            widget.mortgageData.isEmpty && widget.seveng.isEmpty ||
                    (widget.mortgageDataLite["values"].length == 1 &&
                        widget.mortgageDataLite["values"][0] == 0)
                ? Container()
                : Column(
                    children: [
                      SizedBox(
                        height: height * .05,
                        child: const Divider(thickness: 2),
                      ),
                      Center(
                        child: Text(
                          "Mortgage Distribution",
                          style: TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: width * .06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        labels: widget.mortgageDataLite["labels"],
                        values: (widget.mortgageDataLite["values"] as List)
                            .map(
                              (value) =>
                                  double.tryParse(value.toString()) ?? 0.0,
                            )
                            .toList(),
                        percent:
                            (widget.mortgageDataLite["percentages"] as List)
                                .map(
                                  (percent) =>
                                      double.tryParse(percent.toString()) ??
                                      0.0,
                                )
                                .toList(),
                        colors: colors,
                      ),
                    ],
                  ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            const ClockWidget(8),
            Padding(
              padding: EdgeInsets.all(width * .2),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .01),
                  ),
                ),
                onPressed: () async {
                  EasyLoading.show(status: 'Loading', dismissOnTap: false);

                  var url = Uri.parse("$baseUrl/app/360/equity/info");
                  final prefs = await SharedPreferences.getInstance();
                  var token = prefs.getString('tokenDB');

                  var response = await http.get(
                    url,
                    headers: {"Authorization": 'Bearer $token'},
                  );

                  if (response.statusCode == 200) {
                    bool primaryRes = false;
                    Map<String, dynamic>? mortgageInfo = {};
                    bool mortgageloading = true;
                    EasyLoading.dismiss();
                    var res = jsonDecode(response.body);
                    setState(() => primaryRes = res['primary_exist']);

                    setState(() {
                      mortgageInfo = res['secured_against'] ?? {};
                      mortgageloading = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Mortgage(
                          primaryRes: primaryRes,
                          mortgageInfo: mortgageInfo!,
                        ),
                      ),
                    );
                  } else {
                    EasyLoading.dismiss();
                    switch (response.statusCode) {
                      case 400:
                        Fluttertoast.showToast(
                          msg: "Error: bad request",
                          backgroundColor: Colors.red,
                        );
                        break;
                      case 401:
                        Fluttertoast.showToast(
                          msg: "Error: Unauthorised, please login again",
                          backgroundColor: Colors.red,
                        );
                        break;
                      case 422:
                        Fluttertoast.showToast(
                          msg: "Error: 422, please try again later",
                          backgroundColor: Colors.red,
                        );
                        break;
                      case 500:
                        Fluttertoast.showToast(
                          msg: "Error: Server Error",
                          backgroundColor: Colors.red,
                        );
                        break;
                    }
                  }
                },
                child: Text(
                  "Add Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: width * .040,
                  ),
                ),
              ),
            ),
            /*  Padding(
            padding: EdgeInsets.all(width * .2),
            child: Addaccountbtn(
              width: width,
              index: "Mortgage",
            ),
          ), */
          ],
        ),
      ),
    );
  }
}
