import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:GapHub/screens/360/accounts/assetsAcc/equity/equitydetails.dart';

class Equityitem extends StatefulWidget {
  final Map item;
  final bool archived;

  const Equityitem({super.key, required this.item, this.archived = false});
  @override
  _EquityitemState createState() => _EquityitemState();
}

class _EquityitemState extends State<Equityitem> {
  TextEditingController value = TextEditingController();
  TextEditingController mortgage = TextEditingController();
  TextEditingController percent = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController description = TextEditingController();
  DialogBox dialogBox = DialogBox();
  bool enable = false;

  @override
  void initState() {
    super.initState();
    var item = widget.item;

    item["market_value"] == null
        ? value.text = "0"
        : value.text = "${item["market_value"] ?? 0}";

    mortgage.text = "${item["mortgage"]["current_balance"] ?? 0}";

    percent.text = "${item["ownership"].round()}%";

    address.text = "${item["location"]}" ?? "";
    date.text = "${item["date_acquired"]}" ?? "";
  }

  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    var currency = context.watch<Providers>().snapshotmodel.currency;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String formatDate(DateTime date) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date);
    }

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          date.text = formatDate(picked);
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          '${item["location"]}',
          style: TextStyle(fontSize: width * .04, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                enable = true;
              });
            },
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
                "Home Equity - ${item["equity_type"] ?? ""}",
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
                  'Home Value',
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: value,
                keyboardType: TextInputType.number,
                inputFormatters: [amountValidator],
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefix: Text("$currency "),
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
                  'Mortgage',
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: false,
                controller: mortgage,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(fontSize: width * .03),
                  prefix: Text("$currency "),
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
                  'Ownership Percentage',
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: false,
                controller: percent,
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
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Home Address',
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: false,
                maxLines: 3,
                controller: address,
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
              SizedBox(height: height * .03),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Date Acquired',
                  style: TextStyle(
                    fontSize: width * .035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: height * .005),
              TextFormField(
                enabled: enable,
                controller: date,
                maxLines: 1,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                  ),
                  contentPadding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.03,
                  ),
                  border: const OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: enable ? () => selectDate(context) : null,
              ),
              SizedBox(
                height: height * .05,
                child: Visibility(
                  visible: !enable,
                  child: const Divider(thickness: 2),
                ),
              ),
              Visibility(
                visible: !enable,
                child: Container(
                  padding: EdgeInsets.only(
                    top: width * .02,
                    bottom: width * .02,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Ownership Chart",
                          style: TextStyle(
                            // decoration: TextDecoration.underline,
                            fontSize: width * .04,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Piechart(
                        doiwant: true,
                        values: item["chart"]["values"],
                        labels: item["chart"]["labels"],
                        colors: const ["0XFF581845", "0XFFFF5733"],
                        percent: item["chart"]["percentages"],
                      ),

                      // Text(item.toString())
                    ],
                  ),
                ),
              ),
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
                    "Update",
                    style: TextStyle(
                      // decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: width * .04,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * .03),
              Visibility(
                visible: !enable,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.grey[400],
                  ),
                  child: Text(
                    widget.archived ? " Restore Account" : "Remove Account",
                    style: TextStyle(
                      // decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: width * .035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addorremove() async {
    dialogBox.waiting(context, "Loading");
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    // var url2 = Uri.parse('$baseUrl/app/seveng/edit');
    var urlr = Uri.parse("$baseUrl/app/360/tiles");

    var url = widget.archived
        ? Uri.parse(
            "$baseUrl/app/360/equity?header=equhbvkjhvjhcfhxcfhgcfcvfcvgvbnstrgxfjbhmn&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${widget.item["id"]}",
          )
        : Uri.parse(
            "$baseUrl/app/360/equity?header=equhbvkjhvjhcfhxcfhgcfcvfcvgvbnstrgxfjbhmn&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${widget.item["id"]}",
          );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    print('${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        var response = await http.get(
          urlr,
          headers: {"Authorization": 'Bearer $token'},
        );
        var data = jsonDecode(response.body);
        context.read<Providers>().setRecent(data["tiles"]);

        Navigator.pop(context);
        equity();
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

  equity() async {
    var url = Uri.parse("$baseUrl/app/360/equity");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var mapList = data["equity"];
      var mapListLite = data["equity_detail"];
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);

      if (widget.archived) {
        Navigator.pop(context);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Equitydetails(mapList, mapListLite),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  update() async {
    var timer = Timer(const Duration(seconds: 40), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, "Saving");
    var id = widget.item["id"];

    var url = Uri.parse("$baseUrl/app/360/equity/$id");
    var urlr = Uri.parse("$baseUrl/app/360/tiles");

    Map data = {"market_value": value.text, "date_acquired": date.text};

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.post(
      url,
      body: data,
      headers: {"Authorization": 'Bearer $token'},
    );
    print('${response.statusCode}');
    if (response.statusCode == 400) {
      Navigator.pop(context);
      timer.cancel();
      return;
    }

    if (response.statusCode == 200) {
      try {
        var response = await http.get(
          urlr,
          headers: {"Authorization": 'Bearer $token'},
        );
        var body = jsonDecode(response.body);
        context.read<Providers>().setRecent(body["tiles"]);
        Fluttertoast.showToast(
          backgroundColor: Colors.green,
          msg: "Home Equity Information updated successfully",
        );
        equity();
      } catch (e) {
        Navigator.pop(context);
      }
      timer.cancel();
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }
}
