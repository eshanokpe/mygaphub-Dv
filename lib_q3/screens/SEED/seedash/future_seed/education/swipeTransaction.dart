// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/SEED/seedash/seedallocation/record_spend/recordspend.dart';
import 'package:GapHub/screens/SEED/seedash/seedallocation/record_spend/transaction_summary.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'package:shared_preferences/shared_preferences.dart';

import 'educationtransaction_summary.dart';

class SwipeTransaction extends StatefulWidget {
  Map data;
  var totalleft;
  SwipeTransaction({super.key, required this.data, this.totalleft});

  @override
  State<SwipeTransaction> createState() => _SwipeTransactionState();
}

class _SwipeTransactionState extends State<SwipeTransaction> {
  final date = DateFormat("dd, EEEEE, yyyy");
  TextEditingController editingController = TextEditingController();
  String? cdate1;
  final duplicateItems = List<String>.generate(10, (i) => "Item $i");
  String? duplicateItemss;
  List<String> items = [];
  List<Widget> itemss = <Widget>[];
  var balance;
  bool _checkConfiguration() => true;
  String query = '';

  String? currency;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var UserDatamodels = Provider.of<Providers>(context, listen: false);
      currency = UserDatamodels.snapshotmodel.currency;
    });
    super.initState();
    if (_checkConfiguration()) {
      Future.delayed(const Duration(milliseconds: 200), () {
        Orientation orientation = MediaQuery.of(context).orientation;
        // double screenWidth = MediaQuery.of(context).size.width;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;

        List<dynamic> data = widget.data["data"]['record_spents'];
        balance = widget.data["data"]['summary']['total_left'];
        data
            .map(
              (e) => e.forEach((key, value) {
                itemss.add(
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * .05,
                      right: width * .05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cdate1 == date.format(DateTime.parse(key))
                            ? Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w300,
                                ),
                              )
                            : Text(
                                date.format(DateTime.parse(key)),
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
                itemss.add(
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: height * .03,
                      top: height * .01,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        //border: Border(),
                        color: Color.fromARGB(192, 242, 242, 242),
                      ),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EducationTransactionSummary(
                                    spent_current_month:
                                        value['list'][index]["spent_current_month"],
                                    spent_last_month:
                                        value['list'][index]["spent_last_month"],
                                    balance: balance,
                                    recuring: value['list'][index]["recuring"],
                                    id: value['list'][index]["id"],
                                    allocation_id:
                                        value['list'][index]["allocation_id"],
                                    label2: value['list'][index]["label"][0],
                                    label: value['list'][index]["label"],
                                    amount: value['list'][index]["amount"],
                                    date: value['list'][index]["date"],
                                    note:
                                        value['list'][index]["note"] ??
                                        'No note available',
                                  ),
                                ),
                              );
                            },
                            trailing: Text(
                              '$currency${num.parse(value['list'][index]["amount"]).toStringAsFixed(2)}'
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
                );
                setState(() {
                  duplicateItemss = value['list'].toString();
                });
              }),
            )
            .toList();

        items.addAll(duplicateItems);
      });
    }
  }

  void searchResults(String query) {
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenWidth = MediaQuery.of(context).size.width;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    List<dynamic> data = widget.data["data"]['record_spents'];
    List<Widget> dummySearchList = <Widget>[];

    if (query.isNotEmpty) {
      List<Widget> dummyListData = <Widget>[];
      data
          .map(
            (e) => e.forEach((key, value) {
              if (value['list'].toString().contains(query)) {
                dummyListData.add(
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * .05,
                      right: width * .05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cdate1 == date.format(DateTime.parse(key))
                            ? Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w300,
                                ),
                              )
                            : Text(
                                date.format(DateTime.parse(key)),
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
                dummyListData.add(
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: height * .03,
                      top: height * .01,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        //border: Border(),
                        color: Color.fromARGB(192, 242, 242, 242),
                      ),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EducationTransactionSummary(
                                    spent_current_month:
                                        value['list'][index]["spent_current_month"],
                                    spent_last_month:
                                        value['list'][index]["spent_last_month"],
                                    balance: balance,
                                    recuring: value['list'][index]["recuring"],
                                    id: value['list'][index]["id"],
                                    allocation_id:
                                        value['list'][index]["allocation_id"],
                                    label2: value['list'][index]["label"][0],
                                    label: value['list'][index]["label"],
                                    amount: value['list'][index]["amount"],
                                    date: value['list'][index]["date"],
                                    note: value['list'][index]["note"],
                                  ),
                                ),
                              );
                            },
                            trailing: Text(
                              '$currency${num.parse(value['list'][index]["amount"]).toStringAsFixed(2)}'
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
                );
              }
            }),
          )
          .toList();
      setState(() {
        itemss.clear();
        itemss.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        data
            .map(
              (e) => e.forEach((key, value) {
                itemss.clear();
                //itemss.add(Text(key.toString()));
                itemss.add(
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * .05,
                      right: width * .05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cdate1 == date.format(DateTime.parse(key))
                            ? Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * .040,
                                  fontWeight: FontWeight.w300,
                                ),
                              )
                            : Text(
                                date.format(DateTime.parse(key)),
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

                itemss.add(
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: height * .03,
                      top: height * .01,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        //border: Border(),
                        color: Color.fromARGB(192, 242, 242, 242),
                      ),
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
                                    date: value['list'][index]["date"],
                                    note: value['list'][index]["note"],
                                  ),
                                ),
                              );
                            },
                            trailing: Text(
                              '$currency${num.parse(value['list'][index]["amount"]).toStringAsFixed(2)}'
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
                );
              }),
            )
            .toList();
      });
    }
    for (var element in itemss) {
      print('');
    }
    setState(() {
      Set<Widget> set = Set.from(itemss);
      set.forEach((element) => {});
    });
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = [];
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = [];
      for (var item in dummySearchList) {
        if (item.toString().contains(query)) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    cdate1 = DateFormat("dd, EEEEE, yyyy").format(DateTime.now());
    print(cdate1);
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenWidth = MediaQuery.of(context).size.width;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    const styleActive = TextStyle(color: Colors.black);
    const styleHint = TextStyle(color: Color.fromARGB(255, 89, 89, 89));
    final style = editingController.text.isEmpty ? styleHint : styleActive;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Balance',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: width * .04,
              ),
            ),
            Text(
              '$currency${widget.totalleft}',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: width * .05,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var url = Uri.parse("$baseUrl/app/seed");
              var timer = Timer(const Duration(milliseconds: 20000), () {
                Navigator.pop(context);
                dialogBox.information(context, 'Status', 'Service timed out');
                return;
              });
              dialogBox.waiting(context, 'Loading');
              final prefs = await SharedPreferences.getInstance();
              var token = prefs.getString('tokenDB');
              var response = await http.get(
                url,
                headers: {"Authorization": 'Bearer $token'},
              );
              if (response.statusCode == 200) {
                var body = jsonDecode(response.body);

                context.read<Providers>().setSeeData(body);
                timer.cancel();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordSpend(true)),
                );
              } else {
                timer.cancel();
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_down_sharp,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(height: height * .02, color: Colors.white),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(132, 0, 0, 0),
                    spreadRadius: 0,
                    blurRadius: 7,
                    offset: Offset(0, -7),
                  ),
                ],
              ),
              child: SizedBox(
                height: height,
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .01,
                        bottom: height * .0,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Divider(
                          color: Colors.black26,
                          thickness: 3,
                          indent: 160,
                          endIndent: 160,
                        ),
                      ),
                    ),
                    Container(
                      height: 42,
                      margin: EdgeInsets.fromLTRB(
                        width * .08,
                        5,
                        width * .05,
                        16,
                      ),
                      decoration: const BoxDecoration(
                        //borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        // border: Border.all(color: Colors.black26),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        onChanged: (value) {
                          searchResults(value);
                        },
                        autofocus: false,
                        controller: editingController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(width * .02),
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.only(top: 8),
                          fillColor: const Color.fromARGB(255, 217, 217, 217),
                          prefixIcon: Icon(Icons.search, color: style.color),
                          suffixIcon: editingController.text.isNotEmpty
                              ? GestureDetector(
                                  child: Icon(Icons.close, color: style.color),
                                  onTap: () {
                                    editingController.clear();
                                    // FocusScope.of(context).requestFocus(FocusNode());
                                  },
                                )
                              : null,
                          hintText: 'Search transaction',
                          hintStyle: style,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * .02,
                        bottom: height * .25,
                      ),
                      child: Column(
                        children: itemss
                            .map((item) => Column(children: [item]))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
