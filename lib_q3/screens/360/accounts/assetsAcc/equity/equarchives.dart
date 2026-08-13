import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'equityitem.dart';

class Equarchives extends StatefulWidget {
  final Map data;
  const Equarchives(this.data, {super.key});
  @override
  _EquarchivesState createState() => _EquarchivesState();
}

class _EquarchivesState extends State<Equarchives> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String currency = context.watch<Providers>().snapshotmodel.currency;
    List equityData = widget.data["equity"];
    Map equityDataLite = widget.data["equity_detail"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archived Home Equity',
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
                "List of Archived Equity Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Visibility(
              visible: equityData.isEmpty,
              child: SizedBox(
                height: height * .08,
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                      "No Liabilities Account Archived yet",
                      style: TextStyle(
                        fontSize: width * .05,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            equityData.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: equityData.length,
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
                                builder: (context) => Equityitem(
                                  item: equityData[index],
                                  archived: true,
                                ),
                              ),
                            );
                          },
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${equityDataLite["labels"][index]} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "$currency${equityData[index]["market_value"]}"
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
