import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'saddnote.dart';
import 'saving_allocation_summary.dart';
import 'swipeTransaction.dart';

class ViewDetailSavAllocation extends StatefulWidget {
  List<SavingAllserver> item;
  int index;
  ViewDetailSavAllocation({super.key, required this.index, required this.item});
  @override
  State<ViewDetailSavAllocation> createState() =>
      _ViewDetailSavAllocationState();
}

class _ViewDetailSavAllocationState extends State<ViewDetailSavAllocation> {
  final TextEditingController _note = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _label = TextEditingController();
  String left = '';
  List<SavingAllserver> _data = [];
  bool _showTextField = false;
  int totalleft = 0;
  String id = "";
  int balance = 0;

  @override
  void initState() {
    fectchAllocation();
    EasyLoading.dismiss();
    _note.text = widget.item[widget.index].note.toString();
    _label.text = widget.item[widget.index].label.toString();
    _amount.text = widget.item[widget.index].amount.toString();
    print("budgetid:${widget.item[widget.index].id}");
  }

  fectchAllocation() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    final allocationUrl = Uri.parse(
      "$baseUrl/app/seed/allocate/${widget.item[widget.index].id}",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Response response = await Dio().get(
      '$allocationUrl',
      options: Options(
        headers: {
          "Authorization": 'Bearer $token',
          "Content-Type": 'appllication/json',
        },
      ),
      queryParameters: {'allocation_id': '${widget.item[widget.index].id}'},
    );
    if (response.statusCode == 200) {
      var body = response.data;
      // print('body: $body');
      var records = body["data"]['summary'];
      var totalspent = records['total_spent'];
      //var totalspent = records['total_spent'];
      print('totalspent: $totalspent');

      var left = records['total_left'];
      EasyLoading.dismiss();
      setState(() {
        totalleft = left;
      });
      //left = totalleft;

      print('totalleft: $totalleft');
      return totalleft;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalleft == widget.item[widget.index].amount) {
      setState(() {
        balance = 0;
      });
    } else {
      setState(() {
        balance = totalleft;
      });
    }
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue.withOpacity(.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.item[widget.index].label} ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.045),
          ),
        ),
        actions: [
          Container(
            child: (totalleft < widget.item[widget.index].amount)
                ? Container()
                : Material(
                    child: InkWell(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            insetPadding: EdgeInsets.zero,
                            titlePadding: EdgeInsets.only(top: width * .01),
                            elevation: 5,
                            content: StatefulBuilder(
                              builder: (context, StateSetter setState) {
                                return Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Are you sure you want \n to DELETE this item? ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * .05,
                                        ),
                                      ),
                                      SizedBox(height: height * .01),
                                      SizedBox(
                                        width: 200.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xff00B050,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    width * .01,
                                                  ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            EasyLoading.show(
                                              status: 'Loading',
                                              dismissOnTap: false,
                                            );
                                            var id =
                                                widget.item[widget.index].id;
                                            print('id: $id');
                                            var url = Uri.parse(
                                              "$baseUrl/app/seed/allocate/budget/$id",
                                            );
                                            var urlSA = Uri.parse(
                                              "$baseUrl/app/seed/allocate/budget?category=savings",
                                            );
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            var token = prefs.getString(
                                              'tokenDB',
                                            );
                                            var response = await http.delete(
                                              url,
                                              body: {
                                                'category': 'savings',
                                                'label': _label.text.trim(),
                                                "amount": _amount.text.trim(),
                                                'note': _note.text.trim(),
                                              },
                                              headers: {
                                                "Authorization":
                                                    'Bearer $token',
                                                "Accept": "application/json",
                                                "Content-Type":
                                                    "application/x-www-form-urlencoded",
                                              },
                                              encoding: Encoding.getByName(
                                                "utf-8",
                                              ),
                                            );
                                            if (response.statusCode == 400) {
                                              Fluttertoast.showToast(
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                msg:
                                                    'Allocation cannot be deleted',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                              EasyLoading.dismiss();
                                            } else {
                                              //throw "Sorry! Unable to delete this post.";
                                              var savingsresponse = await http.get(
                                                urlSA,
                                                headers: {
                                                  "Authorization":
                                                      'Bearer $token',
                                                  "Accept": "application/json",
                                                  "Content-Type":
                                                      "application/x-www-form-urlencoded",
                                                },
                                              );
                                              if (savingsresponse.statusCode ==
                                                  200) {
                                                var body = jsonDecode(
                                                  savingsresponse.body,
                                                );
                                                var data =
                                                    body["data"]['budget_allocations'];
                                                List res = data;
                                                setState(() {
                                                  _data = res
                                                      .map(
                                                        (data) =>
                                                            SavingAllserver.fromJson(
                                                              data,
                                                            ),
                                                      )
                                                      .toList();
                                                });

                                                Fluttertoast.showToast(
                                                  backgroundColor: const Color(
                                                    0xff00B050,
                                                  ),
                                                  textColor: Colors.white,
                                                  msg:
                                                      'Savings Allocation has been Deleted Successfully',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                );
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FS_SavingAllocationSummary(
                                                          data: _data,
                                                        ),
                                                  ),
                                                );
                                                EasyLoading.dismiss();
                                              }
                                            }
                                          },
                                          child: Text(
                                            "DELETE",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * .05,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(
                          'assets/images/deletee.png',
                          // color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * .33,
              child: Column(
                children: [
                  SizedBox(height: height * .02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: widget.index == 0
                            ? SizedBox(height: height * .03, width: width * .03)
                            : IconButton(
                                icon: Image.asset(
                                  'assets/images/left_chevron.png',
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (widget.index != 0) {
                                      widget.index--;
                                      print('previous:${widget.index}');
                                    }
                                    fectchAllocation();
                                  });
                                },
                              ),
                      ),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            height: height * .3,
                            width: height * .3,
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: 75,

                                ///centerSpaceColor: Colors.yellow,
                                startDegreeOffset: 55,
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 05,
                                sections: [
                                  PieChartSectionData(
                                    radius: 20,
                                    showTitle: false,
                                    value: double.parse(
                                      widget.item[widget.index].amount
                                          .toString(),
                                    ),
                                    color: const Color(0xff00B050),
                                  ),
                                  PieChartSectionData(
                                    showTitle: false,
                                    radius: 20,
                                    value:
                                        double.parse(balance.toString()) ?? 0,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 0,
                              top: height * .11,
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "$currency${totalleft.toStringAsFixed(2)} ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * .06,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 0,
                              top: height * .15,
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "left of $currency ${widget.item[widget.index].amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: width * .04,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: widget.index == widget.item.length - 1
                            ? SizedBox(height: height * .03, width: width * .03)
                            : IconButton(
                                icon: Image.asset(
                                  'assets/images/right_chevron.png',
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (widget.index !=
                                        widget.item.length - 1) {
                                      widget.index++;
                                      print('next:${widget.index}');
                                    }
                                    fectchAllocation();
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: height * .02),
            Card(
              color: Colors.white,
              elevation: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * .02,
                  vertical: height * .01,
                ),
                child: Column(
                  children: [
                    //Budget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: width * .0),
                                  child: IconButton(
                                    icon: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: Image.asset(
                                        'assets/images/piggyy.png',
                                        color: Colors.blue,
                                      ),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: width * .03),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Budget",
                                      style: TextStyle(
                                        color: const Color(0xff00B050),
                                        fontSize: width * .050,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _showTextField == false
                                ? Text(
                                    "$currency${widget.item[widget.index].amount.toStringAsFixed(2)}"
                                        .replaceAllMapped(
                                          RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                          ),
                                          (Match m) => '${m[1]},',
                                        ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: width * .050,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                : Visibility(
                                    visible: _showTextField,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: SizedBox(
                                      width: width * .40,
                                      height: height * .05,
                                      child: TextField(
                                        maxLines: 1,
                                        controller: _amount,
                                        inputFormatters: [amountValidator],
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          prefix: Text(
                                            "$currency ",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),

                                          border: const OutlineInputBorder(),
                                          isDense: true, // Aded this
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        _showTextField == false
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showTextField = !_showTextField;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: context.width(.05),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Visibility(
                                visible: _showTextField,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.red,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showTextField = !_showTextField;
                                    });
                                    updateSavingsAllocation();
                                  },
                                  child: Text(
                                    "Update",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.width(.05),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),

                    //Balance
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .0,
                        right: width * .0,
                      ),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Divider(
                          thickness: 1.5,
                          color: Color.fromARGB(253, 196, 196, 196),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: width * .0),
                                  child: IconButton(
                                    icon: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: Image.asset(
                                        'assets/images/balance.png',
                                        //color: Colors.blue,
                                      ),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: width * .03),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Balance",
                                      style: TextStyle(
                                        color: const Color(0xff00B050),
                                        fontSize: width * .050,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "$currency${totalleft.toStringAsFixed(2) ?? 0}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * .050,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          clipBehavior: Clip.none,
                          onPressed: null,
                          child: Row(
                            children: [
                              Text(
                                "Edit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.width(.05),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    //Notes
                    Padding(
                      padding: EdgeInsets.only(
                        left: width * .0,
                        right: width * .0,
                      ),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Divider(
                          thickness: 1.5,
                          color: Color.fromARGB(253, 196, 196, 196),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: width * .0),
                                  child: IconButton(
                                    icon: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: Image.asset(
                                        'assets/images/notee.jpg',
                                      ),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: width * .03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item[widget.index].note,
                                maxLines: 15,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * .050,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SAddNote(
                                    item: widget.item,
                                    index: widget.index,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: context.width(.05),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          child: (widget.item[widget.index].amount == totalleft)
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'No Record Spent',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        bottom: 5,
                        right: 0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                132,
                                0,
                                0,
                                0,
                              ), // the color of a shadow, you can adjust it
                              spreadRadius:
                                  0, //also play with this two values to achieve your ideal result
                              blurRadius: 5,
                              offset: Offset(
                                0,
                                -7,
                              ), // changes position of shadow, negative value on y-axis makes it appering only on the top of a container
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Divider(
                              color: Colors.black26,
                              thickness: 3,
                              indent: 160,
                              endIndent: 160,
                            ),
                            Text(
                              "Tap to view transactions",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      EasyLoading.show(status: 'Loading', dismissOnTap: false);
                      var timer = Timer(
                        const Duration(milliseconds: 20000),
                        () {
                          // Navigator.pop(context);
                          EasyLoading.dismiss();
                          dialogBox.information(
                            context,
                            'Status',
                            'Service timed out',
                          );
                          return;
                        },
                      );
                      // bool result = await isInternetAvailable();
                      // if (!result) {
                      //   dialogBox.information(context, 'Status',
                      //       'Check your Internet Connection');
                      //   EasyLoading.dismiss();
                      //   return;
                      // }
                      final allocationUrl = Uri.parse(
                        "$baseUrl/app/seed/allocate/${widget.item[widget.index].id}",
                      );
                      final prefs = await SharedPreferences.getInstance();
                      var token = prefs.getString('tokenDB');
                      Response response = await Dio().get(
                        '$allocationUrl',
                        options: Options(
                          headers: {
                            "Authorization": 'Bearer $token',
                            "Content-Type": 'appllication/json',
                          },
                        ),
                        queryParameters: {
                          'allocation_id': '${widget.item[widget.index].id}',
                        },
                      );
                      if (response.statusCode == 200) {
                        var body = response.data;
                        // print('body: $body');
                        var records = body["data"]['summary'];
                        var totalspent = records['total_spent'];
                        //var totalspent = records['total_spent'];
                        print('totalspent: $totalspent');
                        var totalleft = records['total_left'];

                        print('totalleft: $totalleft');

                        timer.cancel();
                        Navigator.push(
                          context,
                          CustomPageRouteBuilder(
                            widget: SwipeTransaction(
                              totalleft: totalleft,
                              data: response.data,
                            ),
                          ),
                        );
                        EasyLoading.dismiss();
                      } else {
                        timer.cancel();
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        bottom: 5,
                        right: 0,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                132,
                                0,
                                0,
                                0,
                              ), // the color of a shadow, you can adjust it
                              spreadRadius:
                                  0, //also play with this two values to achieve your ideal result
                              blurRadius: 5,
                              offset: Offset(
                                0,
                                -7,
                              ), // changes position of shadow, negative value on y-axis makes it appering only on the top of a container
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Divider(
                              color: Colors.black26,
                              thickness: 3,
                              indent: 160,
                              endIndent: 160,
                            ),
                            Text(
                              "Tap to view transactions",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  updateSavingsAllocation() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var timer = Timer(const Duration(milliseconds: 20000), () {
      // Navigator.pop(context);
      EasyLoading.dismiss();
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    // bool result = await isInternetAvailable();
    // if (!result) {
    //   dialogBox.information(
    //       context, 'Status', 'Check your Internet Connection');
    //   EasyLoading.dismiss();
    //   return;
    // }
    var id = widget.item[widget.index].id;
    print('idupdate:$id');
    var url0 = Uri.parse("$baseUrl/app/seed/allocate/budget/$id");
    var urlSA = Uri.parse("$baseUrl/app/seed/allocate/budget?category=savings");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    final response = await http.put(
      url0,
      body: {
        'category': 'savings',
        'label': _label.text.trim(),
        "amount": _amount.text.trim(),
        'note': _note.text.trim(),
      },
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );
    if (response.statusCode == 200) {
      var response2 = await http.get(
        urlSA,
        headers: {"Authorization": 'Bearer $token'},
      );
      if (response2.statusCode == 200) {
        // EasyLoading.dismiss();
        var savall = jsonDecode(response2.body);
        var data = savall["data"]['budget_allocations'];
        print(data);
        List res = data;
        var url = Uri.parse("$baseUrl/app/seed");

        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        var response = await http.get(
          url,
          headers: {"Authorization": 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);
          context.read<Providers>().setSeeData(body);

          List res = data;
          setState(() {
            _data = res.map((data) => SavingAllserver.fromJson(data)).toList();
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FS_SavingAllocationSummary(data: _data),
            ),
          );
          Fluttertoast.showToast(
            backgroundColor: const Color(0xff00B050),
            msg: 'Savings Allocation has been updated',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          EasyLoading.dismiss();
        } else {
          EasyLoading.dismiss();
          timer.cancel();
          Navigator.pop(context);
        }
      } else {
        EasyLoading.dismiss();
        timer.cancel();
        Fluttertoast.showToast(
          msg: 'Error E',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      timer.cancel();
      print(response.statusCode);
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: 'Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}

class CustomPageRouteBuilder<T> extends PageRouteBuilder<T> {
  CustomPageRouteBuilder({required this.widget})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              final Widget transition = SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0.0, -0.7),
                  ).animate(secondaryAnimation),
                  child: child,
                ),
              );

              return transition;
            },
      );

  final Widget widget;
}
