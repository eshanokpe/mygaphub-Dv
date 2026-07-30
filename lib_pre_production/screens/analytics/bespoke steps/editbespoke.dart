import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/screens/analytics/bespoke%20steps/bespokedetails.dart';

class Editbespoke extends StatefulWidget {
  final List bespokes;
  final List bespokes2;
  final int total;

  const Editbespoke({
    super.key,
    required this.bespokes,
    required this.bespokes2,
    required this.total,
  });
  @override
  _EditbespokeState createState() => _EditbespokeState();
}

class _EditbespokeState extends State<Editbespoke> {
  @override
  Widget build(BuildContext context) {
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
          'Bespoke KPI',
          style: TextStyle(
            fontSize: width * .035,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      bottomNavigationBar: const BottomNav(1),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: height * .01),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .02),
              child: Card(
                elevation: 3,
                color: const Color(0xffF3F3F3),
                child: ListTile(
                  title: Text(
                    'Key Performance Indicator Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: widget.total,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: width * .02),
                child: Card(
                  color: const Color(0xffF3F3F3),
                  elevation: 3,
                  child: ListTile(
                    onTap: () {
                      // final newUser = color == 0xff494949;
                      var e = widget.bespokes.where(
                        (element) =>
                            element["kpi_name"] ==
                            widget.bespokes2[index]["name"],
                      );
                      var e2 = widget.bespokes2.where(
                        (element) =>
                            element["name"] == widget.bespokes2[index]["name"],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Bespokedetails(e.toList(), e2.toList()),
                        ),
                      );
                    },
                    trailing: Image.asset(
                      'assets/images/chevron_right.png',
                      height: height * .04,
                      width: width * .04,
                    ),
                    title: Text(
                      widget.bespokes2[index]["name"],
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .05),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .03),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.zero,
                  height: height * .05,
                  width: width * .3,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'View Chart',
                      style: TextStyle(
                        color: const Color(0xfff3f3f4),
                        fontWeight: FontWeight.w900,
                        fontSize: width * .04,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * .05),
          ],
        ),
      ),
    );
  }
}
