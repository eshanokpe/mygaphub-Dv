import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'braiditem.dart';

class Summary extends StatefulWidget {
  final String name;
  final List details;
  final Map data;

  const Summary({
    super.key,
    required this.name,
    required this.details,
    required this.data,
  });

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  TextEditingController period = TextEditingController();
  TextEditingController revenue = TextEditingController();
  TextEditingController expenditure = TextEditingController();
  TextEditingController mtnDetails = TextEditingController();
  TextEditingController otherNotes = TextEditingController();
  TextEditingController income = TextEditingController();
  TextEditingController value = TextEditingController();
  var t;
  var m;
  var c;
  var o;
  DialogBox dialogBox = DialogBox();

  @override
  void initState() {
    super.initState();
    value.text = widget.details[1].toString();
    period.text = widget.details[0].toString();
    revenue.text = widget.details[2].toString();
    t = double.parse(widget.details[3].toString());
    m = double.parse(widget.details[4].toString());
    c = double.parse(widget.details[5].toString());
    o = double.parse(widget.details[9].toString());
    mtnDetails.text = widget.details[6] ?? "";
    otherNotes.text = widget.details[7] ?? "";
    expenditure.text = (t + m + c + o).toString();

    income.text =
        (double.parse(revenue.text.toString()) -
                double.parse(expenditure.text.toString()))
            .round()
            .toString();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final String currency = widget.details[8];
    var type = widget.data["asset_class"];
    var id = widget.data["id"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffBDBDBA),
        title: Text(
          " ${widget.name}",
          style: TextStyle(
            color: Colors.white,
            fontSize: width * .045,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * .02,
          vertical: height * .01,
        ),
        child: ListView(
          children: [
            Container(
              color: const Color(0xffE6C069),
              child: Padding(
                padding: EdgeInsets.all(width * .02),
                child: Text(
                  "Update Summary",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * .05,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  TextRow(
                    thick: true,
                    controller: period,
                    maxLines: 1,
                    text: "Update Period",
                  ),
                  SizedBox(height: height * .03),
                  TextRow(
                    controller: value,
                    currency: currency,
                    maxLines: 1,
                    text: "Asset Value this period",
                  ),
                  SizedBox(height: height * .03),
                  TextRow(
                    controller: revenue,
                    currency: currency,
                    maxLines: 1,
                    text: "Revenue this period",
                  ),
                  SizedBox(height: height * .03),
                  TextRow(
                    controller: expenditure,
                    maxLines: 1,
                    currency: currency,
                    text: "Expenditure this period",
                  ),
                  SizedBox(height: height * .03),
                  TextRow(
                    controller: income,
                    currency: currency,
                    maxLines: 1,
                    text: "NET INCOME",
                    thick: true,
                  ),
                  SizedBox(height: height * .03),
                  TextRow(
                    controller: mtnDetails,
                    maxLines: 1,
                    text: "Maintenace Details",
                  ),
                  SizedBox(height: height * .03),
                  TextRow(
                    controller: otherNotes,
                    maxLines: 1,
                    text: "Other notes",
                  ),
                  SizedBox(height: height * .03),
                ],
              ),
            ),
            SizedBox(height: height * .02),
            ElevatedButton(
              onPressed: () async {
                dialogBox.waiting(context, "Updating");
                var url = Uri.parse(
                  "$baseUrl/app/portfolio/update/records/$id",
                );
                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('tokenDB');
                Map body = {
                  "amount": value.text,
                  "revenue": revenue.text,
                  "management": m.toString(),
                  "taxes": t.toString(),
                  "period": widget.details[10].toString(),
                  "maintenance": c.toString(),
                  "others": o.toString(),
                  "maintenance_details": mtnDetails.text,
                  "note": otherNotes.text,
                };
                var response = await http.post(
                  url,
                  body: body,
                  headers: {"Authorization": 'Bearer $token'},
                );

                if (response.statusCode == 200 &&
                    jsonDecode(response.body)["status"]) {
                  var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
                  var response2 = await http.get(
                    url,
                    headers: {"Authorization": 'Bearer $token'},
                  );

                  if (response2.statusCode == 200) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Braiditem(data: jsonDecode(response2.body)),
                      ),
                    );
                    Fluttertoast.showToast(msg: "Updated Successfully");
                  } else {
                    Navigator.pop(context);

                    Fluttertoast.showToast(msg: "Error");
                  }
                } else {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "Error");
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xffF1DBB1),
                ),
              ),
              child: Text(
                "Submit Updates",
                style: TextStyle(
                  fontSize: width * .04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Text(widget.details[10].toString())
          ],
        ),
      ),
    );
  }
}

class TextRow extends StatelessWidget {
  const TextRow({
    super.key,
    required this.controller,
    required this.maxLines,
    this.currency = "",
    this.thick = false,
    required this.text,
  });

  final TextEditingController controller;
  final int maxLines;
  final String text;
  final String currency;
  final bool thick;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: TextStyle(
              fontSize: width * .045,
              fontWeight: thick ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            keyboardType: TextInputType.name,
            controller: controller,
            maxLines: maxLines,
            onTap: () {
              if (controller.text == "0") {
                controller.clear();
              }
            },
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: thick ? FontWeight.w400 : FontWeight.w300,
            ),
            enabled: false,
            decoration: InputDecoration(
              prefix: Text(currency),
              filled: true,
              contentPadding: EdgeInsets.all(width * .02),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .01),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
