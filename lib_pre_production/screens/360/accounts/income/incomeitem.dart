import 'package:GapHub/screens/360/accounts/income/incomedetails.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:dio/dio.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:GapHub/screens/portfolio/braiditem.dart';
import 'package:GapHub/screens/portfolio/financial.dart';

import 'nonPorfolioIncome.dart';

class Incomeitem extends StatefulWidget {
  final Map data;
  final bool archived;
  const Incomeitem({super.key, required this.data, this.archived = false});
  @override
  _IncomeitemState createState() => _IncomeitemState();
}

class _IncomeitemState extends State<Incomeitem> {
  final List<charts.Series<Kpi, String>> _seriesData = [];
  Dio dio = Dio();
  bool? show;
  DialogBox dialogBox = DialogBox();
  String dateDB = "";
  DateTime? endd;
  DateTime? datez;
  bool enable = false;
  var associates = [];
  var mapAssets = [];
  var idA = 0;
  bool nonPortEdit = false;

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
  TextEditingController value = TextEditingController();
  TextEditingController asset = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController dateNonPort = TextEditingController();
  TextEditingController valueNonPort = TextEditingController();
  TextEditingController tithepaidvalue = TextEditingController();
  TextEditingController taxespaidvalue = TextEditingController();
  TextEditingController othersvalue = TextEditingController();
  TextEditingController detailsNonPort = TextEditingController();

  String associate = '-Select-';

  static const subUnits1 = <String>[
    '-Select-',
    'Weekly',
    'Monthly',
    'Quaterly',
    'Annually',
    'One-Off',
    'Others',
  ];
  String frequency = '-Select-';
  final List<DropdownMenuItem<String>> frequencyList = subUnits1
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

