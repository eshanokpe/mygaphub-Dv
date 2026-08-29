import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import '../../components/addAccountBtn.dart';
import '../../threesixty.dart';
import 'cashitem.dart';
import 'package:GapHub/utils/dialog.dart';
import '../../../../widgets/piechart.dart';
import 'casharchives.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:GapHub/utils/constants.dart';

class Cashdetails extends StatefulWidget {
  final List cashData;
  final Map cashDataLite;
  final List seveng;
  final List bespokes;

  const Cashdetails(
    this.cashData,
    this.cashDataLite,
    this.seveng,
    this.bespokes, {
    super.key,
  });
  @override
  _CashdetailsState createState() => _CashdetailsState();
}

class _CashdetailsState extends State<Cashdetails> {
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
    "0XFFFF5733",
    "0XFFFFC300",
    "0XFFDAF7A6",
    "0XFF2471A3",
    "0XFF581845",
    "0XFF148F77",
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
        var url = "$baseUrl/app/360/cash?archive=all";
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
              builder: (context) => Casharchives(response.data),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
    var cashData = widget.cashData;
    var cashDataLite = widget.cashDataLite;
    var seveng = widget.seveng;
    var bespokes = widget.bespokes;
    String currency(int index, List list) {
      if (list.isNotEmpty) {
        String currency = list[index]["currency"].toString();
        return splitit(currency);
      }
      return '';
    }

    String currenc = context.watch<Providers>().currency;
    String currency1 = splitit(currenc);
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
          'Cash',
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [popUpMenu()],
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: height * .01),
            Center(
              child: Text(
                "Cash: $currency1${cashDataLite["sum"].toStringAsFixed(2)}"
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
                    "Here is an aggregation of all your cash account used for various purposes",
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
                "List of Cash Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Visibility(
              visible: seveng.isEmpty && cashData.isEmpty && bespokes.isEmpty,
              child: SizedBox(
                height: height * .08,
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                      "No Cash Account added yet",
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
              itemCount: seveng.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .02),
                child: Card(
                  color: const Color(0xff989898),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      print("seveng:${seveng[index]}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cashitem(
                            item: seveng[index],
                            seven: true,
                            bespokes: false,
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
                            color: Color(int.parse(colors[index])),
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
                                                "${seveng[index]['account_name']} - ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: width * .04,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                "${seveng[index]['account_purpose']} - ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: width * .04,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "$currency1${seveng[index]['current'] == null ? '0' : seveng[index]['current'].toString()}"
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
              ),
            ),
            bespokes.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: bespokes.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .02),
                      child: Card(
                        color: const Color(0xff989898),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Cashitem(
                                  item: bespokes[index],
                                  seven: true,
                                  bespokes: true,
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
                                  color: Color(
                                    int.parse(colors[index + seveng.length]),
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
                                                      "${bespokes[index]['kpi_name']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${bespokes[index]['account_purpose']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${currency(index, bespokes)}${bespokes[index]['current']}"
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
            cashData.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: cashData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .02),
                      child: Card(
                        color: const Color(0xff989898),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Cashitem(
                                  item: cashData[index],
                                  seven: false,
                                  bespokes: false,
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
                                  color: Color(
                                    int.parse(
                                      colors[index +
                                          bespokes.length +
                                          seveng.length],
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
                                                      "${cashData[index]['account_name']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${cashData[index]['account_purpose']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${currency(index, cashData)}${cashData[index]['current']}"
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
            widget.cashData.isEmpty &&
                        widget.seveng.isEmpty &&
                        widget.bespokes.isEmpty ||
                    (widget.cashDataLite["values"].length == 1 &&
                        widget.cashDataLite["values"][0] == 0)
                ? Container()
                : Column(
                    children: [
                      SizedBox(
                        height: height * .05,
                        child: const Divider(thickness: 2),
                      ),
                      Center(
                        child: Text(
                          "Cash Distribution",
                          style: TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: width * .06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        labels: widget.cashDataLite["labels"],
                        values: (widget.cashDataLite["values"] as List)
                            .map(
                              (value) =>
                                  double.tryParse(value.toString()) ?? 0.0,
                            )
                            .toList(),
                        percent: (widget.cashDataLite["percentages"] as List)
                            .map(
                              (percent) =>
                                  double.tryParse(percent.toString()) ?? 0.0,
                            )
                            .toList(),
                        colors: colors,
                      ),
                    ],
                  ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            const ClockWidget(7),
            SizedBox(height: height * .02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .2),
              child: const Addaccountbtn(index: "Cash"),
            ),
            SizedBox(height: height * .05),
          ],
        ),
      ),
    );
  }
}
