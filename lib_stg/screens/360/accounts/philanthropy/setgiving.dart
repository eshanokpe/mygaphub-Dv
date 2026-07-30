import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'philanthropy.dart';

class Setgiving extends StatefulWidget {
  // final double total;
  final Map data;

  const Setgiving(this.data, {super.key});
  @override
  _SetgivingState createState() => _SetgivingState();
}

class _SetgivingState extends State<Setgiving> {
  TextEditingController charity = TextEditingController();
  TextEditingController extended = TextEditingController();
  FocusNode charFoc = FocusNode();
  TextEditingController personal = TextEditingController();
  TextEditingController others = TextEditingController();
  double total1 = 0;
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  increment() {
    setState(() {
      double a = charity.text.isEmpty ? 0 : double.parse(charity.text);
      double b = extended.text.isEmpty ? 0 : double.parse(extended.text);
      double c = personal.text.isEmpty ? 0 : double.parse(personal.text);
      double d = others.text.isEmpty ? 0 : double.parse(others.text);

      total1 = a + b + c + d;
    });
  }

  var allocated;

  @override
  void initState() {
    super.initState();
    charFoc.requestFocus();
    charity.text = widget.data['data']["philantrophy"]["charity"].toString();
    extended.text = widget.data['data']["philantrophy"]["family_support"]
        .toString();
    personal.text = widget.data['data']["philantrophy"]["personal_commitments"]
        .toString();
    others.text = widget.data['data']["philantrophy"]["others"].toString();

    charity.addListener(increment);
    extended.addListener(increment);
    personal.addListener(increment);
    others.addListener(increment);
    // charity.clear();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    // var diff2 = diff - total1.round();
    allocated =
        num.parse(widget.data['data']["grand"]["current"].toString()) - total1;

    // print(widget.data);
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String currency = context.watch<Providers>().snapshotmodel.currency;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Philanthropy",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * .05),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * .02,
            vertical: height * .01,
          ),
          child: Column(
            children: [
              Text(
                "(Allocate your Giving)",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: width * .06,
                ),
              ),
              SizedBox(height: height * .01),
              Text(
                "You have $currency$allocated to allocate in your \"Giving\""
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: width * .04,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: height * .05),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Charitable Giving",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: width * .045,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      focusNode: charFoc,
                      onTap: () {
                        if (charity.text == '0') {
                          charity.clear();
                        }
                      },
                      inputFormatters: [amountValidator],
                      controller: charity,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(width * .03),
                        prefix: Text(currency),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Extended Family Support",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: width * .045,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onTap: () {
                        if (extended.text == '0') {
                          extended.clear();
                        }
                      },
                      inputFormatters: [amountValidator],
                      controller: extended,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(width * .03),
                        prefix: Text(currency),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Personal Commitments",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: width * .045,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      inputFormatters: [amountValidator],
                      onTap: () {
                        if (personal.text == '0') {
                          personal.clear();
                        }
                      },
                      controller: personal,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(width * .03),
                        prefix: Text(currency),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Others",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: width * .045,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      inputFormatters: [amountValidator],
                      controller: others,
                      onTap: () {
                        if (others.text == '0') {
                          others.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(width * .03),
                        prefix: Text(currency),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * .01),
                  ),
                ),
                onPressed: allocated == 0
                    ? () async {
                        dialogBox.waiting(context, "Saving");
                        var url2 = "$baseUrl/app/360/philantrophy";

                        final prefs = await SharedPreferences.getInstance();
                        String? token = prefs.getString('tokenDB');
                        var response = await dio.post(
                          url2,
                          data: {
                            "charity": charity.text,
                            "family_support": extended.text,
                            "personal": personal.text,
                            "others": others.text,
                          },
                          options: Options(
                            headers: {"Authorization": 'Bearer $token'},
                          ),
                        );
                        if (response.statusCode == 200) {
                          context.read<Providers>().philanthropydata;
                          context.read<Providers>().snapshotmodel.currency;
                          Navigator.pop(context);
                          phila(currency);
                        } else {}
                      }
                    : null,
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: width * .045,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  phila(currency) async {
    var timer = Timer(const Duration(milliseconds: 40000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    dialogBox.waiting(context, 'Loading');
    var url2 = "$baseUrl/app/360/philantrophy";

    final prefs = await SharedPreferences.getInstance();
    String? finalToken = prefs.getString('tokenDB');

    var response2 = await dio.get(
      url2,
      options: Options(headers: {"Authorization": 'Bearer $finalToken'}),
    );
    // print(response2.data);
    if (response2.statusCode == 200) {
      timer.cancel();
      Navigator.pop(context);
      Navigator.pop(context);
      context.read<Providers>().setphilanList(response2.data);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => Philanthropy(response2.data, currency)));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Philanthropy(response2.data, currency),
        ),
      );

      // if (response2.data["grand"]["current"] !=
      //     response2.data["philantrophy_detail"]["sum"]) {
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => Setgiving(
      //           // double.parse(response2.data["grand"]["current"].toString()),
      //           response2.data)));
      // } else {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => Philanthropy(response2.data, currency)));
      // }
      // print(analyticsinfo.grand);
      // print(response2.data);
    } else {
      timer.cancel();
      Navigator.pop(context);
    }
  }
}
