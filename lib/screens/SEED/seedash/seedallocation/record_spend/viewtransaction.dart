import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'transaction_summary.dart';

class ViewTransactionSummary extends StatefulWidget {
  var body;
  ViewTransactionSummary({super.key, this.body});

  @override
  State<ViewTransactionSummary> createState() => _ViewTransactionSummaryState();
}

class _ViewTransactionSummaryState extends State<ViewTransactionSummary> {
  final df = DateFormat("dd, EEEEE, yyyy");
  String formattedDate = '2022-08-29';
  var recordData;
  List<dynamic> list = [];
  var spent_current_month;
  var spent_last_month;
  var balance;
  var keys;
  var backgrounds;
  var colors;
  var cdate1;
  var strings = <String>[];

  @override
  void initState() {
    super.initState();
    //setState(() => recordDatalist = context.read<Providers>().recorddata);
    // balance = recordDatalist['summary']['total_left'];
  }

  @override
  Widget build(BuildContext context) {
    cdate1 = DateFormat("dd, EEEEE, yyyy").format(DateTime.now());
    // print(cdate1);
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenWidth = MediaQuery.of(context).size.width;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List<dynamic> data = widget.body['record_spents'];
    var datas = widget.body['record_spents'];
    balance = widget.body['summary']['total_spent'];
    backgrounds = widget.body["backgrounds"];
    print("balance: $balance");
    print("datas: $datas");

    //List<String> list = [];
    List<Widget> list = <Widget>[];
    data
        .map(
          (e) => e.forEach((key, value) {
            //list.add(key);
            // list.add(value['list'].toString());
            list.add(
              Padding(
                padding: EdgeInsets.only(left: width * .05, right: width * .05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cdate1 == df.format(DateTime.parse(key))
                        ? Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: width * .040,
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        : Text(
                            df.format(DateTime.parse(key)),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: width * .040,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                    Text(
                      '$currency${value['total_amount']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: width * .040,
                        // fontSize: context.width(.055),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            );
            list.add(
              Padding(
                padding: EdgeInsets.only(
                  bottom: height * .02,
                  top: height * .02,
                ),
                child: Card(
                  margin: EdgeInsets.only(
                    top: height * .0,
                    bottom: height * .0,
                  ),
                  color: const Color.fromARGB(255, 242, 242, 242),
                  elevation: 0,
                  child: Container(
                    padding: EdgeInsets.only(bottom: height * .0),
                    decoration: const BoxDecoration(border: Border()),
                    child: ListView.separated(
                      //scrollDirection: Axis.vertical
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => SizedBox(
                        height: 10,
                        child: Container(color: Colors.white),
                      ),
                      shrinkWrap: true,
                      itemCount: value['list'] == null
                          ? 0
                          : value['list'].length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return ListTile(
                          // isThreeLine: true,
                          horizontalTitleGap: 7.0,
                          contentPadding: EdgeInsets.only(
                            bottom: height * .0,
                            right: width * .03,
                            left: width * .03,
                          ),
                          onTap: () {
                            //Navigator.of(context).pushNamed("TransactionSummary");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionSummary(
                                  spent_current_month:
                                      value['list'][index]["spent_current_month"],
                                  spent_last_month:
                                      value['list'][index]["spent_last_month"],
                                  balance: balance,
                                  recuring: value['list'][index]["recuring"],
                                  allocation_id:
                                      value['list'][index]["allocation_id"],
                                  label2: value['list'][index]["label"][0],
                                  label: value['list'][index]["label"],
                                  amount: value['list'][index]["amount"],
                                  date: value['list'][index]["date"].toString(),
                                  note: value['list'][index]["note"].toString(),
                                ),
                              ),
                            );
                          },
                          trailing: Text(
                            '$currency${double.parse(value['list'][index]["amount"]).toStringAsFixed(2)}'
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                ),
                          ),
                          leading: Padding(
                            padding: EdgeInsets.only(top: height * .01),
                            child: Container(
                              alignment: Alignment.center,
                              height: height * .03,
                              width: width * .08,
                              color: const Color.fromARGB(255, 230, 193, 105),
                              child: Text(
                                toBeginningOfSentenceCase(
                                  value['list'][index]["label"][0].toString(),
                                )!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * .050,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          title: Padding(
                            padding: EdgeInsets.only(top: height * .0),
                            child: Text(
                              toBeginningOfSentenceCase(
                                "${value['list'][index]["label"]}",
                              )!,
                              style: TextStyle(
                                fontSize: width * .050,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );

            //list.add(value['list'][0]['amount'].toString());
          }),
        )
        .toList();
    for (var element in list) {
      print(element);
    }
    Set<Widget> set = Set.from(list);
    for (var element in set) {
      print(element);
    }

    Map<String, String> mapOfDateAndlist = {};
    data
        .map(
          (e) => e.forEach((key, value) {
            //mapOfDateAndFirstname.addAll({key: value['total_amount'].toString()});
            mapOfDateAndlist.addAll({key: value.toString()});
          }),
        )
        .toList();
    // print(mapOfDateAndlist);
    Map map = Map.unmodifiable(mapOfDateAndlist);

    final values = data.expand((e) => e.values).toList();
    backgrounds.map((values) {
      //print(values);
      setState(() {
        colors = values;
        // print('background: $colors');
      });
    }).toList();
    values.map((values) {
      //print("values:$values");
      setState(() {
        recordData = values['total_amount'];
        // list = values['list'];
        spent_current_month = values['spent']['spent_current_month'];
        spent_last_month = values['spent']['spent_last_month'];
      });
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SEED',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.045),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.blue.withOpacity(.05),
        height: height,
        child: ListView(
          children: [
            SizedBox(height: height * .03),
            Stack(
              children: [
                Center(
                  child: Container(
                    width: width * .88,
                    height: height * .20,
                    decoration: BoxDecoration(
                      color: const Color(0xffD13B56),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          //color: Color(0xff00B050).withOpacity(0.4),
                          spreadRadius: 6,
                          blurRadius: 1,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: height * .04,
                  left: width * .04,
                  right: width * .0,
                  child: Center(
                    child: SizedBox(
                      width: width * .88,
                      height: height * .10,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: height * .00,
                          right: width * .10,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  'Transaction',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.width(.07),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  'Summary',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.width(.07),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: width * .27),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ClipPath(
                      clipper: ProsteBezierCurve(
                        position: ClipPosition.top,
                        list: [
                          BezierCurveSection(
                            start: Offset(screenWidth, 0),
                            top: Offset(screenWidth / 2, 30),
                            end: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Container(color: Colors.white, height: height),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * .25),
                  child: Column(
                    children: set
                        .map((item) => Column(children: [item]))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
