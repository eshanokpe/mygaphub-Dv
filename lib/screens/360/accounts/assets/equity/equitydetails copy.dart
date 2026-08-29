import 'package:GapHub/screens/360/accounts/assets/equity/equityitem.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/addAccountBtn.dart';
import '../../../threesixty.dart';
import '../../../../../widgets/clock_widget.dart';
import '../../../../../widgets/piechart.dart';
import 'equarchives.dart';

class Equitydetails extends StatefulWidget {
  final List equityData;
  final Map equityDataLite;
  const Equitydetails(this.equityData, this.equityDataLite, {super.key});
  @override
  _EquitydetailsState createState() => _EquitydetailsState();
}

class _EquitydetailsState extends State<Equitydetails> {
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
  Dio dio = Dio();

  DialogBox dialogBox = DialogBox();

  @override
  Widget build(BuildContext context) {
    Widget popUpMenu() => PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text('View Archived Accounts')),
      ],
      icon: const Icon(Icons.list),
      onSelected: (value) async {
        dialogBox.waiting(context, "Opening");
        var url = "$baseUrl/app/360/equity?archive=all";
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
            MaterialPageRoute(builder: (context) => Equarchives(response.data)),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    var equityData = widget.equityData;
    var equityDataLite = widget.equityDataLite;
    final sum = equityDataLite["sum"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Equity',
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
                "Home Equity: $currency${sum.toStringAsFixed(2)}"
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
                    "Here is an aggregation of the values you have in your homes owned by you",
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
                "List of Homes & their Equity",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            equityData.isEmpty
                ? SizedBox(
                    height: height * .1,
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: Text(
                          "No Equity account added yet",
                          style: TextStyle(
                            fontSize: width * .06,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: equityData.length,
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
                                builder: (context) =>
                                    Equityitem(item: equityData[index]),
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
                                                      "${equityDataLite['labels'][index]} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${equityData[index]['equity_type'] ?? ""} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "$currency${equityDataLite['values'][index]}"
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
            SizedBox(height: height * .05, child: const Divider(thickness: 2)),
            equityData.isNotEmpty
                ? Column(
                    children: [
                      Center(
                        child: Text(
                          "Equity Distribution",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: width * .06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        colors: colors,
                        labels: widget.equityDataLite['labels'],
                        values: widget.equityDataLite['values'],
                        percent: widget.equityDataLite["percentages"],
                        // onTap: ggg(),
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
