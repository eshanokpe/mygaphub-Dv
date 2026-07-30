import 'package:GapHub/widgets/bottomnav.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/cash/cashdetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cashitem extends StatefulWidget {
  final Map item;
  final bool seven;
  final bool bespokes;
  final bool archived;
  const Cashitem({
    super.key,
    required this.item,
    required this.seven,
    required this.bespokes,
    this.archived = false,
  });
  @override
  _CashitemState createState() => _CashitemState();
}

class _CashitemState extends State<Cashitem> {
  Dio dio = Dio();
  bool? show;
  final List<charts.Series<Kpi, String>> _seriesData = [];
  addData(currency, Map item, bool seven) {
    List<Kpi> data = [];

    for (var i = 0; i < item["labels"].length; i++) {
      data.add(
        Kpi(
          kpi: Text("${item["labels"][i]}"),
          value: double.parse((item["values"][i] ?? 0.0).toString()),
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

  String dateDB = "";
  DateTime? endd;
  var key = GlobalKey<FormState>();
  TextEditingController details = TextEditingController();
  TextEditingController target = TextEditingController();
  TextEditingController current = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController extra = TextEditingController();

  DialogBox dialogBox = DialogBox();
  static const units1 = <String>[
    'Savings Account',
    'Term Deposit',
    'Fixed Deposit',
    'Others',
  ];
  String? accountType;
  final List<DropdownMenuItem<String>> accountTypeList = units1
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

  static const units2 = <String>[
    '-Select-',
    'Investment Pool Fund',
    'Rainy-Day Fund',
    'Personal Project Fund',
    'Family Project Fund',
    'Holiday Fund',
    'Car Purchase Fund',
    'Children Education Fund',
    'Home Purchase Savings',
    'Others',
  ];
  String purpose = '-Select-';
  final List<DropdownMenuItem<String>> purposeList = units2
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
  bool enable = false;
  int _radioValue = 1;

  var datez;
  @override
  void initState() {
    super.initState();
    var item = widget.item;
    _radioValue = int.parse(item["automated"] ?? '1');

    // if (!widget.seven) purpose = item["account_purpose"];
    if (!widget.seven) purpose = item["account_purpose"];
    var currency = widget.seven ? item["account_currency"] : item["currency"];
    addData(currency, widget.item["chart"], widget.seven);
    accountType = (item["account_type"]?.toString() ?? "Others");
    details.text = (item["account_details"]?.toString() ?? "");
    target.text = (item["target"]?.toString() ?? "");

    current.text = (item["current"]?.toString() ?? "");
    extra.text = (item["extra"]?.toString() ?? "");
    location.text = (item["account_location"]?.toString() ?? "");
    show = item["isAnalytics"].toString() == "1" ? true : false;

    if (item["target_date"] != null) {
      dateDB = item["target_date"];
      datez = DateTime.parse(item["target_date"]);
      var d = DateFormat.yMMMMd();
      var dd = d.format(datez);
      date.text = dd.toString();
    } else {
      datez = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    var currency = item["currency"];
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
          '${item["account_name"]}',
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
          child: Column(
            children: [
              Text(
                "${item["account_purpose"]}: Cash",
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
                    fontSize: width * .040,
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
                    onChanged: (val) {
                      setState(() {
                        _radioValue = val as int;
                      });
                    },
                  ),
                  Text('Automated', style: const TextStyle(fontSize: 14.0)),
                  Radio(
                    value: 0,
                    groupValue: _radioValue,
                    onChanged: (val) {
                      setState(() {
                        _radioValue = val as int;
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
                  'Target Amount:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: target,
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
                  'Type of Holding Account:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              Container(
                padding: EdgeInsets.only(
                  left: width * .015,
                  right: width * .015,
                ),
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * .01),
                  color: Colors.white,
                  border: Border.all(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    focusColor: Theme.of(context).primaryColor,
                    value: accountType,
                    items: accountTypeList,
                    onChanged: (subval) {
                      setState(() {
                        accountType = subval as String;
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Visibility(
                visible: !widget.seven && !widget.bespokes,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Purpose of the Funds:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    Container(
                      padding: EdgeInsets.only(
                        left: width * .015,
                        right: width * .015,
                      ),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * .01),
                        color: Colors.white,
                        border: Border.all(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          focusColor: Theme.of(context).primaryColor,
                          value: purpose,
                          items: purposeList,
                          onChanged: (subval) {
                            setState(() {
                              purpose = subval as String;
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: height * .03),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Target Date:',
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
                    suffixIcon: Icon(
                      Icons.date_range,
                      color: Theme.of(context).primaryColor,
                    ),
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
              ),
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Location of the Funds:',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: location,
                keyboardType: TextInputType.name,
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
                  'Account Alias:',
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
                      inactiveTrackColor: Theme.of(context).primaryColor,
                      value: show!,
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
                visible: !enable,
                child: ElevatedButton(
                  onPressed: widget.archived
                      ? () {
                          dialogBox.options(
                            context,
                            "Confirm Add Account",
                            "Are you sure you want to add this account? (You will be able to view the account in Cash)",
                            () {
                              addorremove();
                            },
                          );
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
                    elevation: 5,
                    backgroundColor: Colors.grey[400],
                  ),
                  child: Text(
                    widget.archived ? "Restore Account" : "Remove Account",
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
                    update();
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
              // Text('${widget.item}')
            ],
          ),
        ),
      ),
    );
  }

  update() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Saving");
    var id = widget.item["id"];
    var url7G = Uri.parse('$baseUrl/app/seveng');
    var url = Uri.parse("$baseUrl/app/360/cash/$id");
    var urlSnapshot = Uri.parse('$baseUrl/app/snapshot');
    var urlr = "$baseUrl/app/360/tiles";

    Map data = {
      "current": current.text,
      "target": target.text,
      "details": details.text,
      "target_date": dateDB,
      "type": accountType,
      "account_location": location.text,
      "alias": extra.text,
    };
    if (!widget.seven) {
      data["analytics"] = show.toString();
      data["automated_rate"] = "$_radioValue";
    }
    if (widget.seven) {
      data["seveng"] = widget.item["account_name"] == "Alpha"
          ? "alpcaksnksnkndkkmkdnkandnsmjmn"
          : widget.item["account_name"] == "Beta"
          ? "betpcaksnksnkndkkmkdnkanmhahbdjb"
          : "edupcaksnksmkdnkjnkndkkahnjn";
    }
    if (!widget.seven || widget.bespokes) {
      data["purpose"] = purpose;
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

        final response3 = await http.get(
          urlSnapshot,
          headers: {"Authorization": 'Bearer $token'},
        );

        Snapshotmodel snapshotmodel = Snapshotmodel.fromJson(
          jsonDecode(response3.body),
        );
        context.read<Providers>().setSnapshot(snapshotmodel);
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);
        Navigator.pop(context);

        cash();
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();

      Navigator.pop(context);
    }
    // Navigator.pop(context);
  }

  addorremove() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    String a = widget.bespokes ? "&kpi=account_header" : "";
    var url7G = Uri.parse('$baseUrl/app/seveng');
    var urlr = "$baseUrl/app/360/tiles";

    var url = widget.archived
        ? "$baseUrl/app/360/cash?header=cakjsnodidjnjksnjbnxdjdbndjcbdbncfjn&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.item["id"]}$a"
        : "$baseUrl/app/360/cash?header=cakjsnodidjnjksnjbnxdjdbndjcbdbncfjn&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.item["id"]}$a";

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

        Sevengeemodel sevengeemodel = Sevengeemodel.fromJson(
          jsonDecode(response4.body),
        );
        context.read<Providers>().setSevenGee(sevengeemodel);
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);

        cash();
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
      Navigator.pop(context);
      timer.cancel();
    }
  }

  cash() async {
    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/360/cash";

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      var mapList = response.data["cash"];
      var seveng = response.data["seveng"];
      var mapListLite = response.data["cash_detail"];
      var bespokes = response.data["bespokes"];

      if (widget.archived) {
        Navigator.pop(context);
      }
      Navigator.pop(context);
      Navigator.pop(context);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Cashdetails(mapList, mapListLite, seveng, bespokes),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
