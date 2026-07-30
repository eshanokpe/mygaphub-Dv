import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/utils/dialog.dart';
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
import 'Saddnote.dart';
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
  final DialogBox dialogBox = DialogBox();
  final TextEditingController _note = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _label = TextEditingController();
  String left = '';
  List<SavingAllserver> _data = [];
  List<SavingAllserver> item = [];

  bool _showTextField = false;
  int totalleft = 0;
  String id = '';
  int balance = 0;
  var index;
  var amount;

  @override
  void initState() {
    EasyLoading.dismiss();
    setState(() => index = context.read<Providers>().index);
    setState(
      () => item = List<SavingAllserver>.from(context.read<Providers>().item),
    );

    _note.text = item[index].note.toString();
    _label.text = item[index].label.toString();
    _amount.text = item[index].amount.toString();
    amount = item[index].amount;
    print("_amount:$amount");
    fectchAllocation();
  }

  var _allocationUrl;
  fectchAllocation() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    _allocationUrl = Uri.parse(
      "$baseUrl/app/seed/allocate/${widget.item[widget.index].id}",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    if (token == null) {
      EasyLoading.dismiss();
      _showErrorToast('Authentication failed');
      return;
    }

    try {
      Response response = await Dio().get(
        '$_allocationUrl',
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Content-Type": 'application/json',
          },
        ),
        queryParameters: {'allocation_id': '${widget.item[widget.index].id}'},
      );

      if (response.statusCode == 200) {
        var body = response.data;
        var records = body["data"]['summary'];
        var totalspent = records['total_spent'];
        print('totalspent: $totalspent');

        var left = records['total_left'];
        EasyLoading.dismiss();
        if (mounted) {
          setState(() {
            totalleft = left;
          });
        }
        print('totalleft: $totalleft');
        return totalleft;
      } else {
        EasyLoading.dismiss();
        _showErrorToast('Failed to fetch allocation');
      }
    } catch (e) {
      EasyLoading.dismiss();
      print('Fetch allocation error: $e');
      _showErrorToast('Error loading allocation');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("index:$index");

    // Fix the balance calculation
    int newBalance = 0;
    if (totalleft == widget.item[widget.index].amount) {
      newBalance = 0;
    } else {
      newBalance = totalleft;
    }

    // Only call setState if balance actually changed
    if (balance != newBalance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            balance = newBalance;
          });
        }
      });
    }

    print('balance:$balance');
    print('totalleft:$totalleft');

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
          widget.item[widget.index].label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.035),
          ),
        ),
        actions: [
          Container(
            child: (totalleft < widget.item[widget.index].amount)
                ? Container()
                : Material(
                    child: InkWell(
                      onTap: () {
                        _showDeleteConfirmationDialog(width, height);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(
                          'assets/images/deletee.png',
                          width: width * .05,
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
                                  width: width * .05,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  if (widget.index != 0) {
                                    setState(() {
                                      widget.index--;
                                    });
                                    fectchAllocation();
                                  }
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
                                    value: double.parse(balance.toString()),
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
                                "left of $currency ${amount.toStringAsFixed(2)}",
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
                                  width: width * .05,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  if (widget.index != widget.item.length - 1) {
                                    setState(() {
                                      widget.index++;
                                    });
                                    fectchAllocation();
                                  }
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
                                        width: width * .05,
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
                                        fontSize: width * .040,
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
                                      fontSize: width * .040,
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
                                          isDense: true,
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
                                        fontSize: context.width(.04),
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
                                      fontSize: context.width(.04),
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
                                        width: width * .05,
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
                                        fontSize: width * .040,
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
                              "$currency${totalleft.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * .040,
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
                                  fontSize: context.width(.04),
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
                                        width: width * .05,
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
                                widget.item[widget.index].note!,
                                maxLines: 15,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: width * .040,
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
                                    fontSize: context.width(.04),
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
          color: Colors.white,
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
                              color: Color.fromARGB(132, 0, 0, 0),
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: Offset(0, -7),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Divider(
                              color: Colors.black26,
                              thickness: 3,
                              indent: 160,
                              endIndent: 160,
                            ),
                            Text(
                              "Tap to view transactions",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * .04,
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
                      await _navigateToTransactions();
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
                              color: Color.fromARGB(132, 0, 0, 0),
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: Offset(0, -7),
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

  Future<void> _navigateToTransactions() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var timer = Timer(const Duration(seconds: 20), () {
      EasyLoading.dismiss();
      _showErrorDialog('Service timed out');
      return;
    });

    try {
      final allocationUrl = Uri.parse(
        "$baseUrl/app/seed/allocate/${widget.item[widget.index].id}",
      );
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token == null) {
        timer.cancel();
        EasyLoading.dismiss();
        _showErrorToast('Authentication failed');
        return;
      }

      Response response = await Dio().get(
        '$allocationUrl',
        options: Options(
          headers: {
            "Authorization": 'Bearer $token',
            "Content-Type": 'application/json',
          },
        ),
        queryParameters: {'allocation_id': '${widget.item[widget.index].id}'},
      );

      timer.cancel();
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        var body = response.data;
        var records = body["data"]['summary'];
        var totalleft = records['total_left'];

        if (mounted) {
          Navigator.push(
            context,
            CustomPageRouteBuilder(
              widget: SwipeTransaction(
                totalleft: totalleft,
                data: response.data,
              ),
            ),
          );
        }
      } else {
        _showErrorToast('Failed to load transactions');
      }
    } catch (e) {
      timer.cancel();
      EasyLoading.dismiss();
      print('Transaction navigation error: $e');
      _showErrorToast('Error loading transactions');
    }
  }

  void _showDeleteConfirmationDialog(double width, double height) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close, color: Colors.black),
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
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * .01),
                  SizedBox(
                    width: 200.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00B050),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * .01),
                        ),
                      ),
                      onPressed: () => _deleteAllocation(context),
                      child: Text(
                        "DELETE",
                        style: TextStyle(
                          color: Colors.white,
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
  }

  updateSavingsAllocation() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    var timer = Timer(const Duration(seconds: 20), () {
      EasyLoading.dismiss();
      _showErrorDialog('Update timed out');
      return;
    });

    try {
      var id = widget.item[widget.index].id;
      print('idupdate:$id');
      var url0 = Uri.parse("$baseUrl/app/seed/allocate/budget/$id");
      var urlSA = Uri.parse(
        "$baseUrl/app/seed/allocate/budget?category=savings",
      );
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      if (token == null) {
        timer.cancel();
        EasyLoading.dismiss();
        _showErrorToast('Authentication failed');
        return;
      }

      final response = await http
          .put(
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
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Update request timed out');
            },
          );

      if (response.statusCode == 200) {
        final response2 = await http
            .get(urlSA, headers: {"Authorization": 'Bearer $token'})
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException('Fetch request timed out');
              },
            );

        if (response2.statusCode == 200) {
          var savall = jsonDecode(response2.body);
          var data = savall["data"]['budget_allocations'];
          print(data);

          if (data != null) {
            List res = data;

            var url = Uri.parse("$baseUrl/app/seed");
            var seedResponse = await http
                .get(url, headers: {"Authorization": 'Bearer $token'})
                .timeout(
                  const Duration(seconds: 15),
                  onTimeout: () {
                    throw TimeoutException('Seed request timed out');
                  },
                );

            if (seedResponse.statusCode == 200) {
              var body = jsonDecode(seedResponse.body);
              context.read<Providers>().setSeeData(body);

              setState(() {
                _data = res
                    .map((data) => SavingAllserver.fromJson(data))
                    .toList();
              });

              timer.cancel();
              EasyLoading.dismiss();

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavingAllocationSummary(data: _data),
                  ),
                );
              }

              _showSuccessToast('Savings Allocation has been updated');
            } else {
              throw Exception('Failed to fetch seed data');
            }
          } else {
            throw Exception('Invalid response format');
          }
        } else {
          throw Exception('Failed to fetch savings list');
        }
      } else {
        throw Exception('Update failed with status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      timer.cancel();
      EasyLoading.dismiss();
      _showErrorToast(e.message ?? 'Request timed out');
    } catch (e) {
      timer.cancel();
      EasyLoading.dismiss();
      print('Update error: $e');
      _showErrorToast(
        'Update failed: ${_getUserFriendlyErrorMessage(e.toString())}',
      );
    }
  }

  Future<void> _deleteAllocation(BuildContext dialogContext) async {
    // Close the dialog first
    Navigator.pop(dialogContext);

    // Show loading indicator
    dialogBox.waiting(context, 'Deleting allocation...');

    final cancelToken = CancelToken();
    final timeoutTimer = Timer(const Duration(seconds: 25), () {
      cancelToken.cancel('Request timeout');
      _handleDeleteError('Request timed out. Please try again.');
    });

    try {
      final id = widget.item[widget.index].id;
      print('Deleting allocation with id: $id');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final deleteResponse = await _performDeleteRequest(id.toString(), token);

      if (mounted) {
        if (deleteResponse.statusCode == 200 ||
            deleteResponse.statusCode == 201) {
          await _fetchUpdatedSavingsList(token);

          timeoutTimer.cancel();

          // Dismiss loading
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          _showSuccessToast('Savings Allocation has been Deleted Successfully');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SavingAllocationSummary(data: _data),
              ),
            );
          }
        } else if (deleteResponse.statusCode == 400) {
          timeoutTimer.cancel();
          if (mounted) Navigator.of(context, rootNavigator: true).pop();
          _showErrorToast('Allocation cannot be deleted');
        } else {
          throw Exception('Server returned ${deleteResponse.statusCode}');
        }
      }
    } catch (e) {
      timeoutTimer.cancel();
      _handleDeleteError(e.toString());
    }
  }

  Future<http.Response> _performDeleteRequest(String id, String token) async {
    final url = Uri.parse("$baseUrl/app/seed/allocate/budget/$id");

    try {
      print('id:$id');
      print('lable:${_label.text}');
      print('amount:${_amount.text}');
      print('note:${_note.text}');
      final response = await http
          .delete(
            url,
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
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw TimeoutException('Delete request timed out');
            },
          );

      return response;
    } catch (e) {
      print('Delete request error: $e');
      rethrow;
    }
  }

  Future<void> _fetchUpdatedSavingsList(String token) async {
    final urlSA = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=savings",
    );

    try {
      final savingsResponse = await http
          .get(
            urlSA,
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Failed to fetch updated list');
            },
          );

      if (savingsResponse.statusCode == 200) {
        final body = jsonDecode(savingsResponse.body);
        final data = body["data"]['budget_allocations'];

        if (data != null) {
          List res = data;
          if (mounted) {
            setState(() {
              _data = res
                  .map((data) => SavingAllserver.fromJson(data))
                  .toList();
            });
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to fetch savings: ${savingsResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Fetch savings error: $e');
      rethrow;
    }
  }

  void _handleDeleteError(String errorMessage) {
    // Dismiss loading if showing
    if (mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        // Dialog might already be dismissed
      }
    }

    String userMessage = _getUserFriendlyErrorMessage(errorMessage);
    _showErrorToast(userMessage);

    if (errorMessage.contains('token') ||
        errorMessage.contains('authentication') ||
        errorMessage.contains('401') ||
        errorMessage.contains('unauthorized')) {
      _showErrorDialog('Authentication failed. Please login again.');
    }
  }

  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('timeout') || error.contains('timed out')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (error.contains('SocketException') || error.contains('Network')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('401') || error.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (error.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.contains('404')) {
      return 'Allocation not found. It may have been already deleted.';
    } else {
      return 'Operation failed. Please try again.';
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: const Color(0xff00B050),
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      dialogBox.information(context, 'Error', message);
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
