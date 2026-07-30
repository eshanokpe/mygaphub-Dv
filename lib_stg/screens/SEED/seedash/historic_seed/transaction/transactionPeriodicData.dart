import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/screens/SEED/seedash/historic_seed/transaction_details.dart';
import 'package:GapHub/utils/constants.dart';

class TransactionPeriodicData extends StatefulWidget {
  final String date;
  String historicdate;
  final List list;

  TransactionPeriodicData({
    super.key,
    required this.date,
    required this.historicdate,
    required this.list,
  });

  @override
  State<TransactionPeriodicData> createState() =>
      _TransactionPeriodicDataState();
}

class _TransactionPeriodicDataState extends State<TransactionPeriodicData> {
  final DateFormat dateFormatter = DateFormat("MMM, yyyy");

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      width: width,
      margin: EdgeInsets.symmetric(horizontal: width * 0.18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC4C4C4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            widget.date.isNotEmpty
                ? dateFormatter.format(
                    DateTime.tryParse(widget.date) ?? DateTime.now(),
                  )
                : "Select Date",
          ),
          value: (widget.list.contains(widget.historicdate))
              ? widget.historicdate
              : null,
          items: widget.list.map((data) {
            return DropdownMenuItem<String>(
              value: data,
              child: Text(dateFormatter.format(DateTime.parse(data))),
            );
          }).toList(),
          onChanged: (value) async {
            if (value == null) return;

            setState(() {
              widget.historicdate = value;
            });

            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('tokenDB');
            if (token == null) return;

            final urlSA = Uri.parse(
              "$baseUrl/app/seed/history/${widget.historicdate}",
            );
            final urlDifferences = Uri.parse(
              "$baseUrl/app/seed/history/${widget.date}/diffrences",
            );

            try {
              final response2 = await http.get(
                urlDifferences,
                headers: {
                  "Authorization": 'Bearer $token',
                  "Accept": "application/json",
                  "Content-Type": "application/x-www-form-urlencoded",
                },
              );

              final response = await http.get(
                urlSA,
                headers: {
                  "Authorization": 'Bearer $token',
                  "Accept": "application/json",
                  "Content-Type": "application/x-www-form-urlencoded",
                },
              );

              if (response.statusCode == 200) {
                final Map<String, dynamic> body2 = jsonDecode(response2.body);
                print("body2:$body2");
                final List<dynamic> data2 = body2['data']['allocations'];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetials(
                      transdata: data2,
                      historicdate: widget.historicdate,
                      list: widget.list,
                    ),
                  ),
                );
              } else {
                Fluttertoast.showToast(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  msg: 'No Data Found',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            } catch (e) {
              // Fluttertoast.showToast(
              //   backgroundColor: Colors.red,
              //   textColor: Colors.white,
              //   msg: 'Error fetching data',
              //   toastLength: Toast.LENGTH_SHORT,
              //   gravity: ToastGravity.BOTTOM,
              // );
            }
          },
        ),
      ),
    );
  }
}
