import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import './retirementdetails.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

class Retarchives extends StatefulWidget {
  final Map data;

  const Retarchives(this.data, {super.key});
  @override
  _RetarchivesState createState() => _RetarchivesState();
}

class _RetarchivesState extends State<Retarchives> {
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

    final List retirementData = widget.data["retirement"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: 'Financial Independence (Not '),
              TextSpan(
                text: 'Retirement',
                style: TextStyle(
                  //  decoration: TextDecoration.lineThrough,
                  color: Colors.red,
                ),
              ),
              TextSpan(text: ')'),
            ],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: width * .04,
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: height * .01),
            Center(
              child: Text(
                "List of Archived Pension Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            retirementData.isEmpty
                ? SizedBox(
                    height: height * .08,
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: Text(
                          "No Pension Account archived yet",
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
                    itemCount: retirementData.length,
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
                                builder: (context) => Retirementdetails(
                                  archived: true,
                                  data: retirementData[index],
                                ),
                              ),
                            );
                          },
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${retirementData[index]['name']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${retirementData[index]['pension_type']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "$currency1${retirementData[index]['monthly_contribution']}"
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
