import 'package:GapHub/screens/360/accounts/mortgage/mortgageitem.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';

class Mortarchives extends StatefulWidget {
  final Map data;
  const Mortarchives(this.data, {super.key});
  @override
  _MortarchivesState createState() => _MortarchivesState();
}

class _MortarchivesState extends State<Mortarchives> {
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
    String currency1 = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List mortgageData = widget.data["mortgages"];
    List seveng = widget.data["seveng"];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archived Mortgage',
          style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w700),
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
                "List of Archived Mortgage Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: seveng.length,
              itemBuilder: (context, index) => seveng[index]['isArchive'] == 0
                  ? const SizedBox()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .02),
                      child: Card(
                        color: const Color(0xff989898),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => Mortgageitem(
                            //             item: mortgageData[index],
                            //             archived: true,
                            //             seven: false)));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mortgageitem(
                                  item: seveng[index],
                                  archived: true,
                                  seven: false,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
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
                                                      "${seveng[index]['creditor_name']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "${seveng[index]['secured_against']} - ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: width * .04,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${splitit(seveng[index]["account_currency"])}${seveng[index]['current']}"
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
            mortgageData.isEmpty
                ? SizedBox(
                    height: height * .08,
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: Text(
                          "No Mortgage Account archived yet",
                          style: TextStyle(
                            fontSize: width * .05,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: mortgageData.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * .02),
                      child: Card(
                        elevation: 3,
                        color: const Color(0xff989898),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mortgageitem(
                                  item: mortgageData[index],
                                  archived: true,
                                  seven: false,
                                ),
                              ),
                            );
                          },
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${mortgageData[index]['creditor_name']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${mortgageData[index]['secured_against']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "$currency1${mortgageData[index]['current_balance']}"
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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
