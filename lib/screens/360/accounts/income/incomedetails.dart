import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../components/addAccountBtn.dart';
import '../../threesixty.dart';
import 'package:GapHub/provider/providers.dart';
import 'incomeitem.dart';
import 'incarchives.dart';

class Incomedetails extends StatefulWidget {
  final List incomeData;
  final Map incomeDataLite;

  const Incomedetails(this.incomeData, this.incomeDataLite, {super.key});

  @override
  _IncomedetailsState createState() => _IncomedetailsState();
}

class _IncomedetailsState extends State<Incomedetails> {
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String currency1 = context.watch<Providers>().snapshotmodel.currency;
    Widget popUpMenu() => PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text('View Archived Accounts')),
      ],
      icon: const Icon(Icons.list),
      onSelected: (value) async {
        dialogBox.waiting(context, "Opening");
        var url = "$baseUrl/app/360/income?archive=all";
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
            MaterialPageRoute(builder: (context) => Incarchives(response.data)),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List incomeData = widget.incomeData;
    Map incomeDataLite = widget.incomeDataLite;

    //print("incomeDataLite:$incomeDataLite");
    String currency(int index, List list) {
      if (list.isNotEmpty) {
        String currency = list[index]["currency"].toString();
        return currency;
      } else {
        return "";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Income',
          style: TextStyle(fontSize: width * .06, fontWeight: FontWeight.w700),
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
                "Income: $currency1${incomeDataLite["sum"] == null ? 0 : incomeDataLite["sum"].toStringAsFixed(2)}"
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: TextStyle(
                  fontSize: width * .05,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: height * .03),
            Center(
              child: Text(
                "List of Income Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .045,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Visibility(
              visible: incomeData.isEmpty,
              child: SizedBox(
                height: height * .08,
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                      "No Income Account added yet",
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
            incomeData.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: incomeData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                      child: Card(
                        color: const Color(0xFF989898),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Incomeitem(data: incomeData[index]),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: height * 0.07,
                                  color: Color(int.parse(colors[index])),
                                ),
                              ),
                              Expanded(
                                flex: 40,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.03,
                                  ),
                                  height: height * 0.07,
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
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      incomeData[index]['income_type'] ==
                                                          'non_portfolio'
                                                      ? 'Non Portfolio - '
                                                      : incomeData[index]['income_type'] ==
                                                            'portfolio'
                                                      ? 'Portfolio - '
                                                      : 'Unknown',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w900,
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
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/chevron_right.png',
                                          height: width * 0.05,
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
            incomeData.isEmpty ||
                    (incomeDataLite["values"] == null ||
                        incomeDataLite["values"].length == 1 &&
                            incomeDataLite["values"][0] == 0)
                ? Container()
                : Column(
                    children: [
                      SizedBox(
                        height: height * .05,
                        child: const Divider(thickness: 2),
                      ),
                      Center(
                        child: Text(
                          "Income Distribution",
                          style: TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: width * .06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        colors: colors,
                        labels: incomeDataLite["labels"],
                        values: incomeDataLite["values"],
                        percent: incomeDataLite["percentages"],
                      ),
                    ],
                  ),
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            const ClockWidget(11),
            SizedBox(height: height * .05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .2),
              child: Addaccountbtn(width: width, index: "Income"),
            ),
            SizedBox(height: height * .05),
          ],
        ),
      ),
    );
  }
}