  static const subUnits3 = <String>[
    'Asset Portfolio Income',
    'Non-Portfolio Income',
  ];
  String type = '';
  final List<DropdownMenuItem<String>> typeList = subUnits3
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
  int? ddid;
  @override
  void initState() {
    super.initState();
    var item = widget.data;
    associates = context.read<Providers>().assets;
    mapAssets = context.read<Providers>().mapAsset;

    if (widget.data["income_type"].toString() == "portfolio") {
      var idpa = widget.data["portfolio_asset_id"];
      ddid = mapAssets.indexWhere((element) => element["id"] == idpa);
      associate = associates[ddid! + 1];
    }
    addData(item["currency"], item["chart"]);

    type = widget.data["income_type"].toString() == "portfolio"
        ? 'Asset Portfolio Income'
        : 'Non-Portfolio Income';
    value.text = widget.data["amount"].toString() ?? "";
    frequency = widget.data["income_frequency"];
    if (widget.data["income_date"] != null) {
      dateDB = widget.data["income_date"];
      datez = DateTime.parse(widget.data["income_date"]);
      var d = DateFormat.yMMMMd();
      var dd = d.format(datez!);
      date.text = dd.toString();
    } else {
      datez = DateTime.now();
      var d = DateFormat.yMMMMd();

      var dd = d.format(datez!);
      date.text = dd.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    String currency = data["currency"];
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
          "${data["income_name"]}",
          style: TextStyle(fontSize: width * .05, fontWeight: FontWeight.w700),
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
        child: nonPortEdit
            ? Container(
                padding: EdgeInsets.only(left: width * .02, right: width * .02),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * .04,
                        vertical: height * .02,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${data["income_name"]} - ${data["channel"]}: Income",
                            style: TextStyle(
                              fontSize: width * .05,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '(view & edit)',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: width * .035,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      heightFactor: height * .005,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.data["income_type"].toString() !=
                              "portfolio") {
                            setState(() => nonPortEdit = !nonPortEdit);
                          } else {
                            [
                                  null,
                                  "",
                                ].contains(widget.data["portfolio_asset_id"])
                                ? Fluttertoast.showToast(
                                    msg: "Portfolio not identified",
                                    backgroundColor: Colors.red,
                                  )
                                : toBraidItem(
                                    widget.data["portfolio_asset_id"],
                                  );
                          }
                        },
                        child: const Text(
                          "Record Monthly Income",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Period Income was Earned:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());

                        showMonthPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ).then((value) {
                          setState(() {
                            if (value != null) {
                              dateDB = DateFormat('yyyy-MM').format(value);

                              checkDateAvail(dateDB, widget.data["id"]);
                              // print(widget.data["id"]);
                              var d = DateFormat.yMMMM();
                              var dd = d.format(value);
                              dateNonPort.text = dd;
                              // endd = value;
                            }
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                      },
                      child: TextFormField(
                        enabled: false,
                        keyboardType: TextInputType.number,
                        controller: dateNonPort,
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
                          contentPadding: EdgeInsets.only(
                            left: width * .013,
                            right: width * .03,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Amount Earned
                    SizedBox(height: height * .02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Amount Earned:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      // controller: value,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.number,
                      controller: valueNonPort,
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
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    // Tithe Paid
                    SizedBox(height: height * .02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ' Tithe Paid:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      // controller: value,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.number,
                      controller: tithepaidvalue,
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
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    // Taxes Paid
                    SizedBox(height: height * .02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Taxes Paid:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      // controller: value,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.number,
                      controller: taxespaidvalue,
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
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Others:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      // controller: value,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.number,
                      controller: othersvalue,
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
                        contentPadding: EdgeInsets.only(
                          left: width * .013,
                          right: width * .03,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: height * .02),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Additional Comment:',
                        style: TextStyle(
                          fontSize: width * .045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: height * .005),
                    TextFormField(
                      controller: detailsNonPort,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: width * .04,
                          fontWeight: FontWeight.w400,
                        ),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(width * .03),
                        ),
                      ),
                    ),
                    SizedBox(height: height * .03),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () {
                        var id = widget.data["id"];
                        print('incomeId:$id');
                        // if ([null, ""].contains(dateNonPort.text) ||
                        //     [null, ""].contains(valueNonPort.text) ||
                        //     [null, ""].contains(detailsNonPort.text)) {
                        //   dialogBox.information(context, "Status",
                        //       "Please provide all necessary details");

                        //   return;
                        // }

                        nowPostUpdate(widget.data["id"]);
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: width * .045,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .04,
                    vertical: height * .02,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${data["income_name"]} - ${data["channel"]}: Income",
                        style: TextStyle(
                          fontSize: width * .05,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '(view & edit)',
                        style: TextStyle(
                          // color: Theme.of(context).primaryColor,
                          fontSize: width * .035,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Center(
                        heightFactor: height * .005,
                        child: GestureDetector(
                          onTap: () {
                            if (widget.data["income_type"].toString() !=
                                "portfolio") {
                              setState(() => nonPortEdit = !nonPortEdit);
                            } else {
                              [
                                    null,
                                    "",
                                  ].contains(widget.data["portfolio_asset_id"])
                                  ? Fluttertoast.showToast(
                                      msg: "Portfolio not identified",
                                      backgroundColor: Colors.red,
                                    )
                                  : toBraidItem(
                                      widget.data["portfolio_asset_id"],
                                    );
                            }
                          },
                          child: const Text(
                            "Record Monthly Income",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Type of Income',
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
                            value: type,
                            items: typeList,
                            onChanged: (subval) {
                              setState(() {
                                type = subval as String;
                                if (subval == "Non-Portfolio Income") {}
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Income Value',
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .005),
                      TextFormField(
                        // enabled: type != 'Asset Portfolio Income' && enable,
                        enabled: enable,
                        controller: value,
                        textCapitalization: TextCapitalization.sentences,
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
                          'Frequency of Income',
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
                            value: frequency,
                            items: frequencyList,
                            onChanged: (subval) {
                              setState(() {
                                frequency = subval as String;
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: type == 'Asset Portfolio Income',
                        child: Column(
                          children: [
                            SizedBox(height: height * .03),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Associated Asset',
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
                                borderRadius: BorderRadius.circular(
                                  width * .01,
                                ),
                                color: Colors.white,
                                border: Border.all(),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  focusColor: Theme.of(context).primaryColor,
                                  value: associate,
                                  items: associates.map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (subval) {
                                    setState(() {
                                      int index = associates.indexOf(subval);
                                      if (index == 0) {
                                      } else {
                                        value.text =
                                            mapAssets[index - 1]["monthly_roi"]
                                                .toString();
                                        idA = int.parse(
                                          mapAssets[index - 1]["id"].toString(),
                                        );
                                      }
                                      associate = subval as String;
                                    });
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .03),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Last Date of Income',
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
                                DateTime today = DateTime.now();
                                if (value.isAfter(today)) {
                                  // Show error message if the selected date is after today
                                  dialogBox.information(
                                    context,
                                    'Error',
                                    'Please select a date before today.',
                                  );
                                  return;
                                }

                                // Proceed with setting the selected date
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
                            contentPadding: EdgeInsets.only(
                              left: width * .013,
                              right: width * .03,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: height * .02),
                      Visibility(
                        visible: !enable,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Colors.grey[400],
                          ),
                          onPressed: widget.archived
                              ? () {
                                  dialogBox.options(
                                    context,
                                    "Confirm Add Account",
                                    "Are you sure you want to add this account? (You will be able to view the account in Mortgage)",
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
                          child: Text(
                            widget.archived
                                ? "Restore Account"
                                : "Remove Account",
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
                            barRendererDecorator:
                                charts.BarLabelDecorator<String>(),
                            animationDuration: const Duration(
                              milliseconds: 1000,
                            ),
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
                      Visibility(
                        visible: !enable,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () async {
                            var incomeType = widget.data["income_type"]
                                .toString();
                            print('income_type:$incomeType');
                            print('${data["id"]}');
                            if (widget.data["income_type"].toString() ==
                                'non_portfolio') {
                              var url = Uri.parse(
                                "$baseUrl/app/360/non_portfolio/${data["id"]}",
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var token = prefs.getString('tokenDB');

                              var response = await http.get(
                                url,
                                headers: {"Authorization": 'Bearer $token'},
                              );
                              // print(response.statusCode);
                              if (response.statusCode == 200) {
                                var body = jsonDecode(response.body);
                                //print('body:${body['data']}');
                                context.read<Providers>().setnonporfolioData(
                                  body['data'],
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NonPorfolioIncome(data: body['data']),
                                  ),
                                );
                              } else {
                                print('Error');
                              }
                            } else {
                              if (widget.data["income_type"].toString() ==
                                  "portfolio") {
                                goToFinancialChart(
                                  widget.data["portfolio_asset_id"].toString(),
                                  widget.data["channel"],
                                );
                              }
                            }
                            // if (widget.data["income_type"].toString() ==
                            //     "portfolio") {
                            //   goToFinancialChart(
                            //       widget.data["portfolio_asset_id"]
                            //           .toString(),
                            //       widget.data["channel"]);
                            // }
                          },
                          child: Text(
                            "View More",
                            style: TextStyle(
                              // decoration: TextDecoration.underline,
                              color: Colors.white,
                              fontSize: width * .035,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * .03),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  goToFinancialChart(String id, String type) async {
    var assetType = type.toLowerCase();
    print('assetType:$assetType');
    print('assetType:$id');
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/portfolio/$assetType/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    // print(response.statusCode);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Financial(
            data: jsonDecode(response.body),
            type: assetType,
            id: id,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }

  toBraidItem(int id) async {
    var type = widget.data["channel"].toLowerCase();
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    // print(response.statusCode);
    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Braiditem(data: jsonDecode(response.body)),
        ),
      );
    } else {
      timer.cancel();
      EasyLoading.dismiss();
      switch (response.statusCode) {
        case 400:
          Fluttertoast.showToast(
            msg: "Error: bad request",
            backgroundColor: Colors.red,
          );
          break;
        case 401:
          Fluttertoast.showToast(
            msg: "Error: Unauthorised, please login again",
            backgroundColor: Colors.red,
          );
          break;
        case 422:
          Fluttertoast.showToast(
            msg: "Error: 422, please try again later",
            backgroundColor: Colors.red,
          );
          break;
        case 500:
          Fluttertoast.showToast(
            msg: "Error: Server Error",
            backgroundColor: Colors.red,
          );
          break;
      }
    }
  }

  checkDateAvail(String date, int id) async {
    // print("date: $date, id: $id");
    var type = widget.data["channel"].toLowerCase();
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse(
      "$baseUrl/app/360/income?header=ajnjxbnuhjsbxnhujbxncujhbxdcbhjnasuhjbn&income=$id&access=checkperiod_ajhbxsjnbjsxbnoaklmsikn&period=$date",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    // print(response.statusCode);
    if (response.statusCode == 200) {
      EasyLoading.dismiss();

      var res = jsonDecode(response.body);

      if (res["success"] == false) {
        return dialogBox.options(
          context,
          'New Update Record',
          'The Period records does not exist. \nAre you sure you want to add this period?',
          () {
            acceptDate(date, id);
          },
        );
      } else {
        valueNonPort.text = res["asset_records"]["amount"].toString() ?? "";
      }
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Braiditem(data: jsonDecode(response.body)),
      //     ));
    } else {
      timer.cancel();
      dateNonPort.text = "";
      EasyLoading.dismiss();
      switch (response.statusCode) {
        case 400:
          Fluttertoast.showToast(
            msg: "Error: bad request",
            backgroundColor: Colors.red,
          );
          break;
        case 401:
          Fluttertoast.showToast(
            msg: "Error: Unauthorised, please login again",
            backgroundColor: Colors.red,
          );
          break;
        case 404:
          Fluttertoast.showToast(
            msg: "Not found, try again later",
            backgroundColor: Colors.red,
          );
          break;
        case 422:
          Fluttertoast.showToast(
            msg: "Error: 422, please try again later",
            backgroundColor: Colors.red,
          );
          break;
        case 500:
          Fluttertoast.showToast(
            msg: "Error: Server Error",
            backgroundColor: Colors.red,
          );
          break;
      }
    }
  }

  acceptDate(String date, int id) async {
    var type = widget.data["channel"].toLowerCase();
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse(
      "$baseUrl/app/360/income?header=ajnjxbnuhjsbxnhujbxncujhbxdcbhjnasuhjbn&income=$id&access=addnewperiodadd_ajhbxsjbhnsjhbjbnsxjk&period=$date",
    );

    print("date: $date, id: $id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    // print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      EasyLoading.dismiss();
    } else {
      timer.cancel();
      EasyLoading.dismiss();
      switch (response.statusCode) {
        case 400:
          Fluttertoast.showToast(
            msg: "Error: bad request",
            backgroundColor: Colors.red,
          );
          break;
        case 404:
          Fluttertoast.showToast(
            msg: "Not found, try again later",
            backgroundColor: Colors.red,
          );
          break;
        case 401:
          Fluttertoast.showToast(
            msg: "Error: Unauthorised, please login again",
            backgroundColor: Colors.red,
          );
          break;
        case 422:
          Fluttertoast.showToast(
            msg: "Error: 422, please try again later",
            backgroundColor: Colors.red,
          );
          break;
        case 500:
          Fluttertoast.showToast(
            msg: "Error: Server Error",
            backgroundColor: Colors.red,
          );
          break;
      }
    }
  }

  nowPostUpdate(int id) async {
    // print("now print id: $id");
    Timer timer = Timer(const Duration(seconds: 50), () {
      EasyLoading.dismiss();
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/360/income/records/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    Map<String, dynamic> data = {
      "record_period": dateDB,
      "amount": valueNonPort.text,
      "tithe": tithepaidvalue.text,
      "taxes": taxespaidvalue.text,
      "others": othersvalue.text,
      "note": detailsNonPort.text,
    };

    // print(dateDB);
    var response = await http.post(
      url,
      body: data,
      headers: {"Authorization": 'Bearer $token'},
    );
    print(id);
    if (response.statusCode == 200 || response.statusCode == 201) {
      EasyLoading.dismiss();
      income();
    } else {
      print(response.statusCode);
      timer.cancel();
      EasyLoading.dismiss();
      switch (response.statusCode) {
        case 400:
          Fluttertoast.showToast(
            msg: "Error: bad request",
            backgroundColor: Colors.red,
          );
          break;
        case 401:
          Fluttertoast.showToast(
            msg: "Error: Unauthorised, please login again",
            backgroundColor: Colors.red,
          );
          break;
        case 404:
          Fluttertoast.showToast(
            msg: "Error: not found",
            backgroundColor: Colors.red,
          );
          break;
        case 422:
          Fluttertoast.showToast(
            msg: "Error: 422, please try again later",
            backgroundColor: Colors.red,
          );
          break;
        case 500:
          Fluttertoast.showToast(
            msg: "Asset not Found",
            backgroundColor: Colors.red,
          );
          break;
      }
    }
  }

  update() async {
    FocusScope.of(context).requestFocus(FocusNode());

    // Parse the date string
    DateTime today = DateTime.now();
    DateTime incomeDate;
    try {
      incomeDate = DateFormat.yMMMMd().parse(
        date.text,
      ); // Assuming date.text is in "May 22, 2024" format
    } catch (e) {
      dialogBox.information(context, 'Error', 'Invalid date format.');
      return;
    }

    // Validate the income date
    if (incomeDate.isAfter(today)) {
      dialogBox.information(
        context,
        'Error',
        'The income date must be a date before today.',
      );
      return;
    }

    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    dialogBox.waiting(context, "Saving");
    var id = widget.data["id"];
    print("id{$id}");

    var url = "$baseUrl/app/360/income/$id";
    var urlr = "$baseUrl/app/360/tiles";
    print('amount:${value.text}');
    Map<String, dynamic> data = {
      "income_type": type == 'Non-Portfolio Income'
          ? "non_portfolio"
          : "portfolio",
      "amount": value.text,
      "income_frequency": frequency,
      "income_date": dateDB,
    };

    if (type == 'Asset Portfolio Income') {
      data["portfolio_asset"] = idA;
    }

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await dio.post(
      url,
      data: data,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );

    if (response.statusCode == 400) {
      Fluttertoast.showToast(msg: "Something went wrong");
      timer.cancel();
      return;
    }

    if (response.statusCode == 200) {
      try {
        var response = await dio.get(
          urlr,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );
        context.read<Providers>().setRecent(response.data["tiles"]);
        income();
        Fluttertoast.showToast(msg: "Income Information updated successfully");
      } catch (e) {
        Navigator.pop(context);
      }
    }

    timer.cancel();
    Navigator.pop(context);
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
        ? "$baseUrl/app/360/income?header=inakjkxbnjksbxjnbsjxnbxjcbnxcjbnxcjhbxnmc&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.data["id"]}"
        : "$baseUrl/app/360/income?header=inakjkxbnjksbxjnbsjxnbxjcbnxcjbnxcjhbxnmc&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.data["id"]}";
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

        Navigator.pop(context);
        income();
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
    }
  }

  income() async {
    /* connectTo(context, "get", "/app/360/income", {}, shoot: () {
      var res = Provider.of<Providers>(context, listen: false).httpData;
      List assets = res["portfolio_asset"];
      List incomeData = res["incomes"];
      var incomeDataLite = res["income_detail"];

      Navigator.push(
          context, 
          MaterialPageRoute(
              builder: (context) => Incomedetails(incomeData, incomeDataLite)));
    }); */
    var timer = Timer(const Duration(seconds: 50), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    var url = "$baseUrl/app/360/income";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await dio.get(
      url,
      options: Options(headers: {"Authorization": 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      List assets = response.data["portfolio_asset"];
      List incomeData = response.data["incomes"];
      var incomeDataLite = response.data["income_detail"];
      timer.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Incomedetails(incomeData, incomeDataLite),
        ),
      );
    } else {
      Navigator.pop(context);
      timer.cancel();
    }
  }
}
