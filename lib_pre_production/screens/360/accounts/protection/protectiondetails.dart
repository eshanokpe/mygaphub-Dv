import 'package:GapHub/screens/360/accounts/protection/protectionitem.dart';
import 'package:GapHub/screens/360/components/addAccountBtn.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/clock_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'procarchives.dart';
import 'package:GapHub/utils/dialog.dart';

class Protectiondetails extends StatefulWidget {
  const Protectiondetails({super.key});
  @override
  _ProtectiondetailsState createState() => _ProtectiondetailsState();
}

class _ProtectiondetailsState extends State<Protectiondetails> {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  List? protectionDatas;
  Map? protectionDataLites;
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
  void didChangeDependencies() {
    setState(() => protectionDatas = context.watch<Providers>().protectionList);
    setState(
      () => protectionDataLites = context.watch<Providers>().protectionListLite,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget popUpMenu() => PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text('View Archived Accounts')),
      ],
      icon: const Icon(Icons.list),
      onSelected: (value) async {
        dialogBox.waiting(context, "Opening");
        var url = "$baseUrl/app/360/protection?archive=all";
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
              builder: (context) => Procarchives(response.data),
            ),
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

    var protectionData = protectionDatas;
    var protectionDataLite = protectionDataLites;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Protection',
          style: TextStyle(fontSize: width * .045, fontWeight: FontWeight.w700),
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
                "Sum Assured: $currency${protectionDataLite!["sum"].toStringAsFixed(2)}"
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
                    "Sum assured is the amount your family gets in case if you pass away. Other categories of insurances are also available. ",
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
                "Insurance Policies and Premiums",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .06,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            protectionData!.isEmpty
                ? SizedBox(
                    height: height * .08,
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: Text(
                          "No Protection Account added yet",
                          style: TextStyle(
                            fontSize: width * .05,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: protectionData.length,
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
                                    Protectionitem(item: protectionData[index]),
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
                                                      "${protectionData[index]['protection_category']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "$currency${protectionData[index]['premium_pay']}"
                                                      .replaceAllMapped(
                                                        RegExp(
                                                          r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                        ),
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
            Visibility(
              visible: protectionData.isNotEmpty,
              child: SizedBox(
                height: height * .05,
                child: const Divider(thickness: 2),
              ),
            ),
            protectionData.isEmpty ||
                    (protectionDataLite["values"].length == 1 &&
                        protectionDataLite["values"][0] == 0)
                ? Container()
                : Column(
                    children: [
                      Center(
                        child: Text(
                          "Insurance Premium Distribution",
                          style: TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: width * .06,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        labels: protectionDataLite["labels"],
                        values: (protectionDataLite["values"] as List)
                            .map(
                              (value) =>
                                  double.tryParse(value.toString()) ?? 0.0,
                            )
                            .toList(),
                        percent: (protectionDataLite["percentages"] as List)
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
            const ClockWidget(4),
            SizedBox(height: height * .05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .2),
              child: Addaccountbtn(width: width, index: "Protection"),
            ),
            SizedBox(height: height * .05),
            // Text(protectionData[0].toString())
          ],
        ),
      ),
    );
  }
}
