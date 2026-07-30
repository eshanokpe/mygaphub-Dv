import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'liabilityitem.dart';
import 'package:dio/dio.dart';

class Liarchives extends StatefulWidget {
  final Map data;
  final bool archived;

  const Liarchives(this.data, {super.key, this.archived = false});

  @override
  _LiarchivesState createState() => _LiarchivesState();
}

class _LiarchivesState extends State<Liarchives> {
  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List liabilityData = widget.data["liabilities"];
    List bespokes = widget.data["bespokes"];
    String currency(int index, List list) {
      if (list.isNotEmpty) {
        String currency = list[index]["currency"].toString();
        return currency;
      } else {
        return "";
      }
      // String currency = s.substring(0, s.indexOf(" "));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archived Liabilities',
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
                "List of Archived Liabilities Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: height * .01),
            Visibility(
              visible: liabilityData.isEmpty && bespokes.isEmpty,
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
            liabilityData.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: liabilityData.length,
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
                                builder: (context) => Liabilityitem(
                                  item: liabilityData[index],
                                  seven: false,
                                  bespokes: false,
                                  archived: true,
                                ),
                              ),
                            );
                          },
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${liabilityData[index]["creditor_name"]} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${liabilityData[index]['account_type']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${currency(index, liabilityData)}${liabilityData[index]["current"]}"
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
            bespokes.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: bespokes.length,
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
                                builder: (context) => Liabilityitem(
                                  item: bespokes[index],
                                  seven: false,
                                  bespokes: true,
                                  archived: true,
                                ),
                              ),
                            );
                          },
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${bespokes[index]["creditor_name"]} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: "${bespokes[index]['account_type']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${currency(index, bespokes)}${bespokes[index]["current"]}"
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
