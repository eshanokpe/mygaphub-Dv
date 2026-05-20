import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:GapHub/models/chartsmodel.dart';
import 'dart:async';
import 'package:GapHub/models/analyticsinfo.dart';
import 'liabilitydetails.dart';

class Liabilityitem extends StatefulWidget {
  final Map item;
  final bool seven;
  final bool bespokes;
  final bool archived;
  final bool zeroBalance;

  const Liabilityitem({
    super.key,
    required this.item,
    required this.seven,
    required this.bespokes,
    this.archived = false,
    this.zeroBalance = false,
  });
  @override
  _LiabilityitemState createState() => _LiabilityitemState();
}

class _LiabilityitemState extends State<Liabilityitem> {
  final List<charts.Series<Kpi, String>> _seriesData = [];
  Dio dio = Dio();
  bool? show;
  addData(currency, Map item) {
    List<Kpi> data = [];

    for (var i = 0; i < item["labels"].length; i++) {
      data.add(
        Kpi(
          kpi: Text("${item["labels"][i]}"),
          value: double.parse(item["values"][i].toString()),
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
        id: 'Expenditure',
        domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Kpi kpi, _) =>
            '$currency${(kpi.value).toInt()}'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
      ),
    );
  }

  var key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController baseline = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController period = TextEditingController();
  TextEditingController interest = TextEditingController();
  TextEditingController total_paid = TextEditingController();
  TextEditingController extra = TextEditingController();

  TextEditingController date = TextEditingController();
  DialogBox dialogBox = DialogBox();
  String dateDB = "";
  DateTime? endd;
  DateTime? datez;
  bool enable = false;
  final bool _paidOff = false;

  static const creditTypeList = <String>[
    '-Select-',
    'Loans',
    'Credit Card',
    'Secured Loans',
    'Overdraft',
    'Friends and Family',
    'Delayed Payment',
    'Hire Purchase',
    'Unsecured Loans',
    'Others',
  ];

