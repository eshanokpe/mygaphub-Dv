import 'package:GapHub/widgets/bottomnav.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:intl/intl.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:GapHub/models/chartsmodel.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'mortgagedetails.dart';

class Mortgageitem extends StatefulWidget {
  final Map item;
  final bool seven;
  final bool archived;
  final bool zeroBalance;

  const Mortgageitem({
    super.key,
    required this.item,
    required this.seven,
    this.archived = false,
    this.zeroBalance = false,
  });
  @override
  _MortgageitemState createState() => _MortgageitemState();
}

class _MortgageitemState extends State<Mortgageitem> {
  TextEditingController name = TextEditingController();
  var key = GlobalKey<FormState>();

  TextEditingController details = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController extra = TextEditingController();
  TextEditingController period = TextEditingController();
  TextEditingController total_paid = TextEditingController();
  TextEditingController baseline = TextEditingController();
  TextEditingController interest = TextEditingController();
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  final List<charts.Series<Kpi, String>> _seriesData = [];

  addData(Map item, bool seven, String currency) {
    List<Kpi> data = [];
    // if (!seven) {
    for (var i = 0; i < item["labels"].length; i++) {
      double parsedValue = double.tryParse(item["values"][i].toString()) ?? 0.0;

      data.add(
        Kpi(
          kpi: Text("${item["labels"][i]}"),
          value: parsedValue ?? 0.0, // fallback to 0.0 if parsing fails
          gradientColors: [const Color(0xff0070C0)],
        ),
      );
    }

    _seriesData.add(
      charts.Series(
        data: data,
        // domainFn: (Kpi kpi, int a) => kpi.kpi.data,
        domainFn: (Kpi kpi, _) => kpi.kpi.data!,
        measureFn: (Kpi kpi, _) => kpi.value,
        colorFn: (Kpi kpi, _) =>
            charts.ColorUtil.fromDartColor((kpi.gradientColors.first)),
        // outsideLabelStyleAccessorFn: (Kpi kpi, _) =>
        //     charts.TextStyleSpec(color: charts.MaterialPalette.red.shadeDefault),
        // fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: 'Mortgage',
        domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Kpi kpi, _) =>
            '$currency${(kpi.value).toInt()}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
      ),
    );
  }

  static const descList = <String>[
    '-Select-',
    'First Charge Mortgage',
    'Second Charge Mortgage',
    'Secured Loan',
  ];

  String description = '-Select-';
  final List<DropdownMenuItem<String>> _mortDesc = descList
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  double total1 = 0;
  String dateDB = "";
  DateTime? endd;
  bool enable = false;
  DateTime? datez;
  bool _paidOff = false;
  increment() {
    setState(() {
      double a = double.tryParse(baseline.text) ?? 0;
      double b = double.tryParse(current.text) ?? 0;

      total1 = a - b;
    });
  }

  @override
  void initState() {
    super.initState();
    String currency = context.read<Providers>().snapshotmodel.currency;

    addData(widget.item["chart"], widget.seven, currency);
    baseline.addListener(increment);
    current.addListener(increment);

    var item = widget.item;
    description = item["description"] ?? "-Select-";

    name.text = item["creditor_name"] ?? "";
    details.text = item["details"] ?? "";
    baseline.text = (item["open_balance"] ?? "").toString();
    current.text = (item["current_balance"] ?? "").toString();
    extra.text = item["extra"] ?? "";

    item["monthly_pay"].toString() != "null"
        ? period.text = item["monthly_pay"].toString()
        : period.text = "0";
    interest.text = "${item["interest_rate"] ?? "0"}";
    location.text = item["account_location"] ?? "";
    // total_paid.text = (int.parse(item["open_balance"].toString()) -
    //         int.parse(item["current_balance"].toString()))
    //     .toString();

    if (item["target_date"] != null) {
      dateDB = item["target_date"];
      datez = DateTime.parse(item["target_date"]);
      var d = DateFormat.yMMMMd();
      var dd = d.format(datez!);
      date.text = dd.toString();
      // String s = "${widget.item["account_currency"]}";
      // addData(s.substring(0, s.indexOf(" ")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    total_paid.text = total1.round().toString();
    String currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          '${item["creditor_name"] ?? "Debt"}',
          style: TextStyle(fontSize: width * .06, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Visibility(
            visible: !widget.archived,
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  enable = !enable;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .04,
            vertical: height * .02,
          ),
          child: Form(
            key: key,
            child: Column(
              children: [
                Text(
                  "${item["secured_against"] ?? item["alias"]}: Mortgage",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: Theme.of(context).primaryColor,
                    fontSize: width * .05,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '(view & edit)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: Theme.of(context).primaryColor,
                    fontSize: width * .035,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: height * .03),
                Container(),
                SizedBox(height: height * .005),
                Container(),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Details of Property:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),

                TextFormField(
                  enabled: enable,
                  // enabled: false,
                  controller: details,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(fontSize: width * .03),
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                ),
                Container(),

                // description == null
                //     ?
                SizedBox(height: height * .03),
                Container(
                  padding: EdgeInsets.only(
                    left: width * .015,
                    right: width * .015,
                    top: height * .005,
                  ),
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .01),
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      focusColor: Theme.of(context).primaryColor,
                      value: description,
                      items: _mortDesc,
                      onChanged: (subval) {
                        setState(() {
                          description = subval!;
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                ),
                // : Container(),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Opening Balance:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  enabled: enable,
                  controller: baseline,
                  inputFormatters: [amountValidator],
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    prefixText: currency,
                    filled: true,
                    fillColor: Colors.white,
                    prefixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: TextStyle(fontSize: width * .03),
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current Balance:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  enabled: enable,
                  controller: current,
                  inputFormatters: [amountValidator],
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    prefixText: currency,
                    prefixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(fontSize: width * .03),
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null &&
                        (double.tryParse(value) ?? 0.0) >
                            (double.tryParse(baseline.text) ?? 0.0)) {
                      return 'Current balance cannot be greater than Opening balance.';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: enable
                      ? Row(
                          children: <Widget>[
                            Text(
                              "Paid Off",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Checkbox(
                              value: _paidOff,
                              checkColor: Colors.red,
                              focusColor: Colors.white,
                              onChanged: (bool? value) {
                                if (enable) {
                                  setState(() => _paidOff = !_paidOff);
                                }
                              },
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Periodic Payment Amount:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  enabled: enable,
                  controller: period,
                  inputFormatters: [amountValidator],
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    prefixText: currency,
                    prefixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Interest Rate:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  enabled: enable,
                  controller: interest,
                  inputFormatters: [amountValidator],
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    suffixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: "%",
                    hintStyle: TextStyle(fontSize: width * .03),
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    final double? interestValue = double.tryParse(value);
                    if (interestValue == null || interestValue > 100) {
                      return 'Interest Rate value must be less than or equal to 100';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Paid till Date:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  enabled: false,
                  controller: total_paid,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    prefix: Text(currency),
                    prefixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(fontSize: width * .03),
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payoff Strategy:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  controller: extra,
                  enabled: enable,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: width * .03),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(width * .03),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payoff Target Date:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    showDatePicker(
                      context: context,
                      initialDate: datez ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    ).then((value) {
                      setState(() {
                        if (value != null) {
                          dateDB = DateFormat('yyyy-MM-dd').format(value);
                          var d = DateFormat.yMMMMd();
                          var dd = d.format(value);
                          date.text = dd;
                          endd = value;
                        }
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  child: TextFormField(
                    controller: date,
                    enabled: false,
                    // inputFormatters: [
                    //   TextInputFormatter.withFunction(
                    //       (oldValue, newValue) => null)
                    // ],
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.date_range,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: TextStyle(fontSize: width * .03),
                      contentPadding: EdgeInsets.only(
                        left: width * .013,
                        right: width * .03,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: height * .03),
                Visibility(
                  visible: !enable && !widget.archived && widget.zeroBalance,
                  child: ElevatedButton(
                    onPressed: widget.archived
                        ? () {
                            // dialogBox.options(context, "Confirm Add Account",
                            //     "Are you sure you want to add this account? (You will be able to view the account in Mortgage)",
                            //     () {
                            //   addorremove();
                            // });
                          }
                        : () {
                            dialogBox.options(
                              context,
                              "Confirm Remove Account",
                              "Are you sure you want to remove this account? (You will be able view the account under Archive section)",
                              () {
                                addorremove();
                              },
                            );
                            // dropdown();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * .01),
                      ),
                    ),
                    child: Text(
                      "Remove Account",
                      style: TextStyle(
                        // decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !enable,
                  child: SizedBox(
                    height: height * .03,
                    child: const Divider(thickness: 2),
                  ),
                ),
                Visibility(
                  visible: !enable,
                  child: Center(
                    child: Text(
                      "Historical Balances",
                      style: TextStyle(
                        // decoration: TextDecoration.underline,
                        fontSize: width * .06,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * .03),
                Visibility(
                  visible: !enable,
                  child: Container(
                    height: height * .4,
                    padding: const EdgeInsets.all(8),
                    child: charts.BarChart(
                      _seriesData,
                      animate: true,
                      vertical: true,
                      barRendererDecorator: charts.BarLabelDecorator<String>(),
                      animationDuration: const Duration(milliseconds: 1000),
                    ),
                  ),
                ),
                SizedBox(height: height * .01),
                //     Visibility(
                //       visible: !enable,
                //       child: ElevatedButton(
                //         onPressed: () {},
                //          style: ElevatedButton.styleFrom(
                //   primary: Theme.of(context).primaryColor,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(width * .01)),
                // ),
                //         child: Text("View More",
                //             style: TextStyle(
                //                 // decoration: TextDecoration.underline,
                //                 color: Colors.white,
                //                 fontSize: width * .035,
                //                 fontWeight: FontWeight.w400)),
                //       ),
                //     ),
                Visibility(
                  visible: enable,
                  child: ElevatedButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        update();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor, // ✅ Replaces `primary`
                      foregroundColor: Colors.white, // ✅ Replaces `onPrimary`
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // child: Text("${widget.item}")),
    );
  }

  addorremove() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    var urlr = "$baseUrl/app/360/tiles";

    var url = widget.archived
        ? "$baseUrl/app/360/mortgage?header=uiwjsbjsbnjmsxnjsxbnsjxbsxhjndghbdgjvhgcghdchm&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.item["id"]}"
        : "$baseUrl/app/360/mortgage?header=uiwjsbjsbnjmsxnjsxbnsjxbsxhjndghbdgjvhgcghdchm&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.item["id"]}";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      try {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);

        mortgage();
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
    }
    //
  }

  bool _isLoading = false; // Track loading state

  update() async {
    if (_isLoading) return; // If already loading, prevent further action
    _isLoading = true; // Set loading state to true

    FocusScope.of(context).requestFocus(FocusNode());

    if (description == "-Select-") {
      dialogBox.information(
        context,
        "Status",
        "Please select a description of mortgage",
      );
      _isLoading = false; // Reset loading state
      return;
    }

    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      _isLoading = false; // Reset loading state
      return;
    });

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async =>
              false, // Prevent back button from dismissing the dialog
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
    var id = widget.item["id"];

    var url = Uri.parse("$baseUrl/app/360/mortgage/$id");
    var urlr = "$baseUrl/app/360/tiles";

    Map<String, dynamic> data = {
      "detail": details.text,
      "current": current.text,
      "current_balance": current.text,
      "open_balance": baseline.text,
      "repayment": period.text,
      // "interest_rate": interest.text,
      "interest": interest.text,
      "target_date": dateDB,
      "extra": extra.text,
      "pay_strategy": extra.text,
      "mortgage_paid": _paidOff,
      "description": description,
      "creditor": name.text,
      // "creditor_name": name.text,
      // "secure_against": 'Others',
    };

    if (widget.seven) {
      data["seveng"] = "pakmamkanknmjkmnzkmnjmnd";
      data["creditor"] = name.text;
    }

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    try {
      var response = await http.post(
        url,
        body: jsonEncode(data),
        headers: {
          "Authorization": 'Bearer $token',
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);
        Fluttertoast.showToast(
          backgroundColor: const Color(0xff00B050),
          msg: 'Mortgage Information updated Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        mortgage();
      } else {
        Fluttertoast.showToast(
          msg: '${response.statusCode} Something went wrong',
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong: $e');
    } finally {
      timer.cancel();
      Navigator.pop(context); // Dismiss the loading dialog
      _isLoading = false; // Reset loading state
    }
  }

  mortgage() async {
    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/mortgage";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      var mapList = response.data["mortgages"];
      var mapListLite = response.data["mortgages_detail"];
      var seveng = response.data["seveng"];
      if (widget.archived) {
        Navigator.pop(context);
      }
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mortgagedetails(mapList, mapListLite, seveng),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
