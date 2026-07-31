import 'package:GapHub/screens/360/accounts/protection/protectionItem/protectionitem.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/dialog.dart';

class Procarchives extends StatefulWidget {
  final Map data;
  const Procarchives(this.data, {super.key});
  @override
  _ProcarchivesState createState() => _ProcarchivesState();
}

class _ProcarchivesState extends State<Procarchives> {
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
    String currency1 = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List protectionData = widget.data["protection"];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archived Protection',
          style: TextStyle(fontSize: width * .045, fontWeight: FontWeight.w700),
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
                "Archived Insurance Policies and Premiums",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .045,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            protectionData.isEmpty
                ? SizedBox(
                    height: height * .08,
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Center(
                        child: Text(
                          "No Protection Account archived yet",
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
                        elevation: 3,
                        color: const Color(0xff989898),
                        child: ListTile(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => Protectionitem(
                            //       archived: true,
                            //       item: protectionData[index],
                            //     ),
                            //   ),
                            // );
                          },
                          title: RichText(
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
                                  text:
                                      "$currency1${protectionData[index]['premium_pay']}"
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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