  int _radioValue = 1;
  String creditType = '-Select-';
  final List<DropdownMenuItem<String>> _creditorType = creditTypeList
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();
  @override
  void initState() {
    super.initState();
    var item = widget.item;
    _radioValue = int.parse(item["automated"]);
    creditType = item["account_type"];
    String currency = item["currency"];
    addData(currency, item["chart"]);
    name.text = item["creditor_name"] ?? "";
    details.text = item["account_details"] ?? "";
    item["baseline"] == null
        ? baseline.text = "0"
        : baseline.text = item["baseline"].toString();
    item["current"] == null
        ? current.text = "0"
        : current.text = item["current"].toString();
    item["extra"] == null
        ? extra.text = ""
        : extra.text = item["extra"].toString();
    item["periodical_pay"] == null
        ? period.text = "0"
        : period.text = item["periodical_pay"].toString();
    item["interest_rate"] == null
        ? interest.text = "0"
        : interest.text = item["interest_rate"].toString();
    item["account_location"] == null
        ? location.text = ""
        : location.text = item["account_location"].toString();
    total_paid.text =
        (int.parse(item["baseline"].toString()) -
                int.parse(item["current"].toString()))
            .toString();

    show = item["isAnalytics"].toString() == "1" ? true : false;

    if (item["target_date"] != null) {
      dateDB = item["target_date"];

      datez = DateTime.parse(item["target_date"]);
      var d = DateFormat.yMMMMd();
      var dd = d.format(datez!);
      date.text = dd.toString();
    } else {
      datez = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    String currency = item["currency"];
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
          "${item["creditor_name"]}",
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
                  "${item["account_type"]}: Liability",
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

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: width * .045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * .005),
                TextFormField(
                  enabled: enable,
                  controller: details,
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

                // Visibility(
                //   visible: !widget.seven,
                //   child: Column(
                //     children: [
                //       SizedBox(
                //         height: height * .03,
                //       ),
                //       Align(
                //         alignment: Alignment.centerLeft,
                //         child: Text(
                //           'What type of credit account is this:',
                //           style: TextStyle(
                //               fontSize: width * .045,
                //               color: Colors.black,
                //               fontWeight: FontWeight.w700),
                //         ),
                //       ),
                //       SizedBox(
                //         height: height * .005,
                //       ),
                //       Container(
                //         padding: EdgeInsets.only(
                //             left: width * .015, right: width * .015),
                //         width: width,
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(width * .01),
                //             color: Colors.white,
                //             border: Border.all()),
                //         child: DropdownButtonHideUnderline(
                //           child: DropdownButton<String>(
                //               focusColor: Theme.of(context).primaryColor,
                //               value: creditType,
                //               items: _creditorType,
                //               onChanged: (subval) {
                //                 setState(() {
                //                   creditType = subval;
                //                 });
                //                 FocusScope.of(context).requestFocus(FocusNode());
                //               }),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: height * .03),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Currency Conversion mode',
                    style: TextStyle(
                      fontSize: width * .045,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: _radioValue,
                      onChanged: (int? val) {
                        setState(() {
                          _radioValue = val!;
                        });
                      },
                    ),
                    Text('Automated', style: const TextStyle(fontSize: 14.0)),
                    Radio(
                      value: 0,
                      groupValue: _radioValue,
                      onChanged: (int? val) {
                        setState(() {
                          _radioValue = val!;
                        });
                      },
                    ),
                    Text('Manual', style: const TextStyle(fontSize: 14.0)),
                  ],
                ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    final double? currentBalance = double.tryParse(value);
                    final double? openingBalance = double.tryParse(
                      baseline.text,
                    );

                    if (currentBalance == null || openingBalance == null) {
                      return 'Invalid number format';
                    }

                    if (currentBalance > openingBalance) {
                      return 'Current balance cannot be greater than Opening balance.';
                    }

                    return null;
                  },
                ),
                /* Container(
                    width: double.infinity,
                    child: Row(children: [
                      Text(
                        "Paid Off",
                      ),
                      Checkbox(
                          value: _paidOff,
                          activeColor: Colors.red,
                          checkColor: Colors.red,
                          focusColor: Colors.black,
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.black54),
                          onChanged: (bool value) => {
                                setState(() => enable ? _paidOff = !_paidOff : 0)
                              }),
                    ])), */
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
                    filled: true,
                    fillColor: Colors.white,
                    prefixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
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
                    suffixText: "%",
                    filled: true,
                    fillColor: Colors.white,
                    suffixStyle: TextStyle(
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
                    prefix: Text("$currency "),
                    prefixStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
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
                  enabled: enable,
                  controller: extra,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: width * .03),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.only(
                      left: width * .013,
                      right: width * .03,
                    ),
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
                      initialDate: datez,
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
                    enabled: false,
                    controller: date,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Icon(
                        Icons.date_range,
                        color: Theme.of(context).primaryColor,
                      ),
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
                  visible: !widget.seven,
                  child: Row(
                    children: [
                      Text(
                        "Show account in Analytics",
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Switch(
                        activeThumbColor: Theme.of(context).primaryColor,
                        value: show!,
                        inactiveTrackColor: Theme.of(context).primaryColor,
                        onChanged: enable
                            ? (val) {
                                setState(() {
                                  show = val;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * .01),
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
                              "Are you sure you want to remove this account? (You will be able to view the account under Archive section)",
                              () {
                                addorremove();
                              },
                            );
                            // dropdown();
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.grey[400],
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
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
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
                Visibility(
                  visible: enable,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * .01),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        update();
                      }
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        // decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontSize: width * .04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Visibility(
                //   visible: !enable,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       primary: Theme.of(context).primaryColor,
                //     ),
                //     onPressed: () {},
                //     child: Text("View More",
                //         style: TextStyle(
                //             // decoration: TextDecoration.underline,
                //             color: Colors.white,
                //             fontSize: width * .035,
                //             fontWeight: FontWeight.w400)),
                //   ),
                // ),
                SizedBox(width: width * .03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  update() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (creditType == "-Select-") {
      dialogBox.information(
        context,
        'Status',
        "Please select a type of Credit Account",
      );
      return;
    }
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Saving");
    var id = widget.item["id"];
    var urlr = "$baseUrl/app/360/tiles";
    var url7G = Uri.parse('$baseUrl/app/seveng');
    print("idd:$id");
    var url = Uri.parse("$baseUrl/app/360/liability/$id");
    Map data = {
      "period_pay": period.text,
      "baseline": baseline.text,
      "current": current.text,
      "interest": interest.text,
      "lia_detail": details.text,
      "target_date": dateDB,
      "pay_startegy": extra.text,
      //"paid_off": _paidOff,
      "automated_rate": "$_radioValue",
    };
    if (widget.seven) {
      data["creditor"] = name.text;
      data["seveng"] = "pakmamkanknmjkmnzkmnjmnd";
      data["credit_type"] = creditType;
    }
    if (!widget.seven) {
      data["analytics"] = show.toString();
    }
    if (widget.bespokes) {
      data["account"] = widget.item["account_header"];
      data["bespoke"] = widget.item["id"].toString();
    }
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.post(
      url,
      body: data,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 400) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: response.body,
        toastLength: Toast.LENGTH_LONG,
      );
      timer.cancel();
      return;
    }

    if (response.statusCode == 200) {
      try {
        final response4 = await http.get(
          url7G,
          headers: {"Authorization": 'Bearer $token'},
        );

        Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
          jsonDecode(response4.body),
        );
        context.read<Providers>().setSevenGee(sevengeemodel);
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);

        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Liabilities Information Updated successfully',
        );
        timer.cancel();
        liability();
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, "Status", "An error occured");
    }
  }

  addorremove() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url7G = Uri.parse('$baseUrl/app/seveng');
    String a = widget.bespokes ? "&kpi=account_header" : "";

    var url = widget.archived
        ? "$baseUrl/app/360/liability?header=ajnkxbjknjsxnbjjkaznjknajhnbjbdhjb&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.item["id"]}$a"
        : "$baseUrl/app/360/liability?header=ajnkxbjknjsxnbjjkaznjknajhnbjbdhjb&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.item["id"]}$a";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      try {
        final response4 = await http.get(
          url7G,
          headers: {"Authorization": 'Bearer $token'},
        );
        // print("error: " + response4.statusCode.toString());

        Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
          jsonDecode(response4.body),
        );
        context.read<Providers>().setSevenGee(sevengeemodel);

        liability();
        Fluttertoast.showToast(
          msg: widget.archived
              ? "Account unarchived successfully"
              : "Account archived successfully",
        );
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }

  liability() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Loading");
    var url = "$baseUrl/app/360/liability";
    var url2 = Uri.parse('$baseUrl/app/seveng/edit');

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    var response2 = await http.get(
      url2,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200 && response2.statusCode == 200) {
      timer.cancel();
      var mapList = response.data["liabilities"];
      List seveng = response.data["seveng"];
      var mapListLite = response.data["liabilities_detail"];
      var isAllocated = response.data["audit"]["is_allocated"];
      var bespokes = response.data["bespokes"];
      var creditCurrent = "0";
      var current = jsonDecode(response2.body);
      // Analyticsinfo analyticsinfo =
      //     Analyticsinfo.fromJson(jsonDecode(response2.body));
      creditCurrent = current["data"]["current"].toString();
      num total = 0;
      List real = [];
      if (seveng.isNotEmpty) {
        List<num> a = seveng
            .map((e) => num.parse(e["current"].toString()))
            .toList();

        for (var item in a) {
          real.add(int.parse(item.toString()));
        }

        for (var item in a) {
          total = total + item;
        }
      }
      if (widget.archived) {
        Navigator.pop(context);
      }
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      print('creditCurrent:$creditCurrent');

      if (isAllocated.toString() == "1") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (creditCurrent == 'null' || creditCurrent.toString().isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (int.parse(creditCurrent.toString()) == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      } else if (total != int.parse(creditCurrent.toString())) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Threesixty(
              unallocated: true,
              data: seveng,
              balance: seveng.isEmpty
                  ? (int.tryParse(creditCurrent) ?? 0) // Ensure non-null value
                  : ((int.tryParse(creditCurrent) ?? 0) - (total ?? 0))
                        .toInt(), // Ensure total is not null and convert to int
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Liabilitydetails(
              liabilityData: mapList,
              liabilityDataLite: mapListLite,
              seveng: seveng,
              bespokes: bespokes,
            ),
          ),
        );
      }
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }
}
