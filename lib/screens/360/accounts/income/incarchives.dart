import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'incomeitem.dart';

class Incarchives extends StatelessWidget {
  final Map data;
  const Incarchives(this.data, {super.key});
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String currency(int index, List list) {
      if (list.isNotEmpty) {
        String currency = list[index]["currency"].toString();
        return currency;
      } else {
        return "";
      }
    }

    List incomeData = data["incomes"];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Archived Income',
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
                "List of Archived Income Accounts",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: width * .05,
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
                      "No Income Account Archived yet",
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
            incomeData.isEmpty
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: incomeData.length,
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
                                builder: (context) => Incomeitem(
                                  data: incomeData[index],
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
                                      "${incomeData[index]["income_name"]} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: "${incomeData[index]['channel']} - ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * .04,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "${currency(index, incomeData)}${incomeData[index]["amount"]}"
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
