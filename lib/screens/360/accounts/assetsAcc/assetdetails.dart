import 'dart:async';
import 'package:GapHub/screens/360/accounts/cash/cashdetails.dart';
import 'package:GapHub/screens/360/accounts/investment/investdash.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/retiredash.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/addAccountBtn.dart';
import '../../threesixty.dart';
import 'equity/equitydetails.dart';

class Assetdetails extends StatefulWidget {
  final List cashData;
  final Map cashDataLite;
  final List equityData;
  final Map equityDataLite;
  final List seveng;
  final List bespokes;
  final Map? pensions;
  final invSum;
  final Map<String, dynamic>? braidTable;

  const Assetdetails({
    super.key,
    required this.cashData,
    required this.cashDataLite,
    required this.seveng,
    this.pensions,
    required this.equityData,
    required this.equityDataLite,
    required this.invSum,
    required this.bespokes,
    required this.braidTable,
  });
  @override
  _AssetdetailsState createState() => _AssetdetailsState();
}

class _AssetdetailsState extends State<Assetdetails> {
  num total = 0;
  Dio dio = Dio();
  final _pensioncontroller = ValueNotifier<bool>(false);
  final _equitycontroller = ValueNotifier<bool>(false);
  List<String> colors = [
    "0XFF581845",
    "0XFFFF5733",
    "0XFFFFC300",
    "0XFFDAF7A6",
    "0XFF2471A3",
    "0XFF148F77",
    "0XFF7D6608",
    "0XFF17202A",
    "0XFFF9EBEA",
    '0xffED3237',
    '0xff494949',
    '0xff000000',
  ];
  @override
  void initState() {
    super.initState();
    var cashDataLite = widget.cashDataLite;

    total = widget.invSum + cashDataLite["sum"] + 0;
  }

  // final invSum;
  // _AssetdetailsState(this.invSum);

