import 'dart:convert';

import 'package:GapHub/screens/SEED/seedash/historic_seed/historicdate.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeriodicData extends StatefulWidget {
  final String? date;
  final String? historicdate;
  final List? list;

  const PeriodicData({super.key, this.date, this.historicdate, this.list});

  @override
  State<PeriodicData> createState() => _PeriodicDataState();
}

class _PeriodicDataState extends State<PeriodicData> {
  String? selectedHistoricDate;

  @override
  void initState() {
    super.initState();
    selectedHistoricDate = widget.historicdate;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("MMM, yyyy");
    Orientation orientation = MediaQuery.of(context).orientation;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      width: width,
      margin: EdgeInsets.symmetric(horizontal: width * 0.18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 196, 196)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: widget.date != null
              ? Text(dateFormat.format(DateTime.parse(widget.date!)))
              : const Text("Select Date"),
          value: (widget.list?.contains(selectedHistoricDate) ?? false)
              ? selectedHistoricDate
              : null,
          items: widget.list?.map((data) {
            return DropdownMenuItem<String>(
              value: data,
              child: Text(dateFormat.format(DateTime.parse(data))),
            );
          }).toList(),
          onChanged: (value) async {
            if (value == null) return;

            setState(() {
              selectedHistoricDate = value;
            });

            final Uri urlSA = Uri.parse("$baseUrl/app/seed/history/$value");
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('tokenDB');

            try {
              final response = await http.get(
                urlSA,
                headers: {
                  "Authorization": 'Bearer $token',
                  "Accept": "application/json",
                  "Content-Type": "application/x-www-form-urlencoded",
                },
              );

              if (response.statusCode == 200) {
                final Map<String, dynamic> body = jsonDecode(response.body);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoricDate(
                      historicdata: body,
                      date: value,
                      list: widget.list!,
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
              Fluttertoast.showToast(
                backgroundColor: Colors.red,
                textColor: Colors.white,
                msg: 'Error fetching data',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          },
        ),
      ),
    );
  }
}