  @override
  Widget build(BuildContext context) {
    var equityDataLite = widget.equityDataLite;
    var cashDataLite = widget.cashDataLite;
    var pensiondata = widget.pensions?['sum'] ?? 0.0;
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    bool checked = true;
    bool checked22 = true;
    if (_pensioncontroller.value && _equitycontroller.value) {
      String stringValue = widget.pensions!['sum'].toString();
      num penValue;
      if (stringValue.contains('.') || stringValue.contains('e')) {
        // If the string contains a dot (.) or 'e', treat it as a double
        penValue = double.parse(stringValue);
      } else {
        // Otherwise, treat it as an int
        penValue = int.parse(stringValue);
      }
      var cashvalue = cashDataLite['sum'];
      setState(() {
        total = widget.invSum + cashvalue + penValue + equityDataLite['sum'];
      });
    } else if (_pensioncontroller.value) {
      String stringValue = widget.pensions!['sum'].toString();
      num penValue;
      if (stringValue.contains('.') || stringValue.contains('e')) {
        // If the string contains a dot (.) or 'e', treat it as a double
        penValue = double.parse(stringValue);
      } else {
        // Otherwise, treat it as an int
        penValue = int.parse(stringValue);
      }
      var cashvalue = cashDataLite['sum'];
      //int value = 9500;
      setState(() {
        total = widget.invSum + cashvalue + penValue;
      });
    } else if (_equitycontroller.value) {
      var cashvalue = cashDataLite['sum'];
      setState(() {
        total = widget.invSum + cashvalue + equityDataLite['sum'];
      });
    } else {
      var cashvalue = cashDataLite['sum'];
      setState(() {
        total = widget.invSum + cashvalue;
      });
    }
    _equitycontroller.addListener(() {
      setState(() {
        if (_equitycontroller.value) {
          checked22 = true;
        } else {
          checked22 = false;
        }
        if (checked22 == true) {
          var cashvalue = cashDataLite['sum'].toDouble();
          setState(() {
            total = widget.invSum + cashvalue + equityDataLite['sum'];
          });

          print('recurr: 1');
        } else {
          setState(() {
            total = widget.invSum + cashDataLite["sum"] + 0;
          });
        }
      });
    });

    _pensioncontroller.addListener(() {
      setState(() {
        if (_pensioncontroller.value) {
          checked = true;
          // print('recurr:$_checked');
        } else {
          checked = false;
          //print('recurr:$_checked');
        }
        if (checked == true) {
          String stringValue = widget.pensions!['sum'].toString();
          num penValue;
          if (stringValue.contains('.') || stringValue.contains('e')) {
            // If the string contains a dot (.) or 'e', treat it as a double
            penValue = double.parse(stringValue);
          } else {
            // Otherwise, treat it as an int
            penValue = int.parse(stringValue);
          }
          var cashvalue = cashDataLite['sum'];
          //int value = 9500;
          setState(() {
            total = widget.invSum + cashvalue + penValue;
          });
          print('recurr: 1');
        } else {
          setState(() {
            total = widget.invSum + cashDataLite["sum"] + 0;
          });
          print('recurr: 0');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assets',
          style: TextStyle(fontSize: width * .04, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: height * .01),
            Center(
              child: Text(
                "Assets: $currency${total.toStringAsFixed(2)}".replaceAllMapped(
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
                    "This includes all your investments, Cash and Home Equity",
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
                "Components of your Asset",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .02,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Current Asset",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: width * .05,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                color: const Color(0xff989898),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Investdash(
                          sums: widget.invSum,
                          braidTable: widget.braidTable,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: height * .07,
                          color: Color(int.parse(colors[0])),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Investments - ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Portfolio - ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "$currency${widget.invSum.toStringAsFixed(2)}"
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                color: const Color(0xff989898),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    // Navigator.of(context).pushNamed('Cashdetails');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cashdetails(
                          widget.cashData,
                          widget.cashDataLite,
                          widget.seveng,
                          widget.bespokes,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: height * .07,
                          color: Color(int.parse(colors[1])),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Cash - ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "360° & Portfolio - ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * .04,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "$currency${cashDataLite['sum'].toStringAsFixed(2)}"
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * .02,
                vertical: height * .02,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Non-Current Asset",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: width * .05,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                color: const Color(0xff989898),
                elevation: 3,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        var timer = Timer(const Duration(seconds: 40), () {
                          Navigator.pop(context);
                          dialogBox.information(
                            context,
                            'Status',
                            'Service timed out',
                          );
                          return;
                        });
                        dialogBox.waiting(context, "Loading");

                        var url = "$baseUrl/app/360/retirement/roi";
                        var url2 = "$baseUrl/app/360/retirement";

                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');

                        var response = await dio.get(
                          url,
                          options: Options(
                            headers: {"Authorization": 'Bearer $token'},
                          ),
                        );
                        var response2 = await dio.get(
                          url2,
                          options: Options(
                            headers: {"Authorization": 'Bearer $token'},
                          ),
                        );
                        context.read<Providers>().setretiredata(response.data);
                        context.read<Providers>().setpensions(response2.data);
                        if (response.statusCode == 200 &&
                            response2.statusCode == 200) {
                          Navigator.pop(context);

                          timer.cancel();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Retiredash(),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                        timer.cancel();
                      },
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: height * .07,
                              color: const Color(0xffDAF7A6),
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
                                              text: "Pension - ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "360° - ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "$currency${pensiondata.toStringAsFixed(2)}"
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
                    AdvancedSwitch(
                      inactiveColor: Colors.white,
                      activeChild: const Text('On'),
                      inactiveChild: const Text('Off'),
                      width: 70.0,
                      height: 30.0,
                      controller: _pensioncontroller,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                color: const Color(0xff989898),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Equitydetails(
                          widget.equityData,
                          widget.equityDataLite,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: height * .07,
                          color: Color(int.parse(colors[2])),
                        ),
                      ),
                      Expanded(
                        flex: 40,
                        child: Column(
                          children: [
                            Container(
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
                                              text: "Home Equity - ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "360° - ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: width * .04,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "$currency${equityDataLite['sum'].toStringAsFixed(2)}"
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
                            AdvancedSwitch(
                              inactiveColor: Colors.white,
                              activeChild: const Text('On'),
                              inactiveChild: const Text('Off'),
                              width: 70.0,
                              height: 30.0,
                              controller: _equitycontroller,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            widget.cashData.isNotEmpty
                ? Column(
                    children: [
                      Center(
                        child: Text(
                          "Asset Distribution",
                          style: TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: width * .06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        colors: colors,
                        labels: const ["Investment", "Cash", "Home Equity"],
                        values: [
                          widget.invSum,
                          widget.cashDataLite["sum"],
                          widget.equityDataLite["sum"],
                        ],
                        percent: [
                          (widget.invSum / total * 100).round(),
                          (widget.cashDataLite["sum"] / total * 100).round(),
                          (widget.equityDataLite["sum"] / total * 100).round(),
                        ],
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            const ClockWidget(12),
            SizedBox(height: height * .02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .2),
              child: const Addaccountbtn(index: "Assets"),
            ),
            SizedBox(height: height * .05),
          ],
        ),
      ),
    );
  }
}
